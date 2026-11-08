# خطة تطوير نظام Viatica / فارمجي
### الخطة التفصيلية للمراحل الأربع — مايو 2026

---

## ملخص تنفيذي

هذه الخطة تُفصّل **27 متطلبًا** موزعة على **64 مهمة تقنية** عبر **4 مراحل**، تهدف إلى تحويل نظام Viatica من منصة طلبات B2B إلى نظام إدارة صيدليات متكامل يشمل التأمين الطبي، العمل أوفلاين، وتخصيص بيئة الصيدلية.

| البند | القيمة |
|---|---|
| عدد المراحل | 4 مراحل |
| إجمالي المتطلبات | 27 متطلب تفصيلي |
| إجمالي المهام | 64 مهمة موزعة |
| تقدير التنفيذ | 13 أسبوع |

---

## الجدول الزمني الموحد

| المرحلة | المحور الرئيسي | المدة | المهام |
|---|---|---|---|
| 1 | التأمين الأساسي + حجز المخزون + SMS (أ. 1–4) | أسابيع 1–4 | 8 مهام |
| 2 | الوضع الأوفلاين الكامل + Delta Sync (أ. 5–7) | أسابيع 5–7 | 7 مهام |
| 3 | الصلاحيات + الصيدلية كبيئة مستقلة (أ. 8–11) | أسابيع 8–11 | 7 مهام |
| 4 | الاختبارات + DevOps + الإطلاق (أ. 11–13) | أسابيع 11–13 | 5 مهام |

---

## المرحلة الأولى — الأساس الحرج
**DB + Backend | المدة: 4 أسابيع (1–4) · 8 مهام تفصيلية**

### الأسبوع 1–2: حجز المخزون الكامل

تعديل نموذج `Drug` في MongoDB وبناء خدمة الحجز التي تضمن عدم قبول طلبات تتجاوز الكمية الفعلية المتاحة.

| الرمز | المهمة | التفاصيل | الطبقة / الأولوية |
|---|---|---|---|
| STK-01 | إضافة `reservedQuantity` للدواء | إضافة حقل `reservedQuantity` (default: 0) وـ `virtual field` `availableQuantity = quantity - reservedQuantity`. Migration script يضع الحقل بـ 0 لجميع الأدوية الموجودة. **الملفات:** `models/Drug.js`، `migration/add_reserved_qty.js` | DB + BE / **حرج** |
| STK-02 | حجز المخزون عند التأكيد | عند confirmed: MongoDB Transaction يزيد `reservedQuantity` فورًا. إذا `availableQuantity` < الكمية المطلوبة يُرفض الطلب مع notification للصيدلي. **الملفات:** `services/stockReservation.js`، `controllers/orderController.js` | Backend / **حرج** |
| STK-03 | Cron + تحرير الحجز عند الإلغاء / انتهاء | تخفيض `reservedQuantity` فورًا عند الإلغاء. Cron Job كل ساعة يلغي حجوزات تجاوزت `reservationExpiresAt` ويرسل notification. **الملفات:** `services/stockReservation.js`، `jobs/expireReservations.js` | Backend / **حرج** |
| STK-04 | تحديث واجهة المخزون | عرض 3 أعمدة في `Inventory.tsx`: الإجمالي / المحجوز / المتاح الفعلي. تنبيه المخزون يعتمد على المتاح الفعلي لا الإجمالي. **الملفات:** `pages/Inventory.tsx`، `pages/Alerts.tsx` | FE + Mob / **عالي** |

---

### الأسبوع 3–4: التأمين الأساسي + SMS

ربط SMS provider حقيقي وبناء نماذج التأمين الأساسية مع منطق الفاتورة المختلطة.

