from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from rest_framework import status
import pyotp

User = get_user_model()


class AuthAPITest(TestCase):
    """Test suite for Authentication endpoints."""

    def setUp(self):
        self.client = APIClient()
        self.register_url = '/api/auth/register/'
        self.login_url    = '/api/auth/login/'
        self.setup_2fa_url = '/api/auth/2fa/setup/'
        self.email_2fa_login_url = '/api/auth/2fa/login/'
        self.verify_2fa_url = '/api/auth/login/2fa/verify/'
        self.password_reset_by_contact_url = '/api/auth/password-reset/by-contact/'
        self.social_login_url = '/api/auth/social-login/'

    def test_customer_registration(self):
        """Customer can register successfully."""
        data = {
            'email':     'test@example.com',
            'full_name': 'Test User',
            'phone':     '03001234567',
            'role':      'customer',
            'password':  'testpass123'
        }
        response = self.client.post(self.register_url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertIn('tokens', response.data)
        self.assertIn('user', response.data)

    def test_login_with_valid_credentials(self):
        """User can login with correct credentials."""
        # Create user first
        User.objects.create_user(
            email='login@test.com',
            full_name='Login User',
            password='testpass123',
            role='customer'
        )
        data = {'email': 'login@test.com', 'password': 'testpass123'}
        response = self.client.post(self.login_url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data['tokens'])

    def test_login_with_wrong_password(self):
        """Login fails with wrong password."""
        User.objects.create_user(
            email='wrong@test.com',
            full_name='Wrong User',
            password='correctpass',
            role='customer'
        )
        data = {'email': 'wrong@test.com', 'password': 'wrongpass'}
        response = self.client.post(self.login_url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_login_requires_2fa_for_enabled_user(self):
        secret = pyotp.random_base32()
        User.objects.create_user(
            email='2fa@test.com',
            full_name='Two Factor User',
            password='testpass123',
            role='customer',
            two_factor_enabled=True,
            two_factor_secret=secret,
        )
        response = self.client.post(
            self.login_url,
            {'email': '2fa@test.com', 'password': 'testpass123'},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data.get('requires_2fa'))
        self.assertIn('challenge_token', response.data)

    def test_verify_2fa_login_success(self):
        secret = pyotp.random_base32()
        user = User.objects.create_user(
            email='2fa-verify@test.com',
            full_name='Two Factor Verify User',
            password='testpass123',
            role='customer',
            two_factor_enabled=True,
            two_factor_secret=secret,
        )
        login_response = self.client.post(
            self.login_url,
            {'email': '2fa-verify@test.com', 'password': 'testpass123'},
            format='json',
        )
        challenge = login_response.data.get('challenge_token')
        code = pyotp.TOTP(secret).now()
        verify_response = self.client.post(
            self.verify_2fa_url,
            {'challenge_token': challenge, 'otp_code': code},
            format='json',
        )
        self.assertEqual(verify_response.status_code, status.HTTP_200_OK)
        self.assertIn('tokens', verify_response.data)

    def test_setup_2fa_by_email(self):
        User.objects.create_user(
            email='setup2fa@test.com',
            full_name='Setup Two Factor',
            password='testpass123',
            role='customer',
        )
        response = self.client.post(
            self.setup_2fa_url,
            {'email': 'setup2fa@test.com'},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('secret', response.data)
        self.assertIn('otpauth_uri', response.data)

    def test_email_based_2fa_login_success(self):
        secret = pyotp.random_base32()
        User.objects.create_user(
            email='email2fa@test.com',
            full_name='Email 2FA User',
            password='testpass123',
            role='customer',
            two_factor_enabled=True,
            two_factor_secret=secret,
        )
        code = pyotp.TOTP(secret).now()
        response = self.client.post(
            self.email_2fa_login_url,
            {'email': 'email2fa@test.com', 'otp_code': code},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('tokens', response.data)

    def test_profile_requires_authentication(self):
        """Profile endpoint returns 401 without token."""
        response = self.client.get('/api/auth/profile/')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_password_reset_by_contact_success(self):
        user = User.objects.create_user(
            email='reset@test.com',
            full_name='Reset User',
            phone='0300-1234567',
            password='oldpass123',
            role='customer',
        )
        response = self.client.post(
            self.password_reset_by_contact_url,
            {
                'email': 'reset@test.com',
                'phone': '03001234567',
                'new_password': 'newpass123',
                'confirm_password': 'newpass123',
            },
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        user.refresh_from_db()
        self.assertTrue(user.check_password('newpass123'))

    def test_password_reset_by_contact_wrong_phone(self):
        User.objects.create_user(
            email='reset2@test.com',
            full_name='Reset User 2',
            phone='03001234567',
            password='oldpass123',
            role='customer',
        )
        response = self.client.post(
            self.password_reset_by_contact_url,
            {
                'email': 'reset2@test.com',
                'phone': '03111234567',
                'new_password': 'newpass123',
                'confirm_password': 'newpass123',
            },
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_social_login_requires_provider(self):
        response = self.client.post(self.social_login_url, {}, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_social_login_google_requires_id_token(self):
        response = self.client.post(
            self.social_login_url,
            {'provider': 'google'},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
