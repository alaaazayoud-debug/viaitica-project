import '../services/location_service.dart';

class LocationController {
  final LocationService _locationService = LocationService();

  Future<bool> validateUserLocation() async {
    try {
      return await _locationService.isInsideLatakia();
    } catch (e) {
      print('⚠️ خطأ في التحقق من الموقع: $e');
      return false;
    }
  }
}
