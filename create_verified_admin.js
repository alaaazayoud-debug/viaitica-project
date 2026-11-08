const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('./backend/models/User');

// قم بتحميل متغيرات البيئة من ملف .env لتطبيق الإنتاج
dotenv.config({ path: './backend/.env' });

const createAdmin = async () => {
    try {
        const uri = process.env.DATABASE_FULL_URL;
        if (!uri) {
            throw new Error('DATABASE_FULL_URL غير موجود في ملف .env');
        }

        console.log('⏳ جاري الاتصال قاعدة البيانات...');
        await mongoose.connect(uri, {
            useNewUrlParser: true,
            useUnifiedTopology: true,
        });
        console.log(`✅ تم الاتصال بنجاح بـ: ${uri.split('@')[1]}`); // إخفاء كلمة المرور للأمان

        // التحقق مما إذا كان المستخدم موجوداً
        const email = 'final_admin@viatica.com';
        const existingUser = await User.findOne({ email });
        
        if (existingUser) {
            console.log('ℹ️ المستخدم موجود بالفعل، جاري حذفه لإعادة الإنشاء...');
            await User.deleteOne({ email });
        }

        // إنشاء المستخدم
        const user = await User.create({
            name: 'Final Admin',
            email: email,
            password: 'password123', // كلمة مرور بسيطة وواضحة
            role: 'admin',
            phone: '0999999999',
            isVerified: true
        });

        console.log('🎉 تم إنشاء المستخدم بنجاح!');
        console.log('--- بيانات الدخول ---');
        console.log(`📧 الإيميل: ${email}`);
        console.log(`🔑 كلمة المرور: password123`);
        console.log('---------------------');
        
        process.exit();
    } catch (err) {
        console.error('❌ حدث خطأ:', err);
        process.exit(1);
    }
};

createAdmin();
