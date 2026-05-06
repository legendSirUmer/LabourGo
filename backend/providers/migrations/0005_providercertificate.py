from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('providers', '0004_provider_service_pricing'),
    ]

    operations = [
        migrations.CreateModel(
            name='ProviderCertificate',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('skill', models.CharField(max_length=100)),
                ('certificate_number', models.CharField(max_length=100)),
                ('issuing_authority', models.CharField(max_length=150)),
                ('issue_date', models.DateField()),
                ('expiration_date', models.DateField()),
                ('image', models.ImageField(upload_to='certificates/')),
                ('status', models.CharField(choices=[('pending', 'Pending'), ('approved', 'Approved'), ('rejected', 'Rejected')], default='pending', max_length=10)),
                ('verified', models.BooleanField(default=False)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('provider', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='certificates', to='providers.provider')),
            ],
            options={
                'ordering': ['-created_at'],
            },
        ),
    ]
