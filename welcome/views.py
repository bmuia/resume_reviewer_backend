from django.views import View
from django.http import JsonResponse

class Welcome(View):
    def get(self, request):
        return JsonResponse({
            "status": "success",
            "message": "🚀 Welcome to the AI Resume Analyzer API!",
            "info": "This API helps you analyze, rate, and improve resumes using AI. Ready to optimize your career journey? Let’s go! 💼✨"
        })
