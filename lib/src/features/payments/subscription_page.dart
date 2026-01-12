import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../core/models/subscription_model.dart';
import '../../core/providers/payment_provider.dart';
import '../../core/providers/theme_provider.dart';
import 'widgets/widgets.dart';
import 'checkout_page.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  SubscriptionPlan? _selectedPlan;
  bool _showYearly = false;

  @override
  void initState() {
    super.initState();
    // Load data after the first frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await context.read<PaymentProvider>().loadSubscription();
  }

  List<SubscriptionPlan> get _filteredPlans {
    final plans = SubscriptionPlan.defaultPlans;
    return plans.where((plan) {
      if (plan.tier == SubscriptionTier.free) return true;
      return _showYearly ? plan.interval == 'year' : plan.interval == 'month';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final paymentProvider = context.watch<PaymentProvider>();
    final currentSubscription = paymentProvider.subscription;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: paymentProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade400,
                                      Colors.blue.shade700,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Iconsax.crown1,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Upgrade Your Experience',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Choose a plan that works for you',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Monthly/Yearly toggle
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey.shade900
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildToggleButton(
                                  'Monthly',
                                  !_showYearly,
                                  () => setState(() => _showYearly = false),
                                  isDark,
                                ),
                                _buildToggleButton(
                                  'Yearly (Save 20%)',
                                  _showYearly,
                                  () => setState(() => _showYearly = true),
                                  isDark,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Plan cards
                        ..._filteredPlans.map((plan) {
                          final isCurrentPlan =
                              currentSubscription?.planId == plan.id;
                          return PlanCard(
                            plan: plan,
                            isSelected: _selectedPlan?.id == plan.id,
                            isCurrentPlan: isCurrentPlan,
                            onTap: () {
                              setState(() {
                                _selectedPlan = plan;
                              });
                            },
                          );
                        }),

                        const SizedBox(height: 16),

                        // Features comparison link
                        Center(
                          child: TextButton(
                            onPressed: () {
                              _showFeaturesComparison(context, isDark);
                            },
                            child: Text(
                              'Compare all features',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom CTA
                Container(
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
                    child: Column(
                      children: [
                        if (_selectedPlan != null &&
                            _selectedPlan!.tier != SubscriptionTier.free)
                          PaymentButton(
                            text:
                                'Continue with ${_selectedPlan!.name} - \$${_selectedPlan!.price.toStringAsFixed(2)}/${_selectedPlan!.interval}',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CheckoutPage(plan: _selectedPlan!),
                                ),
                              );
                            },
                          )
                        else if (_selectedPlan?.tier == SubscriptionTier.free)
                          PaymentButton(
                            text: 'Continue with Free Plan',
                            isOutlined: true,
                            onPressed: () async {
                              final success = await paymentProvider
                                  .subscribeToPlan(_selectedPlan!);
                              if (success && mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'You are now on the Free plan',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                          )
                        else
                          PaymentButton(text: 'Select a Plan', onPressed: null),

                        const SizedBox(height: 12),

                        Text(
                          'Cancel anytime. No hidden fees.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildToggleButton(
    String text,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade700 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : isDark
                ? Colors.grey.shade400
                : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  void _showFeaturesComparison(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Features Comparison',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            // Table
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildComparisonTable(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable(bool isDark) {
    final features = [
      ('Browse Movies', true, true, true),
      ('View Trailers', true, true, true),
      ('Basic Search', true, true, true),
      ('Watchlist', '10', 'Unlimited', 'Unlimited'),
      ('Ad-Free', false, true, true),
      ('HD Streaming', false, true, true),
      ('Download Offline', false, true, true),
      ('Early Access', false, true, true),
      ('4K Ultra HD', false, false, true),
      ('Dolby Atmos', false, false, true),
      ('Exclusive Content', false, false, true),
      ('Family Sharing', false, false, '5 members'),
      ('Priority Support', false, false, true),
    ];

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      children: [
        // Header
        TableRow(
          children: [
            _buildTableHeader('Feature', isDark),
            _buildTableHeader('Free', isDark),
            _buildTableHeader('Premium', isDark),
            _buildTableHeader('VIP', isDark),
          ],
        ),
        // Features
        ...features.map(
          (f) => TableRow(
            children: [
              _buildTableCell(f.$1, isDark),
              _buildTableValue(f.$2, isDark),
              _buildTableValue(f.$3, isDark),
              _buildTableValue(f.$4, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildTableValue(dynamic value, bool isDark) {
    if (value is bool) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Icon(
          value ? Icons.check_circle : Icons.remove_circle_outline,
          color: value ? Colors.green : Colors.grey,
          size: 20,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        value.toString(),
        style: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
