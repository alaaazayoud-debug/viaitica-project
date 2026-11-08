import 'package:geolocator/geolocator.dart';

class LocationService {
  static const double latakiaLat = 35.53;
  static const double latakiaLng = 35.78;
  static const double radiusMeters = 5000;

  /// الحصول على الموقع الحالي
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('خدمة الموقع غير مفعّلة');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('تم رفض إذن الموقع');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  /// التحقق إذا كان المستخدم داخل حدود اللاذقية
  Future<bool> isInsideLatakia() async {
    Position position = await getCurrentLocation();

    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      latakiaLat,
      latakiaLng,
    );

    return distance <= radiusMeters;
  }
}
