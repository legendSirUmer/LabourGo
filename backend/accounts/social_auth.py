from __future__ import annotations

from dataclasses import dataclass
import json
import urllib.parse
import urllib.request
from typing import Iterable, Optional

from django.conf import settings


class SocialAuthError(Exception):
    pass


@dataclass(frozen=True)
class SocialUserInfo:
    provider: str
    provider_user_id: str
    email: Optional[str]
    full_name: Optional[str]


def verify_social_login(
    *,
    provider: str,
    id_token: Optional[str] = None,
    access_token: Optional[str] = None,
) -> SocialUserInfo:
    normalized = provider.strip().lower()

    if normalized == 'google':
        if not id_token:
            raise SocialAuthError('`id_token` is required for Google sign-in.')
        return _verify_google(id_token)

    if normalized == 'apple':
        if not id_token:
            raise SocialAuthError('`id_token` is required for Apple sign-in.')
        return _verify_apple(id_token)

    if normalized == 'facebook':
        if not access_token:
            raise SocialAuthError('`access_token` is required for Facebook sign-in.')
        return _verify_facebook(access_token)

    raise SocialAuthError('Unsupported provider. Use one of: google, apple, facebook.')


def _import_pyjwt():
    try:
        import jwt  # type: ignore
        from jwt import PyJWKClient  # type: ignore
    except Exception as e:  # pragma: no cover
        raise SocialAuthError(
            'Server is missing JWT dependencies. Ensure `PyJWT` + `cryptography` are installed.'
        ) from e
    return jwt, PyJWKClient


def _verify_jwt_with_jwks(
    *,
    token: str,
    jwks_url: str,
    audiences: Iterable[str],
    allowed_issuers: Iterable[str],
) -> dict:
    jwt, PyJWKClient = _import_pyjwt()

    audiences_list = [a for a in audiences if a]
    if not audiences_list:
        raise SocialAuthError('Server is missing required OAuth client IDs for this provider.')

    try:
        jwks_client = PyJWKClient(jwks_url)
        signing_key = jwks_client.get_signing_key_from_jwt(token)
        payload = jwt.decode(
            token,
            signing_key.key,
            algorithms=['RS256'],
            audience=audiences_list,
            options={'verify_aud': True},
        )
    except Exception as e:
        raise SocialAuthError('Invalid token (signature/claims).') from e

    issuer = payload.get('iss')
    if issuer not in set(allowed_issuers):
        raise SocialAuthError('Invalid token issuer.')

    return payload


def _verify_google(id_token: str) -> SocialUserInfo:
    payload = _verify_jwt_with_jwks(
        token=id_token,
        jwks_url='https://www.googleapis.com/oauth2/v3/certs',
        audiences=getattr(settings, 'GOOGLE_OAUTH_CLIENT_IDS', []),
        allowed_issuers=('accounts.google.com', 'https://accounts.google.com'),
    )

    sub = payload.get('sub')
    if not sub:
        raise SocialAuthError('Google token is missing `sub`.')

    return SocialUserInfo(
        provider='google',
        provider_user_id=str(sub),
        email=payload.get('email'),
        full_name=payload.get('name') or payload.get('given_name'),
    )


def _verify_apple(id_token: str) -> SocialUserInfo:
    payload = _verify_jwt_with_jwks(
        token=id_token,
        jwks_url='https://appleid.apple.com/auth/keys',
        audiences=getattr(settings, 'APPLE_SIGN_IN_CLIENT_IDS', []),
        allowed_issuers=('https://appleid.apple.com',),
    )

    sub = payload.get('sub')
    if not sub:
        raise SocialAuthError('Apple token is missing `sub`.')

    return SocialUserInfo(
        provider='apple',
        provider_user_id=str(sub),
        email=payload.get('email'),
        full_name=None,
    )


def _read_json(url: str) -> dict:
    req = urllib.request.Request(url, headers={'User-Agent': 'LabourGo/1.0'})
    with urllib.request.urlopen(req, timeout=8) as res:
        body = res.read().decode('utf-8')
    return json.loads(body)


def _verify_facebook(access_token: str) -> SocialUserInfo:
    app_id = getattr(settings, 'FACEBOOK_APP_ID', '') or ''
    app_secret = getattr(settings, 'FACEBOOK_APP_SECRET', '') or ''
    if not app_id or not app_secret:
        raise SocialAuthError('FACEBOOK_APP_ID/FACEBOOK_APP_SECRET are not configured on the server.')

    app_access_token = f'{app_id}|{app_secret}'
    debug_url = (
        'https://graph.facebook.com/debug_token?'
        + urllib.parse.urlencode(
            {'input_token': access_token, 'access_token': app_access_token}
        )
    )
    debug = _read_json(debug_url).get('data') or {}

    if not debug.get('is_valid'):
        raise SocialAuthError('Invalid Facebook access token.')
    if str(debug.get('app_id')) != str(app_id):
        raise SocialAuthError('Facebook token was not issued for this app.')

    me_url = (
        'https://graph.facebook.com/me?'
        + urllib.parse.urlencode(
            {'fields': 'id,name,email', 'access_token': access_token}
        )
    )
    me = _read_json(me_url)

    fb_id = me.get('id') or debug.get('user_id')
    if not fb_id:
        raise SocialAuthError('Facebook token is missing user id.')

    return SocialUserInfo(
        provider='facebook',
        provider_user_id=str(fb_id),
        email=me.get('email'),
        full_name=me.get('name'),
    )

