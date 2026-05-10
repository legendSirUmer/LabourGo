from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ProviderViewSet

router = DefaultRouter()
router.register(r'providers', ProviderViewSet)

urlpatterns = [
    path('', include(router.urls)),
]