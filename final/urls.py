# final/urls.py

from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('vfit.urls')),
]

# ส่วนนี้จะทำงานเฉพาะตอน DEBUG=True เพื่อเสิร์ฟไฟล์ media
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)