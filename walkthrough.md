# 🏥 Viatica — فارمجي (Farmaji)
> منصة رقمية متكاملة تربط **الصيدليات** بـ **مستودعات الأدوية** عبر تطبيق موبايل وداشبورد إدارة وباكند مركزي.

---

## 📐 1. الهيكل العام للمشروع

```mermaid
graph TB
    subgraph "📱 Mobile App - Flutter"
        MA["تطبيق الصيدلي"]
        MA --> |"Dio HTTP"| API
    end

    subgraph "🖥️ Dashboard - React + Vite"
        DB["لوحة تحكم المستودع/الأدمن"]
        DB --> |"Axios"| API
    end

    subgraph "⚙️ Backend - Node.js + Express"
        API["REST API v1"]
        API --> MongoDB["MongoDB Atlas"]
        API --> Cloudinary["Cloudinary (صور)"]
        API --> Firebase["Firebase (Notifications)"]
        API --> SMS["SMS Provider (OTP)"]
    end

    style MA fill:#4CAF50,color:#fff
    style DB fill:#2196F3,color:#fff
    style API fill:#FF9800,color:#fff
    style MongoDB fill:#47A248,color:#fff
```

| المكوّن | التقنية | الحالة |
|---------|---------|--------|
| **Backend** | Node.js 18+ / Express / MongoDB (Mongoose) | ✅ مرفوع على Render |
| **Dashboard** | React 18 / Vite / TypeScript / TailwindCSS | ✅ مرفوع على Vercel |
| **Mobile App** | Flutter / Dart / GoRouter / Firebase | ✅ APK جاهز للتوزيع |
| **قاعدة البيانات** | MongoDB Atlas | ✅ جاهز |
| **التخزين السحابي** | Cloudinary | ✅ مُدعم |
| **الإشعارات** | Firebase Cloud Messaging (FCM) | ✅ مُهيأ (Backend + Mobile) |

---

## 👥 2. أنواع المستخدمين (Roles)

| الدور | طريقة الدخول | القدرات |
|-------|-------------|---------|
| **Admin** | إيميل + كلمة مرور (Dashboard) | إدارة المستخدمين، الموافقة على الصيادلة، إحصائيات عامة |
| **Warehouse** | إيميل + كلمة مرور (Dashboard) | إدارة كاملة: مخزون، طلبات، POS، مشتريات، موردين، تقارير، مرتجعات، مصاريف |
| **Pharmacist** | رقم هاتف + OTP (Mobile App) | تصفح الأدوية، إنشاء طلبات، متابعة الحساب المالي، POS مبسط |
| **Customer** | يُنشئه المستودع من Dashboard | زبون/موزع مسجل لتتبعه مالياً |
| **Driver** | (دور موجود، تطبيق قيد التطوير) | تحديث حالة التوصيل |

---

## 🗄️ 3. نماذج قاعدة البيانات (15 Model)

| النموذج | الوصف |
|---------|-------|
| `User` | admin / pharmacist / warehouse / driver / customer |
| `Drug` | الأدوية: اسم، كمية، سعر، صلاحية، باركود، سعر عام |
| `Order` | الطلبات: app / manual_pharmacy / manual_distributor / manual_other |
| `Invoice` | الفواتير مع snapshot المستودع وقت الإصدار |
| `Ledger` | القيود المالية: debt / payment |
| `Return` | المرتجعات: إعادة مخزون + قيد دائن |
| `Offer` | العروض: خصم / بونص / توصيل مجاني |
| `PharmacistStock` | مخزون تتبعي للصيدلي |
| `Notification` | إشعارات النظام |
| `Purchase` | مشتريات المستودع من الموردين |
| `Supplier` | موردو المستودع |
| `Expense` | مصاريف التشغيل |
| `StockMovement` | حركات المخزون (in/out) |
| `FeedItem` | منشورات Farmaji Pulse (الأخبار) |
| `AuditLog` | سجل المراجعة الأمنية |

---

## 🔄 4. تدفق العمليات الأساسية

### 4.1 دورة حياة الطلب
```mermaid
stateDiagram-v2
    [*] --> pending: الصيدلي يطلب
    pending --> confirmed: المستودع يوافق
    confirmed --> assigned: تعيين سائق
    assigned --> out_for_delivery: السائق يبدأ
    out_for_delivery --> delivered: تم التسليم ✅
    pending --> cancelled: إلغاء ❌
    confirmed --> cancelled: إلغاء ❌
    delivered --> [*]: تحديث المخزون + الحساب المالي تلقائياً
```

