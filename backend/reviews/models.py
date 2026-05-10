from django.db import models
from django.conf import settings
from django.core.validators import MinValueValidator, MaxValueValidator
from bookings.models import Booking


class Review(models.Model):
    """
    A customer reviews a completed booking.
    One booking = maximum one review (enforced by unique_together).
    Rating is 1–5 stars.
    """

    booking = models.OneToOneField(
        Booking,
        on_delete=models.CASCADE,
        related_name='review'
    )
    customer = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='reviews_given'
    )
    provider = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='reviews_received'
    )

    rating  = models.PositiveSmallIntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)]
    )
    comment    = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Review by {self.customer} → {self.provider} | ⭐{self.rating}"

    class Meta:
        ordering = ['-created_at']