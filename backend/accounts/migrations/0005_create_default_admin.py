from django.contrib.auth.hashers import make_password
from django.db import migrations


def create_default_admin(apps, schema_editor):
    User = apps.get_model('accounts', 'User')
    email = 'admin@labourgo.test'
    if not User.objects.filter(email=email).exists():
        user = User(
            email=email,
            full_name='LabourGo Admin',
            phone='0000000000',
            is_active=True,
            is_staff=True,
            is_superuser=True,
            role='admin',
            password=make_password('Admin123!'),
        )
        user.save(using=schema_editor.connection.alias)


def remove_default_admin(apps, schema_editor):
    User = apps.get_model('accounts', 'User')
    User.objects.filter(email='admin@labourgo.test').delete()


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0004_add_social_ids'),
    ]

    operations = [
        migrations.RunPython(create_default_admin, remove_default_admin),
    ]
