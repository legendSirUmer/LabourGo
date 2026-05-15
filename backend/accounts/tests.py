from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from rest_framework import status

User = get_user_model()


class AuthAPITest(TestCase):
    """Test suite for Authentication endpoints."""

    def setUp(self):
        self.client = APIClient()
        self.register_url = '/api/auth/register/'
        self.login_url    = '/api/auth/login/'
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

    def test_profile_requires_authentication(self):
        """Profile endpoint returns 401 without token."""
        response = self.client.get('/api/auth/profile/')
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
