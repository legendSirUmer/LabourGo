from django.db import models

class Provider(models.Model):
    name = models.CharField(max_length=100)
    skills = models.TextField()
    experience = models.IntegerField()
    price_per_hour = models.FloatField()
    availability = models.BooleanField(default=True)
    rating = models.FloatField(default=0)
    jobs_completed = models.IntegerField(default=0)

    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
    ]

    verification_status = models.CharField(
        max_length=10,
        choices=STATUS_CHOICES,
        default='pending'
    )

    def __str__(self):
        return self.name