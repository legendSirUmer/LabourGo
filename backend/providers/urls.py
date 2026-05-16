from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ProviderViewSet
from .admin_views import AdminProviderListView, AdminProviderStatusView

router = DefaultRouter()
router.register(r'providers', ProviderViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('providers/admin/list/', AdminProviderListView.as_view(), name='admin-provider-list'),
    path('providers/admin/<int:pk>/status/', AdminProviderStatusView.as_view(), name='admin-provider-status'),
]