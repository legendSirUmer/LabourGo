from django.db import models
from django.conf import settings


class ServiceCategory(models.Model):
    """
    Examples: Plumbing, Electrician, Cleaning, Carpentry
    Admin creates these from the dashboard.
    """
    name        = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    icon        = models.ImageField(upload_to='categories/', blank=True, null=True)

    def __str__(self):
        return self.name

    class Meta:
        verbose_name_plural = 'Service Categories'


class Booking(models.Model):
    """
    Core booking model — links a customer to a service provider.
    """

    STATUS_CHOICES = [
        ('pending',    'Pending'),
        ('accepted',   'Accepted'),
        ('in_progress','In Progress'),
        ('completed',  'Completed'),
        ('cancelled',  'Cancelled'),
    ]

    customer = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='customer_bookings',
        limit_choices_to={'role': 'customer'}
    )
    provider = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='provider_bookings',
        limit_choices_to={'role': 'provider'}
    )

    category         = models.ForeignKey(ServiceCategory, on_delete=models.SET_NULL, null=True)
    description      = models.TextField()
    location_address = models.CharField(max_length=255)

    scheduled_date = models.DateField()
    scheduled_time = models.TimeField()

    status        = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    price_offered = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Booking #{self.id} | {self.customer} → {self.provider} | {self.status}"

    class Meta:
        ordering = ['-created_at']