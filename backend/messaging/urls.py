from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import MessageViewSet, ChatRoomViewSet

router = DefaultRouter()
router.register(r'messages', MessageViewSet, basename='message')
router.register(r'chat-rooms', ChatRoomViewSet, basename='chat-room')

urlpatterns = [
    path('', include(router.urls)),
]