### 4.2 نقطة البيع (POS) — بيع مباشر
```mermaid
flowchart LR
    A["اختيار نوع البيع"] --> B{"صيدلية مسجلة؟"}
    B -->|نعم| C["اختيار من القائمة"]
    B -->|لا| D["إدخال اسم الزبون"]
    C --> E["إضافة أدوية للسلة"]
    D --> E
    E --> F{"نوع الدفع"}
    F -->|نقدي| G["debt + payment فوري"]
    F -->|آجل| H["debt فقط"]
    G --> I["فاتورة + طلب"]
    H --> I
```

### 4.3 نظام المرتجعات
- اختيار طلب مُسلَّم → تحديد الأصناف والكميات → إعادة مخزون تلقائية + قيد دائن في Ledger

### 4.4 نظام المشتريات
- المستودع يشتري من مورد → تسجيل فاتورة شراء → تحديث المخزون → تتبع المصاريف

### 4.5 منطق العروض التلقائية
عند إنشاء طلب: جلب العروض النشطة → تطبيق خصم النسبة → حساب البونص → فحص التوصيل المجاني → خصم الكمية من المخزون

---

## 🖥️ 5. صفحات الداشبورد (React) — 20 صفحة

| الصفحة | الوظيفة | الحالة |
|--------|---------|--------|
| `Login.tsx` | تسجيل الدخول | ✅ |
| `Landing.tsx` | الصفحة التعريفية للمنصة | ✅ |
| `DashboardHome.tsx` | إحصائيات + رسوم بيانية + مبيعات اليوم | ✅ |
| `PointOfSale.tsx` | بيع مباشر (كاش/آجل) + فواتير فورية | ✅ |
| `Inventory.tsx` | عرض/إضافة/استيراد الأدوية | ✅ |
| `Orders.tsx` | قائمة الطلبات + فلترة + تمييز POS | ✅ |
| `OrderDetails.tsx` | تفاصيل + تغيير حالة + تعيين سائق | ✅ |
| `Returns.tsx` | واجهة المرتجعات الكاملة | ✅ |
| `Finance.tsx` | كشوف حسابات + تسديد ديون | ✅ |
| `Reports.tsx` | تقارير مبيعات + فلترة + تصدير Excel | ✅ |
| `Purchases.tsx` | إدارة مشتريات المستودع من الموردين | ✅ |
| `Suppliers.tsx` | إدارة الموردين | ✅ |
| `Expenses.tsx` | تتبع مصاريف التشغيل | ✅ |
| `ProfitLoss.tsx` | تقرير الأرباح والخسائر | ✅ |
| `StockMovements.tsx` | تتبع حركات المخزون (in/out) | ✅ |
| `Alerts.tsx` | تنبيهات انتهاء الصلاحية ونقص المخزون | ✅ |
| `FeedManagement.tsx` | إدارة منشورات Farmaji Pulse | ✅ |
| `Users.tsx` | إدارة المستخدمين + الموافقة + إضافة زبائن | ✅ |
| `Offers.tsx` | إنشاء/تعديل العروض | ✅ |
| `WarehouseProfile.tsx` | بيانات المستودع + الشعار + تخصيص الفاتورة | ✅ |

### مكونات مساعدة (7 Components):
`AddDrugModal` · `AddOfferModal` · `SmartImportModal` · `PrintInvoiceModal` · `StockReplenishModal` · `Header` · `Sidebar`

---

## 📱 6. شاشات التطبيق (Flutter) — 19 شاشة

| الشاشة | الوظيفة |
|--------|---------|
| `splash_screen.dart` | شاشة بداية متحركة + تحقق من Token |
| `phone_entry_screen.dart` | تسجيل/دخول بالهاتف |
| `otp_screen.dart` | إدخال رمز التحقق |
| `complete_profile_screen.dart` | اسم الصيدلية + رخصة + موقع |
| `waiting_approval_screen.dart` | شاشة انتظار الموافقة |
| `main_layout_screen.dart` | الهيكل الرئيسي + Bottom Navigation |
| `home_screen.dart` | الواجهة الرئيسية (Farmaji Pulse + إحصائيات) |
| `warehouses_list_screen.dart` | قائمة المستودعات المتاحة |
| `medicine_catalog_screen.dart` | تصفح + بحث + فلترة الأدوية |
| `drug_detail_screen.dart` | تفاصيل الدواء الكاملة |
| `cart_screen.dart` | سلة المشتريات |
| `my_orders_screen.dart` | قائمة الطلبات |
| `order_details_screen.dart` | تتبع حالة الطلب |
| `offers_screen.dart` | عروض المستودعات |
| `pharmacist_inventory_screen.dart` | مخزون الصيدلية الخاص |
| `ledger_screen.dart` | كشف حساب (ديون + مدفوعات) |
| `notifications_screen.dart` | إشعارات النظام |
| `feed_details_screen.dart` | تفاصيل منشور Farmaji Pulse |
| `pos_screen.dart` | نقطة بيع مبسطة للصيدلي |

