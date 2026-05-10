from rest_framework import serializers
from django.contrib.auth import get_user_model

User = get_user_model()


class RegisterSerializer(serializers.ModelSerializer):
    """Handles new user registration."""

    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model  = User
        fields = ['email', 'full_name', 'phone', 'role', 'password']

    def create(self, validated_data):
        # create_user automatically hashes the password
        user = User.objects.create_user(**validated_data)
        return user


class UserProfileSerializer(serializers.ModelSerializer):
    """Returns user profile info (no password)."""

    class Meta:
        model  = User
        fields = ['id', 'email', 'full_name', 'phone', 'role', 'profile_pic', 'created_at']
        read_only_fields = ['id', 'email', 'created_at']