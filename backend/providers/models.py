from django.db import models

class Provider(models.Model):
    name = models.CharField(max_length=100)
    email = models.EmailField(blank=True, null=True)
    phone = models.CharField(max_length=20, blank=True, null=True)
    image = models.ImageField(upload_to='providers/', blank=True, null=True)
    skills = models.TextField()
    experience = models.IntegerField()
    price_per_hour = models.FloatField()
    service_pricing = models.JSONField(default=list, blank=True)
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


class ProviderCertificate(models.Model):
    STATUS_PENDING = 'pending'
    STATUS_APPROVED = 'approved'
    STATUS_REJECTED = 'rejected'

    STATUS_CHOICES = [
        (STATUS_PENDING, 'Pending'),
        (STATUS_APPROVED, 'Approved'),
        (STATUS_REJECTED, 'Rejected'),
    ]

    provider = models.ForeignKey(
        Provider,
        on_delete=models.CASCADE,
        related_name='certificates',
    )
    skill = models.CharField(max_length=100)
    certificate_number = models.CharField(max_length=100)
    issuing_authority = models.CharField(max_length=150)
    issue_date = models.DateField()
    expiration_date = models.DateField()
    image = models.ImageField(upload_to='certificates/')
    status = models.CharField(
        max_length=10,
        choices=STATUS_CHOICES,
        default=STATUS_PENDING,
    )
    verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'{self.provider.name} - {self.skill} - {self.certificate_number}'

    class Meta:
        ordering = ['-created_at']
