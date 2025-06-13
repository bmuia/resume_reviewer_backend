from rest_framework import serializers
from .models import UploadFile

class UploadSerializer(serializers.ModelSerializer):
    class Meta:
        model = UploadFile
        fields = ['id','file','job_description','created_at','updated_at']
        read_only_fields = ['id','created_at','updated_at']