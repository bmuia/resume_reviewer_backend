from django.urls import path
from .views import Welcome

urlpatterns = [
    path('', Welcome.as_view(), name='welcome'),
]