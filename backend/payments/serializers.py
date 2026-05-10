from rest_framework import serializers
from .models import Payment
from bookings.models import Booking


class PaymentCreateSerializer(serializers.ModelSerializer):
    """Customer initiates payment for a booking."""

    booking_id = serializers.PrimaryKeyRelatedField(
        queryset=Booking.objects.all(),
        source='booking'
    )

    class Meta:
        model  = Payment
        fields = ['booking_id', 'amount', 'method']

    def validate_booking_id(self, booking):
        request = self.context['request']

        # Must be the customer of this booking
        if booking.customer != request.user:
            raise serializers.ValidationError(
                "You can only pay for your own bookings."
            )
        # Cannot pay twice
        if hasattr(booking, 'payment'):
            raise serializers.ValidationError(
                "Payment already exists for this booking."
            )
        return booking


class PaymentSerializer(serializers.ModelSerializer):
    """Full payment details."""
    customer_name = serializers.CharField(source='customer.full_name', read_only=True)
    booking_info  = serializers.SerializerMethodField()

    class Meta:
        model  = Payment
        fields = [
            'id', 'booking', 'booking_info',
            'customer_name', 'amount', 'method',
            'status', 'transaction_id',
            'paid_at', 'created_at'
        ]

    def get_booking_info(self, obj):
        return {
            'id':       obj.booking.id,
            'service':  obj.booking.category.name if obj.booking.category else '',
            'provider': obj.booking.provider.full_name,
        }