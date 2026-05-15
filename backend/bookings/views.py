from rest_framework import status, generics
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.shortcuts import get_object_or_404

from .models import Booking, ServiceCategory
from .serializers import (
    BookingSerializer,
    BookingCreateSerializer,
    BookingStatusUpdateSerializer,
    ServiceCategorySerializer,
)


class ServiceCategoryListView(generics.ListAPIView):
    """
    GET /api/bookings/categories/
    Public — Flutter uses this to show service options (no login needed).
    """
    queryset = ServiceCategory.objects.all()
    serializer_class = ServiceCategorySerializer
    permission_classes = [AllowAny]


class BookingCreateView(APIView):
    """
    POST /api/bookings/create/
    Customer creates a new booking.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        if request.user.role != 'customer':
            return Response(
                {'error': 'Only customers can create bookings.'},
                status=status.HTTP_403_FORBIDDEN
            )

        serializer = BookingCreateSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            booking = serializer.save()
            return Response({
                'message': 'Booking created successfully!',
                'booking': BookingSerializer(booking).data,
            }, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class MyBookingsView(generics.ListAPIView):
    """
    GET /api/bookings/my-bookings/
    Returns bookings for the logged-in user.
    - Customer → sees bookings they made
    - Provider → sees bookings assigned to them
    """
    permission_classes = [IsAuthenticated]
    serializer_class = BookingSerializer

    def get_queryset(self):
        user = self.request.user
        if user.role == 'customer':
            return Booking.objects.filter(customer=user)
        elif user.role == 'provider':
            return Booking.objects.filter(provider=user)
        return Booking.objects.none()


class BookingDetailView(generics.RetrieveAPIView):
    """
    GET /api/bookings/<id>/
    View details of a single booking.
    Only the customer or provider involved can view it.
    """
    permission_classes = [IsAuthenticated]
    serializer_class = BookingSerializer

    def get_object(self):
        booking = get_object_or_404(Booking, id=self.kwargs['pk'])
        user = self.request.user
        if user != booking.customer and user != booking.provider:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied("You don't have access to this booking.")
        return booking


class BookingStatusUpdateView(APIView):
    """
    PATCH /api/bookings/<id>/update/
    Provider updates booking status.
    """
    permission_classes = [IsAuthenticated]

    VALID_TRANSITIONS = {
        'pending':     ['accepted', 'cancelled'],
        'accepted':    ['in_progress', 'cancelled'],
        'in_progress': ['completed', 'cancelled'],
        'completed':   [],
        'cancelled':   [],
    }

    def patch(self, request, pk):   # <-- must be indented inside the class
        booking = get_object_or_404(Booking, id=pk)
        new_status = request.data.get('status')

        if new_status == 'completed':
            if request.user != booking.customer:
                return Response(
                    {'error': 'Only the customer can mark a job as completed.'},
                    status=status.HTTP_403_FORBIDDEN
                )
        else:
            if request.user != booking.provider:
                return Response(
                    {'error': 'Only the assigned provider can update this booking.'},
                    status=status.HTTP_403_FORBIDDEN
                )

        allowed = self.VALID_TRANSITIONS.get(booking.status, [])
        if new_status not in allowed:
            return Response(
                {
                    'error': f'Cannot change status from "{booking.status}" to "{new_status}".',
                    'allowed_next': allowed,
                },
                status=status.HTTP_400_BAD_REQUEST
            )

        booking.status = new_status
        booking.save()

# ── UPDATE PROVIDER JOBS COUNT ──
        if new_status == 'completed' and booking.provider:
            try:
                from providers.models import Provider
                from bookings.models import Booking
                provider = Provider.objects.filter(
                    email__iexact=booking.provider.email
                ).first()
                if provider:
                    provider.jobs_completed = Booking.objects.filter(
                        provider=booking.provider,
                        status='completed'
                    ).count()
                    provider.save()
            except Exception as e:
                print(f'Jobs update error: {e}')
# ── END UPDATE ──

        return Response({
            'message': f'Booking status updated to "{new_status}".',
            'booking': BookingSerializer(booking).data,
        })