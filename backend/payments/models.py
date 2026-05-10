from django.db import models
from django.conf import settings
from bookings.models import Booking


class Payment(models.Model):
    """
    Tracks payment for each booking.
    Status: pending → paid → failed → refunded
    """

    STATUS_CHOICES = [
        ('pending',  'Pending'),
        ('paid',     'Paid'),
        ('failed',   'Failed'),
        ('refunded', 'Refunded'),
    ]

    METHOD_CHOICES = [
        ('cash',       'Cash on Delivery'),
        ('easypaisa',  'Easypaisa'),
        ('jazzcash',   'JazzCash'),
        ('card',       'Credit/Debit Card'),
    ]

    booking        = models.OneToOneField(
        Booking, on_delete=models.CASCADE, related_name='payment'
    )
    customer       = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='payments'
    )
    amount         = models.DecimalField(max_digits=10, decimal_places=2)
    method         = models.CharField(max_length=20, choices=METHOD_CHOICES, default='cash')
    status         = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')

    # Mock transaction ID (real gateway would return this)
    transaction_id = models.CharField(max_length=100, blank=True)

    paid_at    = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Payment #{self.id} | {self.customer} | {self.amount} PKR | {self.status}"