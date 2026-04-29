from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/',        admin.site.urls),
    path('api/auth/',     include('accounts.urls')),
    path('api/bookings/', include('bookings.urls')),
    path('api/reviews/',  include('reviews.urls')),
    path('api/payments/', include('payments.urls')),
    path('api/', include('providers.urls')),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)