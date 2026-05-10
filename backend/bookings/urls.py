from django.urls import path
from .views import (
    ServiceCategoryListView,
    BookingCreateView,
    MyBookingsView,
    BookingDetailView,
    BookingStatusUpdateView,
)

urlpatterns = [
    path('categories/',      ServiceCategoryListView.as_view(),  name='categories'),
    path('create/',          BookingCreateView.as_view(),        name='booking-create'),
    path('my-bookings/',     MyBookingsView.as_view(),           name='my-bookings'),
    path('<int:pk>/',        BookingDetailView.as_view(),        name='booking-detail'),
    path('<int:pk>/update/', BookingStatusUpdateView.as_view(),  name='booking-update'),
]
