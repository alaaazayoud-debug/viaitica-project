import 'package:flutter/material.dart';

class OtpController {
  final TextEditingController otpFieldController = TextEditingController();

  /// الكود الصحيح الثابت (حالياً)
  final String _validOtp = '1234';

  /// التحقق من الكود المُدخل
  bool verifyOtp(String enteredOtp) {
    return enteredOtp == _validOtp;
  }

  /// تنظيف الموارد عند الانتهاء
  void dispose() {
    otpFieldController.dispose();
  }
}