### خدمات الموبايل (8 Services):
`api_service` · `cart_service` · `inventory_service` · `ledger_service` · `location_service` · `notification_service` · `otp_service` · `secure_storage_service`

---

## ⚙️ 7. Backend — Controllers & Routes (16 Controller)

| Controller | الوظيفة |
|------------|---------|
| `auth.controller.js` | OTP + تسجيل دخول + إعادة تعيين كلمة المرور |
| `order.controller.js` | الطلبات الكاملة + منطق العروض + POS |
| `drug.controller.js` | CRUD الأدوية |
| `import.controller.js` | استيراد/تصدير Excel/CSV |
| `admin.controller.js` | صلاحيات الأدمن + إحصائيات |
| `invoice.controller.js` | الفواتير (إنشاء + عرض + طباعة) |
| `ledger.controller.js` | الحسابات المالية (كشوف + تسديد) |
| `report.controller.js` | تقارير المبيعات |
| `return.controller.js` | المرتجعات (إنشاء + إعادة مخزون) |
| `offer.controller.js` | العروض |
| `notification.controller.js` | الإشعارات |
| `purchase.controller.js` | مشتريات المستودع من الموردين |
| `supplier.controller.js` | إدارة الموردين |
| `expense.controller.js` | مصاريف التشغيل |
| `feed.controller.js` | منشورات Farmaji Pulse |
| `stock.controller.js` | حركات المخزون والتنبيهات |

---

## 🛡️ 8. الأمان المُطبَّق

| الميزة | التقنية | الحالة |
|--------|---------|--------|
| CORS | Origins محددة (Vercel + Mobile) | ✅ |
| HTTP Security Headers | `helmet` | ✅ |
| Rate Limiting | `express-rate-limit` | ✅ |
| NoSQL Injection | `express-mongo-sanitize` | ✅ |
| XSS Protection | `xss-clean` | ✅ |
| Parameter Pollution | `hpp` | ✅ |
| Password Hashing | `bcryptjs` (12 rounds) | ✅ |
| JWT Authentication | `jsonwebtoken` | ✅ |
| OTP Hashing | SHA256 | ✅ |
| Role-Based Access | `restrictTo()` middleware | ✅ |
| Audit Logging | `AuditLog` model | ✅ |

---

## 📊 9. تقييم الجاهزية للإنتاج — مايو 2026

> [!IMPORTANT]
> ### ✅ المنجز — نسبة الاكتمال ~92%

**Backend:**
- ✅ 16 Controller + 15 نموذج بيانات
- ✅ نظام مصادقة كامل (OTP + Email/Password)
- ✅ دورة حياة الطلب الكاملة مع منطق العروض التلقائي
- ✅ نقطة البيع (POS) + الفواتير الاحترافية
- ✅ الحسابات المالية (Ledger) + نظام المرتجعات
- ✅ مشتريات المستودع + إدارة الموردين
- ✅ مصاريف التشغيل + تقرير الأرباح والخسائر
- ✅ تنبيهات انتهاء الصلاحية + نقص المخزون
- ✅ Farmaji Pulse (نظام الأخبار والمنشورات)
- ✅ Firebase Cloud Messaging مُهيأ

**Dashboard:**
- ✅ 20 صفحة متكاملة + 7 مكونات
- ✅ Landing Page احترافية
- ✅ مرفوع على Vercel ويعمل بشكل كامل

**Mobile App:**
- ✅ 19 شاشة + 8 خدمات
- ✅ Splash Screen متحركة احترافية
- ✅ Firebase FCM مُهيأ لاستقبال الإشعارات
- ✅ APK مبني وجاهز للتوزيع

> [!WARNING]
> ### ⚠️ ما يحتاج إكمالاً قبل الإطلاق الحقيقي

1. **SMS Provider حقيقي** — الـ OTP يُطبع في Console فقط حالياً
2. **Push Notifications كاملة** — FCM مُهيأ لكن يحتاج اختبار E2E كامل
3. **اختبارات** — تغطية الاختبارات شبه معدومة
4. **تطبيق السائق** — الدور موجود لكن لا تطبيق منفصل

---

## 🗺️ 10. خارطة الطريق المستقبلية

### المرحلة 1: إطلاق تجاري فعلي (2-3 أسابيع)

| المهمة | الأولوية |
|--------|---------|
| ربط SMS Provider حقيقي (Twilio أو محلي) | 🔴 حرج |
| اختبار Push Notifications E2E | 🔴 حرج |
| Docker + CI/CD على سيرفر | 🟡 مهم |
| اختبارات أساسية (Jest) | 🟡 مهم |

### المرحلة 2: ميزات تنافسية (1-2 شهر)

