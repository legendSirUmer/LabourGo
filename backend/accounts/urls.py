from django.urls import path
from .views import (
    RegisterView,
    TwoFactorSetupView,
    TwoFactorEmailLoginView,
    ResetPasswordByContactView,
    LoginView,
    VerifyTwoFactorLoginView,
    ProfileView,
    LogoutView,
    ProviderListView,
    SocialLoginView,
)
from .admin_views import (
    AdminUserListView,
    AdminUserToggleView, 
    AdminStatsView
)


urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('2fa/setup/', TwoFactorSetupView.as_view(), name='2fa-setup'),
    path('2fa/login/', TwoFactorEmailLoginView.as_view(), name='2fa-login'),
    path('password-reset/by-contact/', ResetPasswordByContactView.as_view(), name='password-reset-by-contact'),
    path('login/',    LoginView.as_view(),    name='login'),
    path('login/2fa/verify/', VerifyTwoFactorLoginView.as_view(), name='login-2fa-verify'),
    path('social-login/', SocialLoginView.as_view(), name='social-login'),
    path('profile/',  ProfileView.as_view(),  name='profile'),
    path('logout/',   LogoutView.as_view(),   name='logout'),
    path('providers/', ProviderListView.as_view(), name='providers'),
    path('admin/users/',  AdminUserListView.as_view(), name='admin-users'),
    path('admin/users/<int:pk>/toggle/', AdminUserToggleView.as_view(), name='admin-toggle'),
    path('admin/stats/',  AdminStatsView.as_view(),    name='admin-stats'),
]




