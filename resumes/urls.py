from django.urls import path
from .views import UploadResumeView

urlpatterns = [
    path('resume-review/',UploadResumeView.as_view(), name='resume-reviewer')
]
