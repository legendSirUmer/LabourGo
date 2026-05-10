from rest_framework import viewsets
from .models import Provider
from .serializers import ProviderSerializer
from rest_framework.decorators import action
from rest_framework.response import Response


class ProviderViewSet(viewsets.ModelViewSet):
    queryset = Provider.objects.all()
    serializer_class = ProviderSerializer

    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        provider = self.get_object()
        provider.verification_status = 'approved'
        provider.save()
        return Response({"status": "approved"})
    
    @action(detail=True, methods=['get'])
    def performance(self, request, pk=None):
        provider = self.get_object()
        return Response({
            "rating": provider.rating,
            "jobs_completed": provider.jobs_completed
        })
    @action(detail=True, methods=['post'])
    def toggle_availability(self, request, pk=None):
        provider = self.get_object()
        provider.availability = not provider.availability
        provider.save()
        return Response({"availability": provider.availability})