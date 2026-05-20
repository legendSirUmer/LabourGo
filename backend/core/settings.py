from pathlib import Path
from dotenv import load_dotenv
import os

BASE_DIR = Path(__file__).resolve().parent.parent

def _env_bool(name: str, default: bool) -> bool:
    raw = os.getenv(name)
    if raw is None:
        return default
    value = raw.strip().lower()
    if value in ('1', 'true', 't', 'yes', 'y', 'on'):
        return True
    if value in ('0', 'false', 'f', 'no', 'n', 'off'):
        return False
    return default

# Load environment variables from backend/.env (without overriding existing env vars)
load_dotenv(BASE_DIR / '.env')

SECRET_KEY = os.getenv('SECRET_KEY', 'fallback-secret-key')

# Prefer DJANGO_DEBUG to avoid collisions with global DEBUG env vars.
#DEBUG = _env_bool('DJANGO_DEBUG', _env_bool('DEBUG', False))
DEBUG = True  # We'll set this via env vars in production
ALLOWED_HOSTS = ['*']  # We'll restrict this in production

# ─── Apps ───────────────────────────────────────────────
INSTALLED_APPS = [
    'daphne',  # Must be first for ASGI
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # Third-party
    'rest_framework',
    'rest_framework_simplejwt',
    'rest_framework_simplejwt.token_blacklist',
    'corsheaders',
    'channels',

    # Your apps
    'accounts',
    'bookings',
    'reviews',
    'payments',
    'providers',
    'messaging',
]

# ─── Middleware ──────────────────────────────────────────
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # Must be FIRST
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'core.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'core.wsgi.application'

# ─── Database (SQLite for now, PostgreSQL later) ─────────
import os

# ─── Database ────────────────────────────────────────
DATABASE_URL = os.getenv('DATABASE_URL')

if DATABASE_URL:
    # Docker / Production → use PostgreSQL
    import dj_database_url
    DATABASES = {
        'default': dj_database_url.config(
            default=DATABASE_URL,
            conn_max_age=600
        )
    }
else:
    # Local development → use SQLite
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': BASE_DIR / 'db.sqlite3',
        }
    }

# ─── Password Validation ─────────────────────────────────
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# ─── Internationalization ────────────────────────────────
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'Asia/Karachi'
USE_I18N = True
USE_TZ = True

# ─── Static & Media Files ────────────────────────────────
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'

MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'


DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# ─── Custom User Model ───────────────────────────────────
AUTH_USER_MODEL = 'accounts.User'

# ─── REST Framework + JWT ────────────────────────────────
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.AllowAny',
    ),
}

# ─── CORS (Allow Flutter to connect) ────────────────────
CORS_ALLOW_ALL_ORIGINS = True  # Restrict in production
from datetime import timedelta

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME':  timedelta(days=1),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS':  True,
    'BLACKLIST_AFTER_ROTATION': True,
}

# ─── Social Login (OAuth) ─────────────────────────────────
GOOGLE_OAUTH_CLIENT_IDS = [
    cid.strip()
    for cid in os.getenv('GOOGLE_OAUTH_CLIENT_IDS', '').split(',')
    if cid.strip()
]

APPLE_SIGN_IN_CLIENT_IDS = [
    cid.strip()
    for cid in os.getenv('APPLE_SIGN_IN_CLIENT_IDS', '').split(',')
    if cid.strip()
]

FACEBOOK_APP_ID = os.getenv('FACEBOOK_APP_ID', '')
FACEBOOK_APP_SECRET = os.getenv('FACEBOOK_APP_SECRET', '')


CORS_ALLOW_ALL_ORIGINS = True
CORS_ALLOW_CREDENTIALS = True

# ─── Django Channels (WebSocket) ────────────────────────
ASGI_APPLICATION = 'core.asgi.application'

REDIS_URL = os.getenv('REDIS_URL', '').strip()

if REDIS_URL:
    CHANNEL_LAYERS = {
        'default': {
            'BACKEND': 'channels_redis.core.RedisChannelLayer',
            'CONFIG': {
                'hosts': [REDIS_URL],
            },
        },
    }
else:
    # Local development without Redis
    CHANNEL_LAYERS = {
        'default': {
            'BACKEND': 'channels.layers.InMemoryChannelLayer',
        },
    }


ALLOWED_HOSTS += [
    "labourgo.onrender.com",
]

CSRF_TRUSTED_ORIGINS = [
    "https://labourgo.onrender.com",
]

SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')

CSRF_COOKIE_SECURE = True
SESSION_COOKIE_SECURE = True
# To use Redis locally, set REDIS_URL in backend/.env or environment:
# REDIS_URL=redis://127.0.0.1:6379