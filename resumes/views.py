import re
import json
from rest_framework import generics, status
from rest_framework.response import Response
from django.conf import settings
from .serializers import UploadSerializer
import google.generativeai as genai
from openai import OpenAI
from .utils import extract_text_from_pdf

class UploadResumeView(generics.CreateAPIView):
    serializer_class = UploadSerializer

    def post(self, request, *args, **kwargs):
        file = request.data.get("file")
        job_description = request.data.get("job_description", "")

        if not file:
            return Response({"error": "No file provided."}, status=status.HTTP_400_BAD_REQUEST)

        if file.name.endswith('pdf'):
            resume_text = extract_text_from_pdf(file)
        else:
            resume_text = file.read().decode("utf-8")

        prompt = f"""
You are a professional resume reviewer. Analyze the following resume and return the result in valid JSON with three keys:
- "strengths": a list of strengths
- "weaknesses": a list of weaknesses
- "improvements": a list of actionable suggestions
{f"Compare it with this job posting: {job_description}" if job_description else ""}
Resume:
{resume_text}
Respond only with JSON.
"""

        ai_choice = settings.AI_PROVIDER.lower()

        try:
            if ai_choice == "gemini":
                genai.configure(api_key=settings.GEMINI_API_KEY)
                model = genai.GenerativeModel("gemini-2.0-flash")
                response = model.generate_content(prompt)
                raw_feedback = response.text

            elif ai_choice == "chatgpt":
                client = OpenAI(api_key=settings.OPENAI_API_KEY)
                completion = client.chat.completions.create(
                    model="gpt-3.5-turbo",
                    messages=[
                        {"role": "system", "content": "You are a career advisor"},
                        {"role": "user", "content": prompt}
                    ]
                )
                raw_feedback = completion.choices[0].message.content

            else:
                return Response({"error": "Invalid AI provider configured."}, status=status.HTTP_400_BAD_REQUEST)

            # Strip code block formatting if present
            cleaned_feedback = re.sub(r"^```(?:json)?\s*|\s*```$", "", raw_feedback.strip(), flags=re.MULTILINE)

            try:
                structured_feedback = json.loads(cleaned_feedback)
            except json.JSONDecodeError:
                return Response({"error": "AI response was not valid JSON", "raw": raw_feedback}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

            return Response({"feedback": structured_feedback}, status=status.HTTP_200_OK)

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
