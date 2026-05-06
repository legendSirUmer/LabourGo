from rest_framework import serializers
from .models import Provider, ProviderCertificate

class ProviderCertificateSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProviderCertificate
        fields = [
            'id',
            'provider',
            'skill',
            'certificate_number',
            'issuing_authority',
            'issue_date',
            'expiration_date',
            'image',
            'status',
            'verified',
            'created_at',
        ]
        read_only_fields = ['id', 'status', 'verified', 'created_at']


class ProviderSerializer(serializers.ModelSerializer):
    certificates = ProviderCertificateSerializer(many=True, read_only=True)

    class Meta:
        model = Provider
        fields = '__all__'
