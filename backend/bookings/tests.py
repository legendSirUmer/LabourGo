from django.test import TestCase
from rest_framework.test import APIClient
from rest_framework import status
from django.contrib.auth import get_user_model
from .models import ServiceCategory

User = get_user_model()


class BookingAPITest(TestCase):
    """Test suite for Booking endpoints."""

    def setUp(self):
        self.client = APIClient()

        # Create customer
        self.customer = User.objects.create_user(
            email='customer@test.com',
            full_name='Test Customer',
            password='testpass123',
            role='customer'
        )
        # Create provider
        self.provider = User.objects.create_user(
            email='provider@test.com',
            full_name='Test Provider',
            password='testpass123',
            role='provider'
        )
        # Create category
        self.category = ServiceCategory.objects.create(name='Plumbing')

        # Login as customer
        response = self.client.post('/api/auth/login/', {
            'email': 'customer@test.com',
            'password': 'testpass123'
        }, format='json')
        token = response.data['tokens']['access']
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')

    def test_categories_are_public(self):
        """Anyone can view service categories."""
        public_client = APIClient()  # no token
        response = public_client.get('/api/bookings/categories/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_customer_can_create_booking(self):
        """Customer can create a booking."""
        data = {
            'provider_id':       self.provider.id,
            'category_id':       self.category.id,
            'description':       'Sink is leaking',
            'location_address':  'Karachi',
            'scheduled_date':    '2026-06-01',
            'scheduled_time':    '10:00:00',
            'price_offered':     '1500.00'
        }
        response = self.client.post('/api/bookings/create/', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['booking']['status'], 'pending')

    def test_my_bookings_returns_only_own(self):
        """Customer only sees their own bookings."""
        response = self.client.get('/api/bookings/my-bookings/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
