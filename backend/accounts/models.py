from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models


class UserManager(BaseUserManager):
    """Custom manager to create users via email instead of username."""

    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('Email is required')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)   # bcrypt hashing happens here via Django
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('role', 'admin')
        return self.create_user(email, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
    """
    Custom User Model for LabourGo.
    Supports three roles: customer, provider, admin.
    """

    ROLE_CHOICES = [
        ('customer', 'Customer'),
        ('provider', 'Service Provider'),
        ('admin', 'Admin'),
    ]

    email        = models.EmailField(unique=True)
    full_name    = models.CharField(max_length=100)
    phone        = models.CharField(max_length=15, blank=True)
    role         = models.CharField(max_length=20, choices=ROLE_CHOICES, default='customer')
    profile_pic  = models.ImageField(upload_to='profiles/', blank=True, null=True)
    is_active    = models.BooleanField(default=True)
    is_staff     = models.BooleanField(default=False)
    created_at   = models.DateTimeField(auto_now_add=True)

    # Use email as the login field instead of username
    USERNAME_FIELD  = 'email'
    REQUIRED_FIELDS = ['full_name']

    objects = UserManager()

    def __str__(self):
        return f"{self.full_name} ({self.role})"
