from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('providers', '0003_add_provider_image'),
    ]

    operations = [
        migrations.AddField(
            model_name='provider',
            name='service_pricing',
            field=models.JSONField(blank=True, default=list),
        ),
    ]
