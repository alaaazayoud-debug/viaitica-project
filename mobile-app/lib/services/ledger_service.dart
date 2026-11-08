import 'package:dio/dio.dart';
import 'package:dighri_customer/services/api_service.dart';
import 'package:dighri_customer/core/api_exceptions.dart';

class LedgerService {
  static final LedgerService _instance = LedgerService._internal();
  factory LedgerService() => _instance;
  LedgerService._internal();

  final ApiService _api = ApiService();

  Future<List<dynamic>> getMyStatement() async {
    try {
      final response = await _api.dio.get('/ledger/statement');
      return response.data['data']['entries'];
    } on DioException catch (e) {
      throw _api.handleError(e);
    }
  }
}