| المهمة | الأولوية |
|--------|---------|
| تطبيق السائق (Flutter منفصل) + GPS تتبع | 🟡 مهم |
| WebSocket / Real-time تحديثات حية | 🟡 مهم |
| نظام محفظة رقمية + دفع إلكتروني | 🟡 مهم |
| Dark Mode للتطبيق | 🟢 تحسين |
| Multi-language (عربي/إنجليزي) | 🟢 تحسين |

### المرحلة 3: التوسع والاحتراف (2-4 شهر)

| المهمة | الأولوية |
|--------|---------|
| Multi-tenancy (عدة مستودعات مستقلة) | 🟡 مهم |
| خطط اشتراك (مجاني / أساسي / احترافي) | 🟡 مهم |
| AI: توقع الطلب + تنبيهات ذكية | 🟢 تحسين |
| White Label لكل مستودع | 🟢 تحسين |
| Swagger / OpenAPI Documentation | 🟢 تحسين |
| تطبيق موبايل للمستودع | 🟢 تحسين |

---

## 💰 11. الرؤية التجارية

### نموذج الربح
```mermaid
graph TD
    A["💰 مصادر الدخل"] --> B["اشتراك شهري للمستودعات"]
    A --> C["عمولة على كل طلب %"]
    A --> D["رسوم العروض المميزة"]
    A --> E["بيع النظام White-Label"]

    style A fill:#FFD700,color:#000
    style B fill:#4CAF50,color:#fff
    style C fill:#2196F3,color:#fff
    style D fill:#FF9800,color:#fff
    style E fill:#9C27B0,color:#fff
```

### الأسواق المستهدفة
1. 🇸🇾 **سوريا** — سوق ناشئ، فرصة رائدة لرقمنة سلسلة الأدوية
2. 🇮🇶 **العراق** — سوق مشابه مع حاجة تنظيمية قوية
3. 🇯🇴 **الأردن** — سوق منظم يقبل الابتكار
4. 🇪🇬 **مصر** — سوق ضخم مع منافسة عالية

> [!NOTE]
> ### تقييم قيمة المشروع (مايو 2026)
> - **كقاعدة كود جاهزة:** $12,000 - $18,000
> - **بعد إكمال المرحلة 1 (SMS + Docker):** $20,000 - $28,000
> - **كمنتج SaaS مع أول 5 عملاء:** $40,000 - $60,000+

---

## 📁 12. هيكل الملفات الكامل

```
Viatica-Project/
├── 📂 backend/                    # Node.js + Express API
│   ├── controllers/               # 16 controllers
│   ├── models/                    # 15 Mongoose models
│   ├── routes/                    # 16+ route files
│   ├── middlewares/               # auth, error, auditLogger, upload
│   ├── services/                  # ai.service, notification.service
│   ├── utils/                     # JWT, Email, SMS, Error handling
│   ├── scripts/                   # seed, migrate
│   ├── app.js                     # Express configuration
│   └── server.js                  # Entry point
│
├── 📂 dashboard/                  # React 18 + Vite + TypeScript
│   └── src/
│       ├── pages/                 # 20 pages
│       ├── components/            # 7 components
│       ├── context/               # AuthContext
│       ├── services/              # API service (Axios)
│       └── layouts/               # MainLayout
│
└── 📂 mobile-app/                 # Flutter (dighri_customer)
    └── lib/
        ├── screens/               # 19 screens
        ├── services/              # 8 services
        ├── models/                # user_model.dart
        ├── controller/            # BLoC controllers
        ├── constants/             # colors, theme
        └── main.dart              # GoRouter configuration
```

---

## 🎯 13. ملخص الإنجازات التراكمية

| الفترة | الإنجاز |
|--------|---------|
| **أبريل 2026 — الأسبوع 1** | بنية المشروع + المصادقة + CRUD الأدوية + الطلبات الأساسية |
| **أبريل 2026 — الأسبوع 2** | نظام العروض الذكي + POS + الفواتير + الحسابات المالية |
| **أبريل 2026 — الأسبوع 3** | المرتجعات + التقارير + تصدير Excel + أمان CORS |
| **أبريل 2026 — الأسبوع 4** | Dashboard Vercel deployment + Farmaji Pulse + مخزون الصيدلي |
| **مايو 2026 — الأسبوع 1** | مشتريات + موردين + مصاريف + P&L + تنبيهات + Landing Page |
| **مايو 2026 — الأسبوع 2** | Firebase FCM + APK إنتاج + Splash Screen احترافية + اختبار E2E |

> [!TIP]
> **المشروع الآن شبه جاهز للإطلاق التجاري.**
> الخطوة التالية الحرجة: ربط SMS Provider حقيقي لتفعيل OTP في الإنتاج.