| الرمز | المهمة | التفاصيل | الطبقة / الأولوية |
|---|---|---|---|
| SMS-01 | ربط SMS Provider حقيقي | Twilio كـ primary وUnifonic كـ fallback للمنطقة العربية. Mock في Development. OTP يُخزَّن في Redis بـ TTL=5 دقائق. **الملفات:** `services/smsService.js`، `.env` | Backend / **حرج** |
| INS-01 | نماذج `InsuranceCompany` + `InsuranceClaim` | InsuranceCompany: اسم، رقم العقد، قواعد التغطية، API endpoint. InsuranceClaim: رقم المطالبة، الفاتورة، المبالغ، الحالة (submitted/approved/paid/rejected). **الملفات:** `models/InsuranceCompany.js`، `models/InsuranceClaim.js` | DB + BE / **حرج** |
| INS-02 | إضافة `insuranceInfo` لـ User | حقل مركب: `companyId`، `policyNumber`، `coveragePercent`، `coverageType` (individual/family/vip)، `expiresAt`، `isVerified`. **الملفات:** `models/User.js` | DB + BE / **حرج** |
| INS-03 | منطق الفاتورة المختلطة — خدمة `insuranceBillingService` | تحسب حصة المريض وحصة التأمين لكل صنف حسب قواعد الشركة. ثلاث نسخ للفاتورة: مريض، صيدلية، تأمين. **الملفات:** `services/insuranceBillingService.js` | Backend / **حرج** |

---

## المرحلة الثانية — الوضع الأوفلاين الكامل
**Backend + Flutter | المدة: 3 أسابيع (5–7) · 7 مهام تفصيلية**

### الأسبوع 5: قاعدة البيانات المحلية (Hive)

إعداد Hive كقاعدة بيانات محلية في Flutter مع خدمة مراقبة الاتصال وبدء المزامنة التلقائية.

| الرمز | المهمة | التفاصيل | الطبقة / الأولوية |
|---|---|---|---|
| OFF-01 | Hive setup — قاعدة البيانات المحلية | Boxes: `drugsBox` (كتالوج)، `cartBox` (سلة)، `invoicesBox` (فواتير)، `syncQueue` (معلقة)، `metaBox` (lastSync). استخدام `hive_generator` لإنشاء adapters. **الملفات:** `lib/local_db/hive_service.dart`، `models/*_local.dart` | Mobile / **حرج** |
| OFF-02 | `ConnectivityService` — مراقبة الشبكة | يراقب `connectivity_plus` Stream. عند الاتصال يستدعي `SyncService.startSync()` تلقائيًا. `isOnline` متاحة لكل widget. **الملفات:** `lib/services/connectivity_service.dart` | Mobile / **حرج** |
| OFF-03 | `SyncQueueService` — تخزين وإرسال | `SyncQueueItem` يحتوي: uuid، operation، payload، retryCount، status (pending/synced/failed). يُرسَل بالترتيب الزمني. ثلاث محاولات قبل failed. **الملفات:** `lib/services/sync_service.dart` | Mobile / **حرج** |

---

### الأسبوع 6–7: POS أوفلاين + تجربة المستخدم

شاشة POS تعمل بالكامل بلا إنترنت، مع شريط الحالة ونقطة API للمزامنة الدفعية و Delta Sync للكتالوج.

| الرمز | المهمة | التفاصيل | الطبقة / الأولوية |
|---|---|---|---|
| OFF-04 | POS أوفلاين كامل الوظائف | البحث من Hive. رقم فاتورة مؤقت `-LOCAL-{timestamp}`. حفظ في `invoicesBox` + `syncQueueItem`. رسالة "سيُرفع عند الاتصال". **الملفات:** `lib/screens/pos/pos_screen.dart`، `pos_controller.dart` | Mobile / **عالي** |
| OFF-05 | Batch Sync API في Backend | `POST /api/sync/batch` يستقبل مصفوفة عمليات ويعالجها بالترتيب. يرجع: `localId`، `status` (ok/conflict)، أو `serverId` و`reason` في حالة التعارض. **الملفات:** `controllers/syncController.js`، `routes/sync.js` | Backend / **عالي** |
| OFF-06 | شريط حالة الاتصال (OfflineBanner) | أوفلاين: كهرماني + عداد العمليات. يتزامن: دوران. متصل أخضر يختفي بعد 3 ثوانٍ. تعارض: أحمر + رابط للمراجعة. **الملفات:** `lib/widgets/offline_banner.dart` | Mobile / **عالي** |
| OFF-07 | Delta Sync كتالوج الأدوية | `GET /api/drugs?updatedAfter=timestamp` يرجع فقط التغييرات منذ آخر مزامنة. يشمل المحذوف بـ `{deleted: true}`. يقلل حجم البيانات من MB إلى KB. **الملفات:** `controllers/drugController.js`، `lib/services/catalog_sync.dart` | BE + Mob / **متوسط** |

