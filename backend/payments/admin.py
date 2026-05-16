from django.contrib import admin
from .models import Payment

@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    list_display  = ['id', 'customer', 'amount', 'method', 'status', 'transaction_id']
    list_filter   = ['status', 'method']
    search_fields = ['customer__email', 'transaction_id']