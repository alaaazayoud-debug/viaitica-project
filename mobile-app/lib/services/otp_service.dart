import 'package:flutter/material.dart';

class OtpController {
  final TextEditingController otpFieldController = TextEditingController();

  // الكود الثابت الحالي للتحقق
  final String _validOtp = '1234';

  /// التحقق من صحة الرمز المُدخل
  bool verifyOtp(String enteredOtp) {
    return enteredOtp == _validOtp;
  }

  void dispose() {
    otpFieldController.dispose();
  }
}