---

## المرحلة الثالثة — الصيدلية كبيئة مستقلة
**Full Stack | المدة: 4 أسابيع (8–11) · 7 مهام تفصيلية**

### الأسبوع 8–9: النماذج وهيكل الصلاحيات

بناء نموذج `Pharmacy` المستقل مع نظام صلاحيات متعدد الأدوار وتوسيع مخزون الصيدلية ونموذج الوصفة الطبية.

| الرمز | المهمة | التفاصيل | الطبقة / الأولوية |
|---|---|---|---|
| PHA-01 | نموذج `Pharmacy` + صلاحيات | نموذج Pharmacy: ترخيص، موظفون، مستودعات مفضلة، عقود تأمين. Roles جديدة: `pharmacy_manager`، `pharmacist_staff`، `cashier`، `patient`. Middleware: `requirePharmacyRole`. **الملفات:** `models/Pharmacy.js`، `middleware/pharmacyAuth.js` | DB + BE / **حرج** |
| PHA-02 | توسيع مخزون الصيدلية مع الدفعات | `PharmacistStock` بـ batches: رقم دفعة، كمية، سعر شراء، انتهاء، `barcode`، `reorderLevel`، `location` داخل الصيدلية. Cron يُنبّه قبل 30 يوم من الانتهاء. **الملفات:** `models/PharmacistStock.js`، `jobs/expiryAlerts.js` | DB + BE / **حرج** |
| PHA-03 | نموذج `Prescription` + CRUD | وصفة طبية رقمية: رقم، صورة Cloudinary، طبيب، أصناف مع `dispensedQty`، الحالة (active/partially/fully/expired)، ربط بتأمين. API: CRUD + صرف + رفع صورة. **الملفات:** `models/Prescription.js`، `controllers/prescriptionController.js` | DB + BE / **عالي** |

---

### الأسبوع 10–11: واجهات الصيدلية

بناء POS الصيدلية للمرضى مع التأمين، داشبورد React المخصص، ومسح باركود بطاقة التأمين.

| الرمز | المهمة | التفاصيل | الطبقة / الأولوية |
|---|---|---|---|
| PHA-04 | POS الصيدلية للمرضى | تدفق كامل: بحث مريض ← وصفاته النشطة ← تعبئة سلة تلقائيًا ← احتساب تقسيم التأمين ← إيصالان (مريض + تأمين) ← تحديث مخزون + وصفة فورًا. **الملفات:** `lib/screens/pharmacy_pos/pharmacy_pos_screen.dart`، `pages/PharmacyPOS.tsx` | FE + Mob / **عالي** |
| PHA-05 | داشبورد الصيدلية المستقل | صفحات React منفصلة: `PharmacyDashboard` (KPIs)، `PharmacyInventory` (دفعات + انتهاء)، `PharmacyPrescriptions`، `PharmacyInsurance`، `PharmacyStaff`، `PharmacyReports`. **الملفات:** `pages/pharmacy/*.tsx` | Frontend / **عالي** |
| INS-06 | مسح بطاقة التأمين (Barcode) | شاشة Flutter بـ `mobile_scanner` تقرأ QR/barcode بطاقة التأمين. `GET /api/insurance/verify?policyNumber=X` يرجع: اسم المريض + نسبة التغطية + تاريخ الانتهاء. **الملفات:** `lib/screens/insurance_scan_screen.dart` | Mobile / **متوسط** |
| INS-07 | قائمة الأدوية المعتمدة (Formulary) | ربط كل دواء بشركات تأمين تغطيه. تصنيف: مغطى كليًا / جزئيًا / غير مغطى. تنبيه تلقائي عند صرف دواء غير مغطى في POS. **الملفات:** `models/Drug.js`، `controllers/insuranceController.js` | DB + BE / **متوسط** |

---

## المرحلة الرابعة — الاكتمال والجودة
**Testing + DevOps | المدة: 3 أسابيع (11–13) · 5 مهام تفصيلية**

