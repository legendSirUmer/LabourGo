from django.urls import path
from .views import RegisterView, LoginView, ProfileView, LogoutView, ProviderListView, SocialLoginView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/',    LoginView.as_view(),    name='login'),
    path('social-login/', SocialLoginView.as_view(), name='social-login'),
    path('profile/',  ProfileView.as_view(),  name='profile'),
    path('logout/',   LogoutView.as_view(),   name='logout'),
    path('providers/', ProviderListView.as_view(), name='providers'),
]
