import uuid
from django.utils import timezone
from rest_framework import status, generics
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

from .models import Payment
from .serializers import PaymentCreateSerializer, PaymentSerializer


class PaymentCreateView(APIView):
    """
    POST /api/payments/pay/
    Customer initiates a mock payment.
    In production: call Easypaisa/JazzCash API here.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = PaymentCreateSerializer(
            data=request.data,
            context={'request': request}
        )
        if serializer.is_valid():
            payment = serializer.save(customer=request.user)

            # ── MOCK PAYMENT PROCESSING ──────────────────────
            # In real life: call payment gateway API here
            # For now: auto-approve and generate fake transaction ID
            payment.status         = 'paid'
            payment.transaction_id = f"LG-{uuid.uuid4().hex[:10].upper()}"
            payment.paid_at        = timezone.now()
            payment.save()
            # ─────────────────────────────────────────────────

            return Response({
                'message':        'Payment successful! (Mock)',
                'transaction_id': payment.transaction_id,
                'payment':        PaymentSerializer(payment).data,
            }, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class PaymentDetailView(generics.RetrieveAPIView):
    """
    GET /api/payments/<booking_id>/
    Check payment status for a booking.
    """
    permission_classes = [IsAuthenticated]
    serializer_class   = PaymentSerializer

    def get_object(self):
        from django.shortcuts import get_object_or_404
        return get_object_or_404(
            Payment,
            booking_id=self.kwargs['booking_id'],
            customer=self.request.user
        )


class MyPaymentsView(generics.ListAPIView):
    """
    GET /api/payments/my-payments/
    All payments made by logged-in customer.
    """
    permission_classes = [IsAuthenticated]
    serializer_class   = PaymentSerializer

    def get_queryset(self):
        return Payment.objects.filter(customer=self.request.user)