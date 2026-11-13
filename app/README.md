# Alfaham Tube (Flutter)

تطبيق أندرويد وويب بنفس هوية الموقع، يقرأ من نفس قاعدة Firebase (categories + articles)
دون أي تغيير في البوت أو لوحة التحكم.

## البناء بدون تثبيت أي شيء
1. ارفع المجلد `app/` وملف `.github/workflows/flutter_build.yml` إلى المستودع.
2. GitHub ثم Actions ثم "Build Flutter App" ثم Run workflow.
3. بعد النجاح (حوالي 8 إلى 12 دقيقة) حمّل من أسفل صفحة التشغيل (Artifacts):
   - `alfaham-tube-apk` ← ملف app-release.apk للتثبيت على أندرويد.
   - `alfaham-tube-web` ← ملفات الويب جاهزة للرفع على أي استضافة.

## إعدادات
`lib/config.dart`:
- `firebaseUrl`: رابط قاعدة Firebase (مضبوط على قاعدة الموقع).
- `siteUrl`: رابط موقعك للمشاركة (اتركه فارغًا إن لم تحتجه).
