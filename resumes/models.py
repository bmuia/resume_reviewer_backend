from django.db import models

class UploadFile(models.Model):
    file = models.FileField(upload_to='files/')
    job_description = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f'File uploaded at {self.created_at}, filename: {self.file.name}'
