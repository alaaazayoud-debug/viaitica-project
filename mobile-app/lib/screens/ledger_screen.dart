import 'package:flutter/material.dart';
import 'package:dighri_customer/constants/app_colors.dart';
import 'package:dighri_customer/services/ledger_service.dart';
import 'package:dighri_customer/widgets/shimmer_loading.dart';
import 'package:dighri_customer/widgets/empty_state.dart';
import 'package:dighri_customer/widgets/error_state.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  List<dynamic> _entries = [];
  bool _isLoading = true;
  dynamic _error;

  @override
  void initState() {
    super.initState();
    _fetchLedger();
  }

  Future<void> _fetchLedger() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await LedgerService().getMyStatement();
      setState(() {
        _entries = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate totals for a simple summary
    double totalDebt = 0;
    for (var entry in _entries) {
      if (entry['type'] == 'debt') totalDebt += (entry['amount'] as num).toDouble();
      if (entry['type'] == 'payment') totalDebt -= (entry['amount'] as num).toDouble();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('كشف الحساب المالي'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF15803d)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                const Text('إجمالي المطالبات المستحقة', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  _isLoading ? '...' : '${totalDebt.toStringAsFixed(0)} ل.س',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          Expanded(
            child: _isLoading
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: List.generate(6, (_) => const ShimmerLedgerCard()),
                    ),
                  )
                : _error != null
                    ? ErrorStateWidget(error: _error, onRetry: _fetchLedger)
                    : _entries.isEmpty
                        ? const EmptyStateWidget(
                            icon: Icons.account_balance_wallet_outlined,
                            title: 'لا يوجد سجل مالي حالياً',
                            subtitle: 'ستظهر هنا جميع عمليات الدين والتسديد بعد إتمام طلباتك',
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchLedger,
                            color: AppColors.primary,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _entries.length,
                              itemBuilder: (context, index) {
                                final entry = _entries[index];
                                final isDebt = entry['type'] == 'debt';
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey.shade200),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isDebt ? Colors.red.shade50 : Colors.green.shade50,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isDebt ? Icons.arrow_upward : Icons.arrow_downward,
                                          color: isDebt ? Colors.red : Colors.green,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(entry['description'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                            Text(entry['warehouse']?['name'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${isDebt ? "+" : "-"}${entry['amount']} ل.س',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isDebt ? Colors.red : Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
