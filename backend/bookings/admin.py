from django.contrib import admin
from .models import Booking, ServiceCategory


@admin.register(ServiceCategory)
class ServiceCategoryAdmin(admin.ModelAdmin):
    list_display = ['id', 'name']


@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = ['id', 'customer', 'provider', 'category', 'status', 'scheduled_date']
    list_filter = ['status', 'category']
    search_fields = ['customer__email', 'provider__email']
