import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/models/payment_model.dart';
import '../../core/providers/payment_provider.dart';
import '../../core/providers/theme_provider.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    await context.read<PaymentProvider>().loadPaymentHistory();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final paymentProvider = context.watch<PaymentProvider>();
    final history = paymentProvider.paymentHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.filter),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: paymentProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHistory,
              child: history.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final payment = history[index];
                        final showHeader =
                            index == 0 ||
                            !_isSameMonth(
                              history[index - 1].createdAt,
                              payment.createdAt,
                            );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showHeader) ...[
                              if (index > 0) const SizedBox(height: 24),
                              _buildMonthHeader(payment.createdAt, isDark),
                              const SizedBox(height: 12),
                            ],
                            _buildPaymentCard(payment, isDark),
                          ],
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.receipt_item,
            size: 80,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No payment history',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your transactions will appear here',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(DateTime date, bool isDark) {
    return Text(
      DateFormat('MMMM yyyy').format(date),
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
      ),
    );
  }

  Widget _buildPaymentCard(PaymentHistory payment, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getStatusColor(payment.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getTypeIcon(payment.type),
              color: _getStatusColor(payment.status),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.description ?? _getTypeLabel(payment.type),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      DateFormat(
                        'MMM d, yyyy • h:mm a',
                      ).format(payment.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                    ),
                    _buildStatusBadge(payment.status),
                  ],
                ),
              ],
            ),
          ),
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${payment.type == PaymentType.subscription ? '-' : ''}\$${payment.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: payment.status == PaymentStatus.completed
                      ? (isDark ? Colors.white : Colors.black87)
                      : Colors.grey,
                ),
              ),
              if (payment.discountAmount != null && payment.discountAmount! > 0)
                Text(
                  'Saved \$${payment.discountAmount!.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 11, color: Colors.green),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PaymentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _getStatusLabel(status),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.refunded:
        return Colors.blue;
      case PaymentStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getStatusLabel(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return 'COMPLETED';
      case PaymentStatus.pending:
        return 'PENDING';
      case PaymentStatus.failed:
        return 'FAILED';
      case PaymentStatus.refunded:
        return 'REFUNDED';
      case PaymentStatus.cancelled:
        return 'CANCELLED';
    }
  }

  IconData _getTypeIcon(PaymentType type) {
    switch (type) {
      case PaymentType.subscription:
        return Iconsax.crown1;
      case PaymentType.rental:
        return Iconsax.video_time;
      case PaymentType.purchase:
        return Iconsax.video_play;
    }
  }

  String _getTypeLabel(PaymentType type) {
    switch (type) {
      case PaymentType.subscription:
        return 'Subscription';
      case PaymentType.rental:
        return 'Movie Rental';
      case PaymentType.purchase:
        return 'Movie Purchase';
    }
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }
}
