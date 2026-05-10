from rest_framework import serializers
from .models import Review
from bookings.models import Booking


class ReviewCreateSerializer(serializers.ModelSerializer):
    """
    Customer submits a review.
    They only provide: booking_id, rating, comment.
    Everything else is auto-filled from the booking.
    """
    booking_id = serializers.PrimaryKeyRelatedField(
        queryset=Booking.objects.filter(status='completed'),
        source='booking'
    )

    class Meta:
        model  = Review
        fields = ['booking_id', 'rating', 'comment']

    def validate_booking_id(self, booking):
        """Extra checks before saving."""
        request = self.context['request']

        # Must be the customer of this booking
        if booking.customer != request.user:
            raise serializers.ValidationError(
                "You can only review your own bookings."
            )

        # Cannot review the same booking twice
        if hasattr(booking, 'review'):
            raise serializers.ValidationError(
                "You have already reviewed this booking."
            )

        return booking

    def create(self, validated_data):
        booking  = validated_data['booking']
        request  = self.context['request']
        return Review.objects.create(
            booking  = booking,
            customer = request.user,
            provider = booking.provider,
            **{k: v for k, v in validated_data.items() if k != 'booking'},
        )


class ReviewSerializer(serializers.ModelSerializer):
    """Full review details for GET responses."""

    customer_name = serializers.CharField(source='customer.full_name', read_only=True)
    provider_name = serializers.CharField(source='provider.full_name', read_only=True)
    service_name  = serializers.CharField(source='booking.category.name', read_only=True)

    class Meta:
        model  = Review
        fields = [
            'id', 'booking',
            'customer_name', 'provider_name', 'service_name',
            'rating', 'comment', 'created_at'
        ]