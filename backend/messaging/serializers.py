from rest_framework import serializers
from .models import Message, ChatRoom
from accounts.models import User


class UserMinimalSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'full_name',  'profile_pic']


class MessageSerializer(serializers.ModelSerializer):
    sender_details = UserMinimalSerializer(source='sender', read_only=True)
    receiver_details = UserMinimalSerializer(source='receiver', read_only=True)

    class Meta:
        model = Message
        fields = [
            'id',
            'booking',
            'sender',
            'sender_details',
            'receiver',
            'receiver_details',
            'content',
            'is_read',
            'created_at',
            'updated_at'
        ]
        read_only_fields = ['id', 'sender', 'created_at', 'updated_at']


class ChatRoomSerializer(serializers.ModelSerializer):
    customer_details = UserMinimalSerializer(source='customer', read_only=True)
    provider_details = UserMinimalSerializer(source='provider', read_only=True)
    last_message = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()

    class Meta:
        model = ChatRoom
        fields = [
            'id',
            'booking',
            'customer',
            'customer_details',
            'provider',
            'provider_details',
            'last_message',
            'unread_count',
            'created_at',
            'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def get_last_message(self, obj):
        last_message = obj.booking.messages.first()
        if last_message:
            return MessageSerializer(last_message).data
        return None

    def get_unread_count(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.booking.messages.filter(
                receiver=request.user,
                is_read=False
            ).count()
        return 0