| الرمز | المهمة | التفاصيل | الطبقة / الأولوية |
|---|---|---|---|
| TEST-01 | اختبارات Jest للمسارات الحرجة | 5 ملفات: `stockReservation`، `insuranceBilling`، `syncBatch`، `orderLifecycle`، `expiryReservation`. هدف التغطية: 80%+ على Services و Controllers الجديدة. استخدام `mongodb-memory-server`. **الملفات:** `__tests__/*.test.js` | Backend / **عالي** |
| TEST-02 | Widget Tests في Flutter | 4 ملفات: `offline_banner`، `sync_service`، `offline_pos`، `split_insurance`. التحقق من جميع حالات `OfflineBanner` وصحة احتساب التقسيم. **الملفات:** `test/*_test.dart` | Mobile / **متوسط** |
| DEV-01 | Docker Compose + CI/CD | Services: `api`، `redis` (rate limiting + OTP)، `cron` (jobs runner). GitHub Actions: test → build → deploy Render/Vercel → flutter build apk. **الملفات:** `docker-compose.yml`، `.github/workflows/ci.yml` | DevOps / **عالي** |
| DEV-02 | PWA للداشبورد (Workbox) | `vite-plugin-pwa` مع `StaleWhileRevalidate` للـ drugs. تخزين الصفحات الأساسية. عمل القراءة أوفلاين (فواتير، تقارير محمّلة). **الملفات:** `vite.config.ts`، `public/sw.js` | Frontend / **متوسط** |
| DOCS-01 | Swagger لجميع الـ endpoints الجديدة | 21 endpoint جديدة: `/api/insurance/*` (7)، `/api/sync/batch` (1)، `/api/prescriptions/*` (5)، `/api/pharmacy/*` (8). تحديث موجود: `/api/drugs?updatedAfter`. **الملفات:** `swagger/insurance.yaml`، `pharmacy.yaml`، `sync.yaml` | Backend / **متوسط** |

---

## المخاطر والتبعيات التقنية

### المخاطر

| المخاطرة | الوصف | الحل المقترح |
|---|---|---|
| تعارضات المزامنة أوفلاين | مريض اشترى دواء أوفلاين والدواء نفد من الصيدلية قبل المزامنة | Server-wins للمخزون + إشعار فوري للمستخدم مع خيار إعادة الطلب. Last-write-wins للقراءات فقط. |
| Race Conditions في الحجز | طلبان من صيدليتين مختلفتين على نفس الدواء في الميلي-ثانية ذاتها | MongoDB Transaction مع Optimistic Locking (key: version). إذا تغيّرت الـ version: retry تلقائي. |
| تنوع أنظمة التأمين | كل شركة لها قواعد مختلفة، بعضها يحتاج API مباشر وبعضها ملف Excel شهري | بناء منطق عام مرن أولًا. ربط API مع شركات بعينها يُؤجَّل كميزة premium بعد الإطلاق. |
| حجم Hive cache والأجهزة القديمة | كتالوج كبير (10,000+ دواء) قد يأخذ 50–100 MB على الجهاز | Delta sync (فقط التغييرات). تخزين أسعار وأسماء فقط في Hive. الصور تُحمَّل عند الطلب. |

---

### التبعيات الحرجة بين المهام

يجب مراعاة الترتيب التالي لضمان عدم الانتظار بين المطورين:

- `STK-01` (DB schema) ← يجب أن يكتمل قبل `STK-02` و `STK-03`
- `INS-01` (InsuranceCompany model) ← قبل `INS-02` و `INS-03`
- `OFF-01` (Hive setup) ← قبل `OFF-02` و `OFF-03` و `OFF-04`
- `PHA-01` (Pharmacy model) ← قبل `PHA-02` و `PHA-03` و `PHA-04`
- `OFF-05` (Batch Sync API) ← يمكن للمطور 1 أن يبدأ SyncQueue بينما المطور 2 يبني الـ API
- `SMS-01` ← مستقل ويمكن تنفيذه متوازيًا في الأسبوع 3

---

> هذه الخطة قابلة للتعديل حسب الأولويات التجارية. يُنصح بمراجعتها دوريًا مع كل sprint.
