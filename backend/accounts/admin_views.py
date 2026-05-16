from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAdminUser
from django.db.models import Sum
from django.contrib.auth import get_user_model

User = get_user_model()


class AdminUserListView(APIView):
    permission_classes = [IsAdminUser]

    def get(self, request):
        users = User.objects.filter(role='customer').order_by('-created_at')
        data = []
        for u in users:
            data.append({
                'id':        u.id,
                'full_name': u.full_name,
                'email':     u.email,
                'phone':     u.phone,
                'role':      u.role,
                'is_active': u.is_active,
                'joined_at': u.created_at.isoformat() if hasattr(u, 'created_at') and u.created_at else None,
            })
        return Response(data)


class AdminUserToggleView(APIView):
    permission_classes = [IsAdminUser]

    def patch(self, request, pk):
        try:
            user = User.objects.get(pk=pk)
            user.is_active = not user.is_active
            user.save()
            return Response({'id': user.id, 'is_active': user.is_active})
        except User.DoesNotExist:
            return Response({'error': 'Not found'}, status=404)


class AdminStatsView(APIView):
    permission_classes = [IsAdminUser]

    def get(self, request):
        from providers.models import Provider
        try:
            from bookings.models import Booking
            total_bookings    = Booking.objects.count()
            completed         = Booking.objects.filter(status='completed').count()
        except Exception:
            total_bookings = completed = 0

        try:
            from payments.models import Payment
            revenue = Payment.objects.filter(
                status='paid'
            ).aggregate(t=Sum('amount'))['t'] or 0
        except Exception:
            revenue = 0

        return Response({
            'total_providers':    Provider.objects.count(),
            'active_users':       User.objects.filter(role='customer', is_active=True).count(),
            'total_users':        User.objects.filter(role='customer').count(),
            'pending_providers':  Provider.objects.filter(verification_status='pending').count(),
            'total_bookings':     total_bookings,
            'completed_bookings': completed,
            'total_revenue':      float(revenue),
        })