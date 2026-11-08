import 'package:dio/dio.dart';
import 'package:dighri_customer/services/api_service.dart';
import 'package:dighri_customer/core/api_exceptions.dart';

class InventoryService {
  static final InventoryService _instance = InventoryService._internal();
  factory InventoryService() => _instance;
  InventoryService._internal();

  final ApiService _api = ApiService();

  Future<List<dynamic>> getMyStock() async {
    try {
      final response = await _api.dio.get('/inventory/my-stock');
      return response.data['data']['stock'];
    } on DioException catch (e) {
      throw _api.handleError(e);
    }
  }

  Future<void> adjustStock(String stockId, int newQuantity) async {
    try {
      await _api.dio.patch('/inventory/$stockId/adjust', data: {'quantity': newQuantity});
    } on DioException catch (e) {
      throw _api.handleError(e);
    }
  }
}
