# دليل النشر (Deployment Guide)

هذا الدليل يوضح كيفية نشر تطبيق PowerFlow Portal في بيئة الإنتاج (Production).

## 📦 بناء التطبيق (Build)

### 1. بناء الواجهة الخلفية (Backend)
TypeScript يحتاج إلى تحويل (Transpile) إلى JavaScript قبل التشغيل في الإنتاج.

```bash
cd backend
npm install
npm run build
```
سيتم إنشاء مجلد `dist` يحتوي على ملفات JavaScript الجاهزة للتشغيل.

### 2. بناء الواجهة الأمامية (Frontend)
React يحتاج إلى بناء حزمة (Bundle) من الملفات الثابتة.

```bash
cd frontend
npm install
npm run build
```
سيتم إنشاء مجلد `build` يحتوي على ملفات HTML, CSS, JS.

---

## 🚀 التشغيل في الإنتاج (Production Run)

### 1. تشغيل الـ Backend
استخدم مدير عمليات مثل **PM2** لضمان بقاء التطبيق قيد التشغيل وإعادة تشغيله عند الأخطاء.

```bash
# تثبيت PM2 عالمياً
npm install -g pm2

# تشغيل التطبيق
cd backend
pm2 start dist/server.js --name "powerflow-api"
```

**متغيرات البيئة للإنتاج:**
تأكد من ضبط ملف `.env` بقيم الإنتاج:
- `NODE_ENV=production`
- `DB_HOST`: عنوان خادم قاعدة البيانات الحقيقي.
- `JWT_SECRET`: مفتاح طويل ومعقد جداً.

### 2. تشغيل الـ Frontend
يتم تقديم ملفات الـ Frontend كملفات ثابتة (Static Files). يمكنك استخدام **Nginx** أو **Apache** أو حتى تقديمها من خلال الـ Backend نفسه (غير مفضل للأداء العالي).

**مثال لإعداد Nginx:**
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        root /path/to/powerflow-portal/frontend/build;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://localhost:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

---

## 🛡️ قائمة التحقق قبل النشر (Pre-deployment Checklist)
- [ ] تغيير جميع كلمات المرور الافتراضية.
- [ ] التأكد من أن `NODE_ENV=production`.
- [ ] تفعيل HTTPS (SSL Certificate) باستخدام Certbot أو غيره.
- [ ] إعداد جدار الحماية (Firewall) للسماح فقط بالمنافذ الضرورية (80, 443).
- [ ] أخذ نسخة احتياطية (Backup) لقاعدة البيانات.
