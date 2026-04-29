from rest_framework import viewsets
from .models import Provider
from .serializers import ProviderSerializer


class ProviderViewSet(viewsets.ModelViewSet):
    queryset = Provider.objects.all()
    serializer_class = ProviderSerializer