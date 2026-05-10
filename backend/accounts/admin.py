from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User

@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display   = ['id', 'email', 'full_name', 'role', 'is_active']
    list_filter    = ['role', 'is_active']
    search_fields  = ['email', 'full_name']
    ordering       = ['id']

    fieldsets = (
        (None,           {'fields': ('email', 'password')}),
        ('Personal',     {'fields': ('full_name', 'phone', 'role', 'profile_pic')}),
        ('Permissions',  {'fields': ('is_active', 'is_staff', 'is_superuser')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields':  ('email', 'full_name', 'role', 'password1', 'password2'),
        }),
    )