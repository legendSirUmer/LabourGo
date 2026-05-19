from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q
from .models import Message, ChatRoom
from .serializers import MessageSerializer, ChatRoomSerializer
from bookings.models import Booking


class MessageViewSet(viewsets.ModelViewSet):
    """
    API endpoints for messages.
    """
    serializer_class = MessageSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        """Return messages for bookings user is involved in"""
        return Message.objects.filter(
            Q(sender=self.request.user) | Q(receiver=self.request.user)
        ).order_by('-created_at')

    @action(detail=False, methods=['get'])
    def by_booking(self, request):
        """Get all messages for a specific booking"""
        booking_id = request.query_params.get('booking_id')
        if not booking_id:
            return Response(
                {'error': 'booking_id parameter is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            booking = Booking.objects.get(id=booking_id)
            # Verify user is part of booking
            if booking.customer != request.user and booking.provider != request.user:
                return Response(
                    {'error': 'You do not have access to this booking'},
                    status=status.HTTP_403_FORBIDDEN
                )

            messages = booking.messages.all()
            serializer = self.get_serializer(messages, many=True)
            return Response(serializer.data)
        except Booking.DoesNotExist:
            return Response(
                {'error': 'Booking not found'},
                status=status.HTTP_404_NOT_FOUND
            )

    @action(detail=False, methods=['post'])
    def mark_as_read(self, request):
        """Mark messages as read"""
        booking_id = request.data.get('booking_id')
        if not booking_id:
            return Response(
                {'error': 'booking_id is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            booking = Booking.objects.get(id=booking_id)
            # Mark all messages to this user as read
            Message.objects.filter(
                booking=booking,
                receiver=request.user,
                is_read=False
            ).update(is_read=True)

            return Response({'status': 'messages marked as read'})
        except Booking.DoesNotExist:
            return Response(
                {'error': 'Booking not found'},
                status=status.HTTP_404_NOT_FOUND
            )

    def create(self, request):
        """Create a new message"""
        booking_id = request.data.get('booking')
        content = request.data.get('content', '').strip()

        if not booking_id or not content:
            return Response(
                {'error': 'booking and content are required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            booking = Booking.objects.get(id=booking_id)
            
            # Verify user is part of booking
            if booking.customer != request.user and booking.provider != request.user:
                return Response(
                    {'error': 'You do not have access to this booking'},
                    status=status.HTTP_403_FORBIDDEN
                )

            # Determine receiver
            receiver = booking.provider if booking.customer == request.user else booking.customer

            # Create message
            message = Message.objects.create(
                booking=booking,
                sender=request.user,
                receiver=receiver,
                content=content
            )

            serializer = self.get_serializer(message)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        except Booking.DoesNotExist:
            return Response(
                {'error': 'Booking not found'},
                status=status.HTTP_404_NOT_FOUND
            )


class ChatRoomViewSet(viewsets.ReadOnlyModelViewSet):
    """
    API endpoints for chat rooms (conversations).
    """
    serializer_class = ChatRoomSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        """Return chat rooms user is involved in"""
        return ChatRoom.objects.filter(
            Q(customer=self.request.user) | Q(provider=self.request.user)
        ).order_by('-updated_at')

    @action(detail=False, methods=['get'])
    def my_chats(self, request):
        """Get all chat rooms for current user"""
        chat_rooms = self.get_queryset()
        serializer = self.get_serializer(chat_rooms, many=True, context={'request': request})
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def active_bookings(self, request):
        """Get chat rooms for active bookings only"""
        active_statuses = ['pending', 'accepted', 'in_progress']
        chat_rooms = self.get_queryset().filter(
            booking__status__in=active_statuses
        )
        serializer = self.get_serializer(chat_rooms, many=True, context={'request': request})
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def unread_count(self, request):
        """Get total unread message count"""
        unread_count = Message.objects.filter(
            receiver=request.user,
            is_read=False
        ).count()
        return Response({'unread_count': unread_count})
