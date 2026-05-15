from rest_framework import status, generics
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import get_user_model
from django.core import signing
import pyotp
from urllib.parse import quote

from .serializers import RegisterSerializer, UserProfileSerializer
from .social_auth import SocialAuthError, verify_social_login

User = get_user_model()
LOGIN_2FA_SALT = 'accounts.login.2fa'


def get_tokens_for_user(user):
    """Generate JWT access + refresh tokens for a user."""
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access':  str(refresh.access_token),
    }


def build_login_2fa_challenge(user):
    return signing.dumps({'user_id': user.id}, salt=LOGIN_2FA_SALT)


def build_otpauth_uri(user, secret):
    account_label = quote(f'LabourGo:{user.email}')
    issuer = quote('LabourGo')
    return f'otpauth://totp/{account_label}?secret={secret}&issuer={issuer}'


class RegisterView(APIView):
    """
    POST /api/auth/register/
    Body: { email, full_name, phone, role, password }
    """
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user   = serializer.save()
            tokens = get_tokens_for_user(user)
            return Response({
                'message': 'Account created successfully!',
                'user':    UserProfileSerializer(user).data,
                'tokens':  tokens,
            }, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class TwoFactorSetupView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        email = (request.data.get('email') or '').strip()
        if not email:
            return Response(
                {'error': 'Email is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response(
                {'error': 'No account found with this email.'},
                status=status.HTTP_404_NOT_FOUND
            )

        secret = user.two_factor_secret or pyotp.random_base32()
        user.two_factor_secret = secret
        user.two_factor_enabled = True
        user.save(update_fields=['two_factor_secret', 'two_factor_enabled'])

        return Response({
            'message': '2FA setup ready.',
            'email': user.email,
            'secret': secret,
            'otpauth_uri': build_otpauth_uri(user, secret),
            'user': UserProfileSerializer(user).data,
        }, status=status.HTTP_200_OK)


class TwoFactorEmailLoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        email = (request.data.get('email') or '').strip()
        otp_code = (request.data.get('otp_code') or '').strip()

        if not email or not otp_code:
            return Response(
                {'error': 'email and otp_code are required.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if not otp_code.isdigit() or len(otp_code) != 6:
            return Response(
                {'error': 'otp_code must be exactly 6 digits.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response(
                {'error': 'No account found with this email.'},
                status=status.HTTP_404_NOT_FOUND
            )

        if not user.two_factor_enabled or not user.two_factor_secret:
            return Response(
                {'error': '2FA is not configured for this account.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        totp = pyotp.TOTP(user.two_factor_secret)
        if not totp.verify(otp_code, valid_window=1):
            return Response(
                {'error': 'Invalid authentication code.'},
                status=status.HTTP_401_UNAUTHORIZED
            )

        tokens = get_tokens_for_user(user)
        return Response({
            'message': 'Login successful!',
            'user': UserProfileSerializer(user).data,
            'tokens': tokens,
        }, status=status.HTTP_200_OK)


class ResetPasswordByContactView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        email = (request.data.get('email') or '').strip()
        phone = (request.data.get('phone') or '').strip()
        new_password = (request.data.get('new_password') or '')
        confirm_password = (request.data.get('confirm_password') or '')

        if not email or not phone or not new_password or not confirm_password:
            return Response(
                {'error': 'email, phone, new_password, and confirm_password are required.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if len(new_password) < 8:
            return Response(
                {'error': 'new_password must be at least 8 characters long.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if new_password != confirm_password:
            return Response(
                {'error': 'new_password and confirm_password do not match.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            user = User.objects.get(email__iexact=email)
        except User.DoesNotExist:
            return Response(
                {'error': 'No account found with this email.'},
                status=status.HTTP_404_NOT_FOUND
            )

        normalized_input_phone = ''.join(ch for ch in phone if ch.isdigit())
        normalized_user_phone = ''.join(ch for ch in (user.phone or '') if ch.isdigit())

        if not normalized_user_phone or normalized_input_phone != normalized_user_phone:
            return Response(
                {'error': 'Email and phone number do not match our records.'},
                status=status.HTTP_401_UNAUTHORIZED
            )

        user.set_password(new_password)
        user.save(update_fields=['password'])

        return Response(
            {'message': 'Password updated successfully.'},
            status=status.HTTP_200_OK
        )


class LoginView(APIView):
    """
    POST /api/auth/login/
    Body: { email, password }
    Returns JWT tokens on success.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        email    = request.data.get('email')
        password = request.data.get('password')

        if not email or not password:
            return Response(
                {'error': 'Email and password are required.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response(
                {'error': 'No account found with this email.'},
                status=status.HTTP_404_NOT_FOUND
            )

        if not user.check_password(password):
            return Response(
                {'error': 'Incorrect password.'},
                status=status.HTTP_401_UNAUTHORIZED
            )

        if user.two_factor_enabled:
            if not user.two_factor_secret:
                return Response(
                    {'error': '2FA is enabled but not configured for this account.'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            return Response({
                'message': '2FA verification required.',
                'requires_2fa': True,
                'challenge_token': build_login_2fa_challenge(user),
                'user': UserProfileSerializer(user).data,
            }, status=status.HTTP_200_OK)

        tokens = get_tokens_for_user(user)
        return Response({
            'message': 'Login successful!',
            'user':    UserProfileSerializer(user).data,
            'tokens':  tokens,
        }, status=status.HTTP_200_OK)


class VerifyTwoFactorLoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        challenge_token = request.data.get('challenge_token')
        otp_code = (request.data.get('otp_code') or '').strip()

        if not challenge_token or not otp_code:
            return Response(
                {'error': 'challenge_token and otp_code are required.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if not otp_code.isdigit() or len(otp_code) != 6:
            return Response(
                {'error': 'otp_code must be exactly 6 digits.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            payload = signing.loads(challenge_token, salt=LOGIN_2FA_SALT, max_age=300)
        except signing.SignatureExpired:
            return Response(
                {'error': '2FA challenge expired. Please login again.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        except signing.BadSignature:
            return Response(
                {'error': 'Invalid 2FA challenge. Please login again.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        user_id = payload.get('user_id')
        if not user_id:
            return Response(
                {'error': 'Invalid challenge payload.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response(
                {'error': 'User not found.'},
                status=status.HTTP_404_NOT_FOUND
            )

        if not user.two_factor_enabled or not user.two_factor_secret:
            return Response(
                {'error': '2FA is not configured for this account.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        totp = pyotp.TOTP(user.two_factor_secret)
        if not totp.verify(otp_code, valid_window=1):
            return Response(
                {'error': 'Invalid authentication code.'},
                status=status.HTTP_401_UNAUTHORIZED
            )

        tokens = get_tokens_for_user(user)
        return Response({
            'message': 'Login successful!',
            'user': UserProfileSerializer(user).data,
            'tokens': tokens,
        }, status=status.HTTP_200_OK)


class ProfileView(generics.RetrieveUpdateAPIView):
    """
    GET  /api/auth/profile/  → View your profile
    PUT  /api/auth/profile/  → Update your profile
    Requires: Authorization: Bearer <access_token>
    """
    permission_classes = [IsAuthenticated]
    serializer_class   = UserProfileSerializer

    def get_object(self):
        return self.request.user


class LogoutView(APIView):
    """
    POST /api/auth/logout/
    Body: { "refresh": "<refresh_token>" }
    Blacklists the refresh token so it can't be used again.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        refresh_token = request.data.get('refresh')
        if not refresh_token:
            return Response(
                {'error': 'Refresh token is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        try:
            token = RefreshToken(refresh_token)
            token.blacklist()
            return Response({'message': 'Logged out successfully.'}, status=status.HTTP_200_OK)
        except Exception:
            return Response(
                {'error': 'Invalid or already blacklisted token.'},
                status=status.HTTP_400_BAD_REQUEST
            )

class ProviderListView(generics.ListAPIView):
    """
    GET /api/auth/providers/
    Returns all service providers.
    Customers use this to pick who to book.
    """
    permission_classes = [IsAuthenticated]
    serializer_class   = UserProfileSerializer

    def get_queryset(self):
        return User.objects.filter(role='provider', is_active=True)


class SocialLoginView(APIView):
    """
    POST /api/auth/social-login/
    Body:
      - provider: "google" | "apple" | "facebook"
      - id_token (google/apple) OR access_token (facebook)
    Returns JWT tokens on success. Creates the user on first sign-in.
    """

    permission_classes = [AllowAny]

    def post(self, request):
        provider = (request.data.get('provider') or '').strip()
        id_token = request.data.get('id_token')
        access_token = request.data.get('access_token')
        requested_role = (request.data.get('role') or 'customer').strip() or 'customer'

        if not provider:
            return Response({'error': 'Provider is required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            info = verify_social_login(
                provider=provider,
                id_token=id_token,
                access_token=access_token,
            )
        except SocialAuthError as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

        provider_field = {
            'google': 'google_sub',
            'apple': 'apple_sub',
            'facebook': 'facebook_id',
        }[info.provider]

        user = User.objects.filter(**{provider_field: info.provider_user_id}).first()

        fallback_email = request.data.get('email')
        fallback_full_name = request.data.get('full_name')
        email = info.email or fallback_email
        full_name = fallback_full_name or info.full_name

        if user is None and email:
            user = User.objects.filter(email__iexact=email).first()
            if user is not None:
                changed_fields = []
                if getattr(user, provider_field) != info.provider_user_id:
                    setattr(user, provider_field, info.provider_user_id)
                    changed_fields.append(provider_field)
                if (not getattr(user, 'full_name', None)) and full_name:
                    user.full_name = full_name
                    changed_fields.append('full_name')
                if changed_fields:
                    user.save(update_fields=changed_fields)

        if user is None:
            if not email:
                return Response(
                    {'error': 'Provider did not return an email address for this user.'},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if not full_name:
                full_name = email.split('@')[0]

            user = User.objects.create_user(
                email=email,
                full_name=full_name,
                phone='',
                role=requested_role if requested_role in ('customer', 'provider') else 'customer',
                password=None,
            )
            setattr(user, provider_field, info.provider_user_id)
            user.save(update_fields=[provider_field])

        tokens = get_tokens_for_user(user)
        return Response(
            {
                'message': 'Login successful!',
                'user': UserProfileSerializer(user).data,
                'tokens': tokens,
            },
            status=status.HTTP_200_OK,
        )
