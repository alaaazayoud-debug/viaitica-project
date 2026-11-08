const xlsx = require('xlsx');
const path = require('path');
const fs = require('fs');

const sourceFile = 'C:/Users/Alaa/Downloads/المنتج (product.template) (1).xlsx';
const targetFile = 'C:/Users/Alaa/Downloads/ready_to_import.xlsx';

try {
  console.log('📖 جاري قراءة ملف المنتجات الأساسي...');
  const wb = xlsx.readFile(sourceFile);
  const ws = wb.Sheets[wb.SheetNames[0]];
  const data = xlsx.utils.sheet_to_json(ws);

  console.log(`تم العثور على ${data.length} منتج.`);

  const uniqueDrugs = new Map();

  data.forEach((row) => {
    // استخراج القيم الأساسية
    let name = row['الاسم'] || '';
    if (!name) return; // تخطي السطور الفارغة
    name = name.toString().trim();

    const price = parseFloat(row['سعر البيع']) || parseFloat(row['التكلفة']) || 0;
    const quantity = parseFloat(row['الكمية في اليد']) || 0;
    const barcode = row['مرجع داخلي'] ? row['مرجع داخلي'].toString() : 'N/A';

    // إذا كان الدواء موجوداً بالفعل، نقوم فقط بزيادة الكمية (إذا أردنا الدمج)
    if (uniqueDrugs.has(name)) {
      const existing = uniqueDrugs.get(name);
      existing['الكمية'] += quantity;
    } else {
      uniqueDrugs.set(name, {
        'الاسم التجاري': name,
        'الاسم العلمي': name, // افتراضي
        'الشركة المصنعة': 'غير محدد',
        'السعر': price,
        'الكمية': quantity,
        'التصنيف': 'other',
        'تاريخ الانتهاء': '2027-12-31', // افتراضي
        'رقم الطبخة': barcode,
        'العيار': 'N/A',
        'الشكل الصيدلاني': 'Other'
      });
    }
  });

  const finalData = Array.from(uniqueDrugs.values());
  console.log(`✅ بعد إزالة المكررات ودمج الكميات، أصبح العدد: ${finalData.length} منتج.`);

  // إنشاء ملف الإكسل الجديد
  const newWb = xlsx.utils.book_new();
  const newWs = xlsx.utils.json_to_sheet(finalData);
  xlsx.utils.book_append_sheet(newWb, newWs, 'Inventory');

  xlsx.writeFile(newWb, targetFile);
  console.log(`🎉 تم حفظ الملف الجاهز للاستيراد بنجاح في:\n${targetFile}`);

} catch (error) {
  console.error('❌ حدث خطأ:', error);
}
