from django.urls import path
from .views import PaymentCreateView, PaymentDetailView, MyPaymentsView

urlpatterns = [
    path('pay/',                        PaymentCreateView.as_view(), name='payment-create'),
    path('booking/<int:booking_id>/',   PaymentDetailView.as_view(), name='payment-detail'),
    path('my-payments/',                MyPaymentsView.as_view(),    name='my-payments'),
]