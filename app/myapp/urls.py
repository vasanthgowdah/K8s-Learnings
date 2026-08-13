from django.contrib import admin
from django.urls import path
from django.http import JsonResponse

def health_check(request):
    return JsonResponse({'status': 'healthy'})

def index(request):
    return JsonResponse({
        'message': 'Welcome to Django on EKS!',
        'version': '1.0.0'
    })

urlpatterns = [
    path('admin/', admin.site.urls),
    path('health/', health_check, name='health'),
    path('', index, name='index'),
]
