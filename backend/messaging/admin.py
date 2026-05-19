from django.contrib import admin
from .models import Message, ChatRoom


@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display = ['id', 'sender', 'receiver', 'booking', 'is_read', 'created_at']
    list_filter = ['is_read', 'created_at']
    search_fields = ['sender__full_name', 'receiver__full_name', 'content']
    readonly_fields = ['created_at', 'updated_at']


@admin.register(ChatRoom)
class ChatRoomAdmin(admin.ModelAdmin):
    list_display = ['id', 'booking', 'customer', 'provider', 'created_at']
    list_filter = ['created_at']
    search_fields = ['customer__full_name', 'provider__full_name']
    readonly_fields = ['created_at', 'updated_at']
