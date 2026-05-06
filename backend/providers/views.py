from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import Provider, ProviderCertificate
from .serializers import ProviderCertificateSerializer, ProviderSerializer


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

    @action(detail=False, methods=['get'])
    def cities(self, request):
        cities = [
            {'label': 'Karachi', 'tag': 'Sindh'},
            {'label': 'Lahore', 'tag': 'Punjab'},
            {'label': 'Islamabad', 'tag': 'Capital'},
            {'label': 'Rawalpindi', 'tag': 'Punjab'},
            {'label': 'Faisalabad', 'tag': 'Punjab'},
            {'label': 'Multan', 'tag': 'Punjab'},
            {'label': 'Peshawar', 'tag': 'KPK'},
            {'label': 'Quetta', 'tag': 'Balochistan'},
        ]
        return Response(cities)

    @action(detail=True, methods=['get', 'post'], url_path='certificates')
    def certificates(self, request, pk=None):
        provider = self.get_object()

        if request.method.lower() == 'get':
            queryset = provider.certificates.all()
            serializer = ProviderCertificateSerializer(queryset, many=True)
            return Response(serializer.data)

        data = request.data.copy()
        data['provider'] = provider.id
        serializer = ProviderCertificateSerializer(data=data)
        if serializer.is_valid():
            serializer.save(provider=provider)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(
        detail=True,
        methods=['delete'],
        url_path=r'certificates/(?P<certificate_id>[^/.]+)',
    )
    def delete_certificate(self, request, pk=None, certificate_id=None):
        certificate = ProviderCertificate.objects.filter(
            id=certificate_id,
            provider_id=pk,
        ).first()
        if certificate is None:
            return Response(
                {'error': 'Certificate not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        certificate.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
