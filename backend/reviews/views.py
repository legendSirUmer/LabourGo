from rest_framework import generics, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth import get_user_model
from django.db.models import Avg

from .models import Review
from .serializers import ReviewCreateSerializer, ReviewSerializer

User = get_user_model()


class ReviewCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        if request.user.role != 'customer':
            return Response(
                {'error': 'Only customers can submit reviews.'},
                status=status.HTTP_403_FORBIDDEN
            )

        serializer = ReviewCreateSerializer(
            data=request.data,
            context={'request': request}
        )
        if serializer.is_valid():
            review = serializer.save()

            # ── UPDATE PROVIDER RATING ──
            try:
                from providers.models import Provider
                booking = review.booking
                if booking and booking.provider:
                    provider = Provider.objects.filter(
                        email__iexact=booking.provider.email
                    ).first()
                    if provider:
                        avg = Review.objects.filter(
                            booking__provider=booking.provider
                        ).aggregate(Avg('rating'))['rating__avg']
                        provider.rating = round(avg, 2) if avg else 0

                        # also update jobs_completed
                        from bookings.models import Booking
                        provider.jobs_completed = Booking.objects.filter(
                            provider=booking.provider,
                            status='completed'
                        ).count()

                        provider.save()
            except Exception as e:
                print(f'Provider update error: {e}')
            # ── END UPDATE ──

            return Response({
                'message': 'Review submitted successfully!',
                'review':  ReviewSerializer(review).data,
            }, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ProviderReviewsView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class   = ReviewSerializer

    def get_queryset(self):
        return Review.objects.filter(
            provider_id=self.kwargs['provider_id']
        )

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        avg      = queryset.aggregate(avg=Avg('rating'))['avg']

        return Response({
            'provider_id':     self.kwargs['provider_id'],
            'average_rating':  round(avg, 2) if avg else None,
            'total_reviews':   queryset.count(),
            'reviews':         ReviewSerializer(queryset, many=True).data,
        })


class MyReviewsView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class   = ReviewSerializer

    def get_queryset(self):
        return Review.objects.filter(customer=self.request.user)