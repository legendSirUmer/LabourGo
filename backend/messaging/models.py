from django.db import models
from django.conf import settings
from bookings.models import Booking


class Message(models.Model):
    """
    Model for storing messages between customer and provider.
    """
    booking = models.ForeignKey(
        Booking,
        on_delete=models.CASCADE,
        related_name='messages'
    )
    sender = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='sent_messages'
    )
    receiver = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='received_messages'
    )
    content = models.TextField()
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['created_at']
        indexes = [
            models.Index(fields=['booking', 'created_at']),
            models.Index(fields=['sender', 'receiver']),
        ]

    def __str__(self):
        return f"Message #{self.id} | {self.sender} → {self.receiver} | Booking #{self.booking.id}"


class ChatRoom(models.Model):
    """
    Represents a unique conversation between customer and provider for a booking.
    """
    booking = models.OneToOneField(
        Booking,
        on_delete=models.CASCADE,
        related_name='chat_room'
    )
    customer = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='customer_chats',
        limit_choices_to={'role': 'customer'}
    )
    provider = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='provider_chats',
        limit_choices_to={'role': 'provider'}
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = [['booking', 'customer', 'provider']]

    def __str__(self):
        return f"ChatRoom #{self.id} | Booking #{self.booking.id}"
