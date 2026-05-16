from django.urls import path
from .views import ReviewCreateView, ProviderReviewsView, MyReviewsView

urlpatterns = [
    path('create/',                    ReviewCreateView.as_view(),    name='review-create'),
    path('provider/<int:provider_id>/', ProviderReviewsView.as_view(), name='provider-reviews'),
    path('my-reviews/',                MyReviewsView.as_view(),       name='my-reviews'),
]