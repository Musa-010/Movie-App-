import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../core/models/payment_model.dart';
import '../../core/providers/payment_provider.dart';
import '../../core/providers/theme_provider.dart';
import 'widgets/widgets.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    await context.read<PaymentProvider>().loadPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final paymentProvider = context.watch<PaymentProvider>();
    final paymentMethods = paymentProvider.paymentMethods;
    final wallet = paymentProvider.wallet;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: paymentProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPaymentMethods,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wallet Section
                    _buildWalletCard(wallet, isDark),

                    const SizedBox(height: 24),

                    // Payment Methods Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Saved Cards',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addPaymentMethod,
                          icon: const Icon(Iconsax.add, size: 20),
                          label: const Text('Add Card'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (paymentMethods.isEmpty)
                      _buildEmptyState(isDark)
                    else
                      ...paymentMethods.map(
                        (method) => _buildPaymentMethodCard(
                          method,
                          isDark,
                          paymentProvider,
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Other Payment Options
                    Text(
                      'Other Payment Options',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildPaymentOption(
                      icon: Iconsax.card,
                      title: 'Pay by Card',
                      subtitle: 'Enter card details manually',
                      isDark: isDark,
                      onTap: () {
                        _showCardInputDialog(isDark);
                      },
                    ),

                    _buildPaymentOption(
                      icon: Icons.apple,
                      title: 'Apple Pay',
                      subtitle: 'Pay with Apple Pay',
                      isDark: isDark,
                      onTap: () {
                        _showComingSoonSnackbar('Apple Pay');
                      },
                    ),

                    _buildPaymentOption(
                      icon: Icons.g_mobiledata,
                      title: 'Google Pay',
                      subtitle: 'Pay with Google Pay',
                      isDark: isDark,
                      onTap: () {
                        _showComingSoonSnackbar('Google Pay');
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWalletCard(WalletBalance? wallet, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade700.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Iconsax.wallet_3,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Wallet Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              IconButton(
                onPressed: _addFundsToWallet,
                icon: const Icon(Iconsax.add_circle, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '\$${(wallet?.balance ?? 0).toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Available for movie purchases & rentals',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Iconsax.card,
            size: 48,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No payment methods saved',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a card for faster checkout',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: PaymentButton(
              text: 'Add Payment Method',
              icon: Iconsax.add,
              height: 48,
              onPressed: _addPaymentMethod,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    PaymentMethod method,
    bool isDark,
    PaymentProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: method.isDefault
              ? Colors.blue.shade700
              : isDark
              ? Colors.grey.shade800
              : Colors.grey.shade200,
          width: method.isDefault ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Card brand icon
          Container(
            width: 48,
            height: 32,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: _getCardBrandIcon(method.brand)),
          ),
          const SizedBox(width: 16),
          // Card details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      method.displayName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (method.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'DEFAULT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Expires ${method.expiryDate}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Actions
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            onSelected: (value) async {
              if (value == 'default') {
                await provider.setDefaultPaymentMethod(method.id);
              } else if (value == 'delete') {
                _confirmDeletePaymentMethod(method, provider);
              }
            },
            itemBuilder: (context) => [
              if (!method.isDefault)
                const PopupMenuItem(
                  value: 'default',
                  child: Row(
                    children: [
                      Icon(Iconsax.tick_circle, size: 20),
                      SizedBox(width: 12),
                      Text('Set as Default'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Iconsax.trash, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : Colors.black87,
          size: 28,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Iconsax.arrow_right_3,
        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        size: 20,
      ),
    );
  }

  Widget _getCardBrandIcon(String? brand) {
    switch (brand?.toLowerCase()) {
      case 'visa':
        return const Text(
          'VISA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.blue,
          ),
        );
      case 'mastercard':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            Transform.translate(
              offset: const Offset(-4, 0),
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );
      case 'amex':
        return const Text(
          'AMEX',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            color: Colors.blue,
          ),
        );
      default:
        return const Icon(Iconsax.card, size: 20);
    }
  }

  Future<void> _addPaymentMethod() async {
    final provider = context.read<PaymentProvider>();
    final success = await provider.addPaymentMethod();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment method added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _addFundsToWallet() async {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final amounts = [10.0, 25.0, 50.0, 100.0];
    double? selectedAmount;

    await showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Funds to Wallet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: amounts.map((amount) {
                  final isSelected = selectedAmount == amount;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedAmount = amount),
                    child: Container(
                      width: 80,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.shade700
                            : isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue.shade700
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        '\$${amount.toInt()}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : isDark
                              ? Colors.white
                              : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              PaymentButton(
                text: selectedAmount != null
                    ? 'Add \$${selectedAmount!.toInt()}'
                    : 'Select Amount',
                onPressed: selectedAmount != null
                    ? () async {
                        Navigator.pop(context);
                        final provider = context.read<PaymentProvider>();
                        final success = await provider.addFundsToWallet(
                          selectedAmount!,
                        );
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Added \$${selectedAmount!.toInt()} to wallet',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    : null,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeletePaymentMethod(
    PaymentMethod method,
    PaymentProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: Text('Are you sure you want to delete ${method.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deletePaymentMethod(method.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackbar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCardInputDialog(bool isDark) {
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Card',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Card Number
              _buildCardInputField(
                controller: cardNumberController,
                label: 'Card Number',
                hint: '1234 5678 9012 3456',
                icon: Iconsax.card,
                isDark: isDark,
                keyboardType: TextInputType.number,
                maxLength: 19,
              ),
              const SizedBox(height: 16),

              // Expiry and CVV Row
              Row(
                children: [
                  Expanded(
                    child: _buildCardInputField(
                      controller: expiryController,
                      label: 'Expiry Date',
                      hint: 'MM/YY',
                      icon: Iconsax.calendar,
                      isDark: isDark,
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCardInputField(
                      controller: cvvController,
                      label: 'CVV',
                      hint: '123',
                      icon: Iconsax.lock,
                      isDark: isDark,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Cardholder Name
              _buildCardInputField(
                controller: nameController,
                label: 'Cardholder Name',
                hint: 'John Doe',
                icon: Iconsax.user,
                isDark: isDark,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 24),

              // Add Card Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Validate and save card
                    if (cardNumberController.text.isNotEmpty &&
                        expiryController.text.isNotEmpty &&
                        cvvController.text.isNotEmpty &&
                        nameController.text.isNotEmpty) {
                      Navigator.pop(context);
                      _saveCard(
                        cardNumberController.text,
                        expiryController.text,
                        cvvController.text,
                        nameController.text,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Add Card',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Secure note
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.shield_tick,
                    size: 16,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Your card info is encrypted and secure',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    int? maxLength,
    bool obscureText = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
        prefixIcon: Icon(
          icon,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        labelStyle: TextStyle(
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        hintStyle: TextStyle(
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
        ),
        filled: true,
        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
      ),
    );
  }

  Future<void> _saveCard(
    String cardNumber,
    String expiry,
    String cvv,
    String name,
  ) async {
    final provider = context.read<PaymentProvider>();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final success = await provider.addCardWithDetails(
      cardNumber: cardNumber,
      expiry: expiry,
      cvv: cvv,
      cardholderName: name,
    );

    // Hide loading indicator
    if (mounted) Navigator.pop(context);

    if (success && mounted) {
      // Refresh the payment methods list
      await _loadPaymentMethods();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Card ending in ${cardNumber.replaceAll(' ', '').substring(cardNumber.replaceAll(' ', '').length - 4)} added successfully',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add card. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
