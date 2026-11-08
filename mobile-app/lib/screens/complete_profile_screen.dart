import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dighri_customer/constants/app_colors.dart';
import 'package:dighri_customer/services/api_service.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final TextEditingController _nameController = TextEditingController(); // Pharmacist Name
  final TextEditingController _pharmacyNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  XFile? _licenseImage;
  Position? _currentPosition;
  String _locationMessage = 'اضغط لتحديد الموقع';

  final ImagePicker _picker = ImagePicker();

  String? _validateRequired(String? value) {
    if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
    if (value.length < 3) return 'قصير جداً';
    return null;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _licenseImage = image);
      }
    } catch (e) { /* handle error */ }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'خدمة الموقع غير مفعلة';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'تم رفض إذن الموقع';
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _locationMessage = 'تم تحديد الموقع بنجاح ✅';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('الرجاء تحديد موقع الصيدلية أولاً'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService().updateProfile(
        name: _nameController.text,
        pharmacyName: _pharmacyNameController.text,
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
        licenseImage: _licenseImage,
      );

      if (mounted) {
        GoRouter.of(context).go('/waiting');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pharmacyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('إكمال البيانات', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ═══ الترحيب ═══
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.assignment_outlined, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('خطوة أخيرة!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                            Text(
                              'أكمل بيانات صيدليتك لتفعيل حسابك',
                              style: TextStyle(fontSize: 12, color: AppColors.textLight.withValues(alpha: 0.7)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ═══ الاسم الشخصي ═══
                const Text('البيانات الشخصية', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'اسم الصيدلاني',
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(Icons.person_outline, color: AppColors.primary),
                    ),
                  ),
                  validator: _validateRequired,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pharmacyNameController,
                  decoration: InputDecoration(
                    labelText: 'اسم الصيدلية',
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(Icons.store_outlined, color: AppColors.primary),
                    ),
                  ),
                  validator: _validateRequired,
                ),

                const SizedBox(height: 28),

                // ═══ الموقع ═══
                const Text('الموقع الجغرافي', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _getCurrentLocation,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _currentPosition != null
                            ? AppColors.emerald.withValues(alpha: 0.5)
                            : AppColors.grey,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _currentPosition != null
                                ? AppColors.emerald.withValues(alpha: 0.1)
                                : AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _currentPosition != null ? Icons.check_circle : Icons.location_on_outlined,
                            color: _currentPosition != null ? AppColors.emerald : AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentPosition == null ? 'تحديد الموقع' : 'تم التحديد',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                              ),
                              Text(
                                _locationMessage,
                                style: TextStyle(fontSize: 12, color: AppColors.textLight.withValues(alpha: 0.7)),
                              ),
                            ],
                          ),
                        ),
                        if (_isLoading && _currentPosition == null)
                          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        else
                          Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textLight.withValues(alpha: 0.5)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ═══ صورة الترخيص ═══
                InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _licenseImage != null
                            ? AppColors.emerald.withValues(alpha: 0.5)
                            : AppColors.grey,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _licenseImage != null
                                ? AppColors.emerald.withValues(alpha: 0.1)
                                : AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _licenseImage != null ? Icons.check_circle : Icons.camera_alt_outlined,
                            color: _licenseImage != null ? AppColors.emerald : AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _licenseImage == null ? 'صورة الترخيص' : 'تم اختيار الصورة',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                              ),
                              Text(
                                _licenseImage == null ? 'اختياري — يمكنك إضافتها لاحقاً' : 'اضغط لتغيير الصورة',
                                style: TextStyle(fontSize: 12, color: AppColors.textLight.withValues(alpha: 0.7)),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.add_a_photo_outlined, size: 18, color: AppColors.textLight.withValues(alpha: 0.5)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ═══ زر الحفظ ═══
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _submitProfile,
                    icon: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check_circle_outline),
                    label: Text(
                      _isLoading ? 'جاري الحفظ...' : 'حفظ وبدء الاستخدام',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor: AppColors.primary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
