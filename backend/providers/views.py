import re

from rest_framework import status, viewsets, serializers
from rest_framework.decorators import action
from rest_framework.response import Response
from django.contrib.auth import get_user_model
from django.db import transaction

from .models import Provider, ProviderCertificate
from .serializers import ProviderCertificateSerializer, ProviderSerializer
from bookings.models import ServiceCategory


def _parse_skills(raw_skills):
    if raw_skills is None:
        return []
    if isinstance(raw_skills, (list, tuple)):
        items = raw_skills
    else:
        items = re.split(r'[,;/\n]+', str(raw_skills))

    skills = []
    seen = set()
    for item in items:
        name = ' '.join(str(item).split()).strip()
        if not name:
            continue
        key = name.lower()
        if key in seen:
            continue
        seen.add(key)
        skills.append(name)
    return skills


def _ensure_service_categories(skills_value):
    for name in _parse_skills(skills_value):
        if ServiceCategory.objects.filter(name__iexact=name).exists():
            continue
        ServiceCategory.objects.create(name=name)


class ProviderViewSet(viewsets.ModelViewSet):
    queryset = Provider.objects.all()
    serializer_class = ProviderSerializer

    @transaction.atomic
    def perform_create(self, serializer):
        instance = serializer.save()
        _ensure_service_categories(instance.skills)

    @transaction.atomic
    def perform_update(self, serializer):
        instance = self.get_object()
        old_email = (instance.email or '').strip()
        instance = serializer.save()
        _ensure_service_categories(instance.skills)

        new_email = (instance.email or '').strip()
        new_name = (instance.name or '').strip()
        new_phone = (instance.phone or '').strip()

        if not (old_email or new_email):
            return

        User = get_user_model()
        user = None

        if old_email:
            user = User.objects.filter(email__iexact=old_email).first()
        if user is None and new_email:
            user = User.objects.filter(email__iexact=new_email).first()

        if not user:
            return

        if new_email and user.email.lower() != new_email.lower():
            if User.objects.exclude(pk=user.pk).filter(
                email__iexact=new_email,
            ).exists():
                raise serializers.ValidationError(
                    {'email': 'Email already exists.'}
                )
            user.email = new_email

        if new_name:
            user.full_name = new_name
        if new_phone:
            user.phone = new_phone

        user.save()

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
