import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
from .models import Message, ChatRoom
from bookings.models import Booking

User = get_user_model()


class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        """Handle WebSocket connection"""
        self.booking_id = self.scope['url_route']['kwargs']['booking_id']
        self.user = self.scope['user']
        self.room_group_name = f'booking_{self.booking_id}'

        # Verify user is part of this booking
        is_valid = await self.verify_booking_access()
        if not is_valid:
            await self.close()
            return

        # Join room group
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )

        await self.accept()

    async def disconnect(self, close_code):
        """Handle WebSocket disconnection"""
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )

    async def receive(self, text_data):
        """Handle incoming message from WebSocket"""
        try:
            data = json.loads(text_data)
            message_content = data.get('message', '').strip()

            if not message_content:
                return

            # Get receiver
            booking = await self.get_booking()
            if booking.customer.id == self.user.id:
                receiver = booking.provider
            else:
                receiver = booking.customer

            # Save message to database
            message = await self.save_message(
                booking=booking,
                sender=self.user,
                receiver=receiver,
                content=message_content
            )

            # Broadcast message to room
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'chat_message',
                    'message_id': message.id,
                    'sender_id': self.user.id,
                    'sender_name': self.user.full_name,
                    'sender_avatar': self.user.profile_pic.url if self.user.profile_pic else None,
                    'receiver_id': receiver.id,
                    'content': message_content,
                    'created_at': message.created_at.isoformat(),
                    'is_read': False,
                }
            )
        except json.JSONDecodeError:
            pass

    async def chat_message(self, event):
        """Broadcast message to WebSocket"""
        await self.send(text_data=json.dumps({
            'type': 'message',
            'message_id': event['message_id'],
            'sender_id': event['sender_id'],
            'sender_name': event['sender_name'],
            'sender_avatar': event['sender_avatar'],
            'receiver_id': event['receiver_id'],
            'content': event['content'],
            'created_at': event['created_at'],
            'is_read': event['is_read'],
        }))

    async def user_online(self, event):
        """Notify user is online"""
        await self.send(text_data=json.dumps({
            'type': 'user_online',
            'user_id': event['user_id'],
            'user_name': event['user_name'],
        }))

    @database_sync_to_async
    def verify_booking_access(self):
        """Verify user is part of the booking"""
        try:
            booking = Booking.objects.get(id=self.booking_id)
            return (booking.customer.id == self.user.id or 
                    booking.provider.id == self.user.id)
        except Booking.DoesNotExist:
            return False

    @database_sync_to_async
    def get_booking(self):
        """Get booking instance"""
        return Booking.objects.select_related(
        'customer',
        'provider'
    ).get(id=self.booking_id)

    @database_sync_to_async
    def save_message(self, booking, sender, receiver, content):
        """Save message to database"""
        return Message.objects.create(
            booking=booking,
            sender=sender,
            receiver=receiver,
            content=content
        )
