from django.contrib import admin
from .models import Review

@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display  = ['id', 'customer', 'provider', 'rating', 'created_at']
    list_filter   = ['rating']
    search_fields = ['customer__email', 'provider__email']