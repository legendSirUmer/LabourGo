from django.contrib import admin
from django.utils.html import format_html

from .models import Provider, ProviderCertificate


class ProviderCertificateInline(admin.TabularInline):
	model = ProviderCertificate
	extra = 0
	readonly_fields = ('status', 'verified', 'created_at')
	fields = (
		'skill',
		'certificate_number',
		'issuing_authority',
		'issue_date',
		'expiration_date',
		'image',
		'status',
		'verified',
		'created_at',
	)


@admin.register(Provider)
class ProviderAdmin(admin.ModelAdmin):
	list_display = (
		'image_preview',
		'name',
		'email',
		'phone',
		'skills',
		'verification_status',
	)
	search_fields = ('name', 'email', 'phone')
	readonly_fields = ('image_preview',)
	inlines = (ProviderCertificateInline,)

	def image_preview(self, obj):
		if obj.image and getattr(obj.image, 'url', None):
			return format_html(
				'<img src="{}" style="height: 40px; width: 40px; object-fit: cover; border-radius: 4px;" />',
				obj.image.url,
			)
		return 'No image'

	image_preview.short_description = 'Image'


@admin.register(ProviderCertificate)
class ProviderCertificateAdmin(admin.ModelAdmin):
	list_display = (
		'provider',
		'skill',
		'certificate_number',
		'issuing_authority',
		'status',
		'verified',
	)
	search_fields = (
		'provider__name',
		'skill',
		'certificate_number',
		'issuing_authority',
	)
	list_filter = ('status', 'verified')
