from django.contrib.auth import get_user_model

User = get_user_model()

if not User.objects.filter(email="umer@gmail.com").exists():
    User.objects.create_superuser(
        email="umer@gmail.com",
        full_name="Umer",
        password="123456"
    )