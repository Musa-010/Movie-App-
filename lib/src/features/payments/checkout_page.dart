import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../core/models/subscription_model.dart';
import '../../core/models/payment_model.dart';
import '../../core/providers/payment_provider.dart';
import '../../core/providers/theme_provider.dart';
import 'widgets/widgets.dart';

class CheckoutPage extends StatefulWidget {
  final SubscriptionPlan plan;

  const CheckoutPage({
    super.key,
    required this.plan,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _promoController = TextEditingController();
  PromoCode? _appliedPromo;
  bool _isApplyingPromo = false;
  String? _promoError;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  double get _subtotal => widget.plan.price;
  
  double get _discount => _appliedPromo?.calculateDiscount(_subtotal) ?? 0;
  
  double get _total => _subtotal - _discount;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final paymentProvider = context.watch<PaymentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary
                  _buildSectionTitle('Order Summary', isDark),
                  const SizedBox(height: 12),
                  _buildOrderSummary(isDark),

                  const SizedBox(height: 24),

                  // Promo Code
                  _buildSectionTitle('Promo Code', isDark),
                  const SizedBox(height: 12),
                  _buildPromoCodeSection(isDark),

                  const SizedBox(height: 24),

                  // Payment Method
                  _buildSectionTitle('Payment Method', isDark),
                  const SizedBox(height: 12),
                  _buildPaymentMethodSection(paymentProvider, isDark),

                  const SizedBox(height: 24),

                  // Price Breakdown
                  _buildSectionTitle('Price Breakdown', isDark),
                  const SizedBox(height: 12),
                  _buildPriceBreakdown(isDark),

                  const SizedBox(height: 24),

                  // Terms
                  _buildTermsSection(isDark),
                ],
              ),
            ),
          ),

          // Bottom CTA
          _buildBottomSection(paymentProvider, isDark),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildOrderSummary(bool isDark) {
    return Container(
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
          // Plan icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _getTierColor(widget.plan.tier).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getTierIcon(widget.plan.tier),
              color: _getTierColor(widget.plan.tier),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Plan details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.plan.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Billed ${widget.plan.interval}ly',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Price
          Text(
            '\$${widget.plan.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCodeSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_appliedPromo != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.ticket_discount, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _appliedPromo!.code,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        '${_appliedPromo!.discountPercent.toInt()}% off',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _appliedPromo = null;
                      _promoController.clear();
                    });
                  },
                  icon: const Icon(Icons.close, color: Colors.green),
                ),
              ],
            ),
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Enter promo code',
                    filled: true,
                    fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    errorText: _promoError,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isApplyingPromo ? null : _applyPromoCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isApplyingPromo
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentMethodSection(PaymentProvider provider, bool isDark) {
    final defaultMethod = provider.paymentMethods.isNotEmpty
        ? provider.paymentMethods.firstWhere(
            (m) => m.isDefault,
            orElse: () => provider.paymentMethods.first,
          )
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          if (defaultMethod != null)
            Row(
              children: [
                Container(
                  width: 48,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Iconsax.card, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        defaultMethod.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        'Expires ${defaultMethod.expiryDate}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to payment methods page
                  },
                  child: const Text('Change'),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: () async {
                await provider.addPaymentMethod();
              },
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Iconsax.add,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Add payment method',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                  Icon(
                    Iconsax.arrow_right_3,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Apple Pay / Google Pay options
          Row(
            children: [
              Expanded(
                child: _buildQuickPayOption(
                  icon: Icons.apple,
                  label: 'Apple Pay',
                  isDark: isDark,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickPayOption(
                  icon: Icons.g_mobiledata,
                  label: 'Google Pay',
                  isDark: isDark,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPayOption({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', '\$${_subtotal.toStringAsFixed(2)}', isDark),
          if (_discount > 0) ...[
            const SizedBox(height: 12),
            _buildPriceRow(
              'Discount (${_appliedPromo!.discountPercent.toInt()}%)',
              '-\$${_discount.toStringAsFixed(2)}',
              isDark,
              isDiscount: true,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _buildPriceRow(
            'Total',
            '\$${_total.toStringAsFixed(2)}',
            isDark,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String amount,
    bool isDark, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isDiscount
                ? Colors.green
                : isDark
                    ? (isTotal ? Colors.white : Colors.grey.shade400)
                    : (isTotal ? Colors.black87 : Colors.grey.shade600),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 20 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isDiscount
                ? Colors.green
                : isDark
                    ? Colors.white
                    : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTermsSection(bool isDark) {
    return Text.rich(
      TextSpan(
        text: 'By completing this purchase, you agree to our ',
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
        ),
        children: [
          TextSpan(
            text: 'Terms of Service',
            style: TextStyle(
              color: Colors.blue.shade700,
              decoration: TextDecoration.underline,
            ),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              color: Colors.blue.shade700,
              decoration: TextDecoration.underline,
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildBottomSection(PaymentProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: PaymentButton(
          text: 'Pay \$${_total.toStringAsFixed(2)}',
          isLoading: provider.isLoading,
          onPressed: () => _processPayment(provider),
        ),
      ),
    );
  }

  Future<void> _applyPromoCode() async {
    if (_promoController.text.isEmpty) return;

    setState(() {
      _isApplyingPromo = true;
      _promoError = null;
    });

    final promo = await context
        .read<PaymentProvider>()
        .validatePromoCode(_promoController.text);

    setState(() {
      _isApplyingPromo = false;
      if (promo != null) {
        _appliedPromo = promo;
      } else {
        _promoError = 'Invalid or expired promo code';
      }
    });
  }

  Future<void> _processPayment(PaymentProvider provider) async {
    final success = await provider.subscribeToPlan(widget.plan);

    if (success && mounted) {
      // Apply promo if used
      if (_appliedPromo != null) {
        await provider.applyPromoCode(_appliedPromo!.id);
      }

      // Show success and go back
      Navigator.popUntil(context, (route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully subscribed to ${widget.plan.name}!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Payment failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getTierColor(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return Colors.grey;
      case SubscriptionTier.premium:
        return Colors.blue.shade700;
      case SubscriptionTier.vip:
        return Colors.amber.shade700;
    }
  }

  IconData _getTierIcon(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return Iconsax.user;
      case SubscriptionTier.premium:
        return Iconsax.crown1;
      case SubscriptionTier.vip:
        return Iconsax.star1;
    }
  }
}
