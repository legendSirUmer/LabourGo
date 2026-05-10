from rest_framework import serializers
from .models import Booking, ServiceCategory
from django.contrib.auth import get_user_model

User = get_user_model()


class ServiceCategorySerializer(serializers.ModelSerializer):
    """List all available service categories."""

    class Meta:
        model = ServiceCategory
        fields = ['id', 'name', 'description', 'icon']


class ProviderBasicSerializer(serializers.ModelSerializer):
    """Shows minimal provider info inside a booking."""

    class Meta:
        model = User
        fields = ['id', 'full_name', 'phone', 'profile_pic']


class BookingSerializer(serializers.ModelSerializer):
    """
    Full booking details — used for GET responses.
    Shows nested provider info instead of just an ID.
    """
    provider = ProviderBasicSerializer(read_only=True)
    category = ServiceCategorySerializer(read_only=True)

    class Meta:
        model = Booking
        fields = [
            'id', 'customer', 'provider', 'category',
            'description', 'location_address',
            'scheduled_date', 'scheduled_time',
            'status', 'price_offered',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'customer', 'status', 'created_at', 'updated_at']


class BookingCreateSerializer(serializers.ModelSerializer):
    """
    Used for POST /bookings/create/
    Customer sends provider_id and category_id as plain numbers.
    """
    provider_id = serializers.PrimaryKeyRelatedField(
        queryset=User.objects.filter(role='provider'),
        source='provider'
    )
    category_id = serializers.PrimaryKeyRelatedField(
        queryset=ServiceCategory.objects.all(),
        source='category'
    )

    class Meta:
        model = Booking
        fields = [
            'provider_id', 'category_id',
            'description', 'location_address',
            'scheduled_date', 'scheduled_time',
            'price_offered'
        ]

    def create(self, validated_data):
        customer = self.context['request'].user
        return Booking.objects.create(customer=customer, **validated_data)


class BookingStatusUpdateSerializer(serializers.ModelSerializer):
    """
    Used for PATCH /bookings/<id>/update/
    Provider can only change the status field.
    """

    class Meta:
        model = Booking
        fields = ['status']
