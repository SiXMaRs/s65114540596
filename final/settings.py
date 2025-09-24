# settings.py (ฉบับแก้ไขสมบูรณ์)

import os
from pathlib import Path

# ==============================================================================
# CORE PATHS & SECURITY
# ==============================================================================
BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = os.getenv('DJANGO_SECRET_KEY', 'django-insecure-fallback-key-for-dev')
DEBUG = os.getenv('DJANGO_DEBUG', 'False') == 'True'

def _csv(v, default=""):
    return [x.strip() for x in (v or default).split(",") if x.strip()]
ALLOWED_HOSTS = _csv(os.getenv("DJANGO_ALLOWED_HOSTS", "localhost,127.0.0.1"))

# --- Path Prefix ---
# บอกให้ Django รู้ว่ามี Prefix อยู่ข้างหน้า (สำคัญมาก)
FORCE_SCRIPT_NAME = '/s65114540596'

# ==============================================================================
# APPLICATION DEFINITION
# ==============================================================================
INSTALLED_APPS = [
    'django.contrib.admin', 'django.contrib.auth', 'django.contrib.contenttypes',
    'django.contrib.sessions', 'django.contrib.messages', 'django.contrib.staticfiles',
    'django.contrib.humanize', 'tailwind', 'vfit',
]
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    "whitenoise.middleware.WhiteNoiseMiddleware",
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]
ROOT_URLCONF = 'final.urls'
WSGI_APPLICATION = 'final.wsgi.application'
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# ==============================================================================
# TEMPLATES & TAILWIND
# ==============================================================================
TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'], 'APP_DIRS': True,
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
TAILWIND_APP_NAME = 'theme'

# ==============================================================================
# DATABASE
# ==============================================================================
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.getenv('POSTGRES_DB'), 'USER': os.getenv('POSTGRES_USER'),
        'PASSWORD': os.getenv('POSTGRES_PASSWORD'), 'HOST': 'db',
        'PORT': os.getenv('POSTGRES_PORT', '5432'), 'CONN_MAX_AGE': 60,
    }
}

# ==============================================================================
# STATIC & MEDIA FILES CONFIGURATION
# ==============================================================================
STATIC_URL = 'static/'


STATIC_ROOT = BASE_DIR / "staticfiles"
STATICFILES_DIRS = [BASE_DIR / 'static']
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

if not DEBUG:
    STATICFILES_STORAGE = "whitenoise.storage.CompressedManifestStaticFilesStorage"

# ==============================================================================
# AUTH, CSRF, AND OTHER SETTINGS
# ==============================================================================
LOGIN_URL = '/login/'
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]
# CSRF
_public_port = os.getenv("PUBLIC_PORT")
_csrf = []
for h in ALLOWED_HOSTS:
    _csrf += [f"http://{h}", f"https://{h}"]
    if _public_port:
        _csrf += [f"http://{h}:{_public_port}", f"https://{h}:{_public_port}"]
# You can add other trusted origins if needed
# _csrf.append('https://your-ngrok-or-domain.com')
CSRF_TRUSTED_ORIGINS = _csrf