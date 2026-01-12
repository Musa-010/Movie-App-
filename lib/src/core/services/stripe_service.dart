import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment_model.dart' as models;
import '../models/subscription_model.dart';

class StripeService {
  static const String _publishableKey = 'pk_test_YOUR_STRIPE_PUBLISHABLE_KEY';
  // Note: In production, the secret key should NEVER be in client code
  // Use Supabase Edge Functions or a backend server for sensitive operations

  // Set to true to save data to Supabase, false for local-only demo
  static const bool _saveToSupabase = true;

  // Local fallback storage (used when Supabase fails)
  static final List<models.PaymentMethod> _localPaymentMethods = [];
  static final List<models.PaymentHistory> _localPaymentHistory = [];
  static UserSubscription? _localSubscription;

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Initialize Stripe - wrapped in try-catch to prevent app crash
  static Future<void> initialize() async {
    debugPrint(
      'Stripe service initialized - saving to Supabase: $_saveToSupabase',
    );
    try {
      Stripe.publishableKey = _publishableKey;
      // Only apply settings if we have a valid key
      if (_publishableKey.startsWith('pk_test_') ||
          _publishableKey.startsWith('pk_live_')) {
        await Stripe.instance.applySettings();
      }
      debugPrint('Stripe initialized');
    } catch (e) {
      // Don't crash the app if Stripe fails to initialize
      debugPrint('Stripe initialization failed: $e');
    }
  }

  /// Get current user ID
  String? get _userId => _supabase.auth.currentUser?.id;

  // ============ SUBSCRIPTION METHODS ============

  /// Get user's current subscription
  Future<UserSubscription?> getUserSubscription() async {
    try {
      if (_userId == null) return null;

      // Try to get from Supabase
      if (_saveToSupabase) {
        try {
          final response = await _supabase
              .from('subscriptions')
              .select()
              .eq('user_id', _userId!)
              .eq('status', 'active')
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();

          if (response != null) {
            debugPrint('Loaded subscription from Supabase');
            return UserSubscription.fromJson(response);
          }
        } catch (e) {
          debugPrint('Supabase subscription fetch failed: $e');
          // Fall back to local
          if (_localSubscription != null) {
            return _localSubscription;
          }
        }
      }

      // Return local subscription as fallback
      return _localSubscription;
    } catch (e) {
      debugPrint('Error getting subscription: $e');
      return _localSubscription;
    }
  }

  /// Create a subscription checkout session
  /// In production, this should call a Supabase Edge Function
  Future<Map<String, dynamic>?> createSubscriptionCheckout(
    SubscriptionPlan plan,
  ) async {
    try {
      if (_userId == null) throw Exception('User not logged in');

      // In production, call your backend/edge function to create a checkout session
      // For now, we'll use a simplified flow with payment sheet

      // This would typically be an Edge Function call:
      // final response = await _supabase.functions.invoke('create-checkout', body: {
      //   'priceId': plan.stripePriceId,
      //   'userId': _userId,
      // });

      // For demo purposes, we'll simulate the response
      return {
        'clientSecret': 'pi_demo_secret', // This would come from your backend
        'customerId': 'cus_demo',
      };
    } catch (e) {
      debugPrint('Error creating checkout: $e');
      return null;
    }
  }

  /// Subscribe to a plan
  Future<bool> subscribeToPlan(SubscriptionPlan plan) async {
    try {
      if (_userId == null) throw Exception('User not logged in');

      // For free plan, just update the database
      if (plan.tier == SubscriptionTier.free) {
        final subscription = UserSubscription(
          id: 'sub_free_${DateTime.now().millisecondsSinceEpoch}',
          userId: _userId!,
          planId: 'free',
          tier: SubscriptionTier.free,
          status: SubscriptionStatus.active,
          startDate: DateTime.now(),
        );
        _localSubscription = subscription;

        if (_saveToSupabase) {
          await _createFreeSubscription();
        }
        return true;
      }

      // Simulate payment processing
      debugPrint('Processing payment for ${plan.name}');
      await Future.delayed(const Duration(seconds: 1));

      final endDate = plan.interval == 'year'
          ? DateTime.now().add(const Duration(days: 365))
          : DateTime.now().add(const Duration(days: 30));

      final subscription = UserSubscription(
        id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
        userId: _userId!,
        planId: plan.id,
        tier: plan.tier,
        status: SubscriptionStatus.active,
        startDate: DateTime.now(),
        endDate: endDate,
        stripeCustomerId: 'cus_$_userId',
      );

      // Save locally
      _localSubscription = subscription;

      // Save to Supabase
      if (_saveToSupabase) {
        try {
          await _supabase.from('subscriptions').upsert({
            'user_id': _userId,
            'plan_id': plan.id,
            'tier': plan.tier.name,
            'status': SubscriptionStatus.active.name,
            'start_date': DateTime.now().toIso8601String(),
            'end_date': endDate.toIso8601String(),
            'stripe_customer_id': 'cus_$_userId',
          }, onConflict: 'user_id');
          debugPrint('Subscription saved to Supabase');

          // Update user's premium status
          await _supabase
              .from('profiles')
              .update({
                'is_premium':
                    plan.tier == SubscriptionTier.premium ||
                    plan.tier == SubscriptionTier.vip,
              })
              .eq('id', _userId!);
        } catch (e) {
          debugPrint('Failed to save subscription to Supabase: $e');
          // Continue - we still have it locally
        }
      }

      // Add to payment history
      final paymentRecord = models.PaymentHistory(
        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        userId: _userId!,
        amount: plan.price,
        currency: 'USD',
        status: models.PaymentStatus.completed,
        type: models.PaymentType.subscription,
        description: '${plan.name} subscription',
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );
      _localPaymentHistory.insert(0, paymentRecord);

      // Save payment history to Supabase
      if (_saveToSupabase) {
        try {
          await _supabase.from('payment_history').insert({
            'user_id': _userId,
            'amount': plan.price,
            'currency': 'USD',
            'status': models.PaymentStatus.completed.name,
            'type': models.PaymentType.subscription.name,
            'description': '${plan.name} subscription',
            'created_at': DateTime.now().toIso8601String(),
            'completed_at': DateTime.now().toIso8601String(),
          });
          debugPrint('Payment history saved to Supabase');
        } catch (e) {
          debugPrint('Failed to save payment history to Supabase: $e');
        }
      }

      return true;
    } on StripeException catch (e) {
      debugPrint('Stripe error: ${e.error.localizedMessage}');
      return false;
    } catch (e) {
      debugPrint('Error subscribing: $e');
      return false;
    }
  }

  Future<void> _createFreeSubscription() async {
    try {
      final now = DateTime.now();
      await _supabase.from('subscriptions').upsert({
        'user_id': _userId,
        'plan_id': 'free',
        'tier': SubscriptionTier.free.name,
        'status': SubscriptionStatus.active.name,
        'start_date': now.toIso8601String(),
        'end_date': null,
      }, onConflict: 'user_id');

      // Update user's premium status
      await _supabase
          .from('profiles')
          .update({'is_premium': false})
          .eq('id', _userId!);
    } catch (e) {
      debugPrint('Error creating free subscription in DB: $e');
      // Continue anyway in demo mode
    }
  }

  /// Cancel subscription
  Future<bool> cancelSubscription() async {
    try {
      if (_userId == null) return false;

      await _supabase
          .from('subscriptions')
          .update({
            'status': SubscriptionStatus.cancelled.name,
            'cancelled_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', _userId!);

      await _supabase
          .from('profiles')
          .update({'is_premium': false})
          .eq('id', _userId!);

      return true;
    } catch (e) {
      debugPrint('Error cancelling subscription: $e');
      return false;
    }
  }

  // ============ PAYMENT METHODS ============

  /// Get user's saved payment methods
  Future<List<models.PaymentMethod>> getPaymentMethods() async {
    try {
      if (_userId == null) return [];

      // Try to get from Supabase first
      if (_saveToSupabase) {
        try {
          final response = await _supabase
              .from('payment_methods')
              .select()
              .eq('user_id', _userId!)
              .order('is_default', ascending: false);

          if ((response as List).isNotEmpty) {
            debugPrint(
              'Loaded ${response.length} payment methods from Supabase',
            );
            final methods = response
                .map((json) => models.PaymentMethod.fromJson(json))
                .toList();
            // Sync to local
            _localPaymentMethods.clear();
            _localPaymentMethods.addAll(methods);
            return methods;
          }
        } catch (e) {
          debugPrint('Supabase payment methods fetch failed: $e');
        }
      }

      // Return local payment methods as fallback
      debugPrint(
        'Returning ${_localPaymentMethods.length} local payment methods',
      );
      return _localPaymentMethods;
    } catch (e) {
      debugPrint('Error getting payment methods: $e');
      return _localPaymentMethods;
    }
  }

  /// Add a new payment method
  Future<bool> addPaymentMethod() async {
    try {
      if (_userId == null) return false;

      // Simulate success
      debugPrint('Simulating add payment method');
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      debugPrint('Error adding payment method: $e');
      return false;
    }
  }

  /// Add card with manual details
  Future<bool> addCardWithDetails({
    required String cardNumber,
    required String expiry,
    required String cvv,
    required String cardholderName,
  }) async {
    try {
      if (_userId == null) return false;

      // Clean card number (remove spaces)
      final cleanCardNumber = cardNumber.replaceAll(' ', '');

      // Determine card brand
      String brand = 'unknown';
      if (cleanCardNumber.startsWith('4')) {
        brand = 'visa';
      } else if (cleanCardNumber.startsWith('5') ||
          cleanCardNumber.startsWith('2')) {
        brand = 'mastercard';
      } else if (cleanCardNumber.startsWith('3')) {
        brand = 'amex';
      } else if (cleanCardNumber.startsWith('6')) {
        brand = 'discover';
      }

      final last4 = cleanCardNumber.length >= 4
          ? cleanCardNumber.substring(cleanCardNumber.length - 4)
          : cleanCardNumber;

      debugPrint('Adding card ending in $last4');
      await Future.delayed(const Duration(milliseconds: 800));

      final isFirst = _localPaymentMethods.isEmpty;
      final cardId = 'pm_${DateTime.now().millisecondsSinceEpoch}';

      final newCard = models.PaymentMethod(
        id: cardId,
        userId: _userId!,
        type: 'card',
        brand: brand,
        last4: last4,
        expiryMonth: int.tryParse(expiry.split('/')[0]) ?? 12,
        expiryYear: int.tryParse('20${expiry.split('/').last}') ?? 2030,
        isDefault: isFirst,
        createdAt: DateTime.now(),
      );

      // Save locally
      _localPaymentMethods.add(newCard);

      // Save to Supabase
      if (_saveToSupabase) {
        try {
          await _supabase.from('payment_methods').insert({
            'id': cardId,
            'user_id': _userId,
            'type': 'card',
            'brand': brand,
            'last4': last4,
            'expiry_month': newCard.expiryMonth,
            'expiry_year': newCard.expiryYear,
            'is_default': isFirst,
            'created_at': DateTime.now().toIso8601String(),
          });
          debugPrint('Card saved to Supabase');
        } catch (e) {
          debugPrint('Failed to save card to Supabase: $e');
          // Continue - we still have it locally
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error adding card: $e');
      return false;
    }
  }

  /// Delete a payment method
  Future<bool> deletePaymentMethod(String paymentMethodId) async {
    try {
      if (_userId == null) return false;

      // Remove from local list
      _localPaymentMethods.removeWhere((m) => m.id == paymentMethodId);

      // Delete from Supabase
      if (_saveToSupabase) {
        try {
          await _supabase
              .from('payment_methods')
              .delete()
              .eq('id', paymentMethodId)
              .eq('user_id', _userId!);
          debugPrint('Card deleted from Supabase');
        } catch (e) {
          debugPrint('Failed to delete card from Supabase: $e');
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error deleting payment method: $e');
      return false;
    }
  }

  /// Set default payment method
  Future<bool> setDefaultPaymentMethod(String paymentMethodId) async {
    try {
      if (_userId == null) return false;

      // Update local list
      for (var i = 0; i < _localPaymentMethods.length; i++) {
        final method = _localPaymentMethods[i];
        _localPaymentMethods[i] = models.PaymentMethod(
          id: method.id,
          userId: method.userId,
          type: method.type,
          brand: method.brand,
          last4: method.last4,
          expiryMonth: method.expiryMonth,
          expiryYear: method.expiryYear,
          isDefault: method.id == paymentMethodId,
          createdAt: method.createdAt,
        );
      }

      // Update in Supabase
      if (_saveToSupabase) {
        try {
          // Remove default from all
          await _supabase
              .from('payment_methods')
              .update({'is_default': false})
              .eq('user_id', _userId!);

          // Set new default
          await _supabase
              .from('payment_methods')
              .update({'is_default': true})
              .eq('id', paymentMethodId);
          debugPrint('Default card updated in Supabase');
        } catch (e) {
          debugPrint('Failed to update default card in Supabase: $e');
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error setting default payment method: $e');
      return false;
    }
  }

  // ============ PAYMENT HISTORY ============

  /// Get payment history
  Future<List<models.PaymentHistory>> getPaymentHistory() async {
    try {
      if (_userId == null) return [];

      // Try to get from Supabase first
      if (_saveToSupabase) {
        try {
          final response = await _supabase
              .from('payment_history')
              .select()
              .eq('user_id', _userId!)
              .order('created_at', ascending: false);

          if ((response as List).isNotEmpty) {
            debugPrint(
              'Loaded ${response.length} payment history items from Supabase',
            );
            final history = response
                .map((json) => models.PaymentHistory.fromJson(json))
                .toList();
            // Sync to local
            _localPaymentHistory.clear();
            _localPaymentHistory.addAll(history);
            return history;
          }
        } catch (e) {
          debugPrint('Supabase payment history fetch failed: $e');
        }
      }

      // Return local payment history as fallback
      debugPrint(
        'Returning ${_localPaymentHistory.length} local payment history items',
      );
      return _localPaymentHistory;
    } catch (e) {
      debugPrint('Error getting payment history: $e');
      return _localPaymentHistory;
    }
  }

  /// Record a payment
  Future<void> recordPayment({
    required double amount,
    required models.PaymentType type,
    required models.PaymentStatus status,
    String? description,
    String? planId,
    String? movieId,
    String? promoCode,
    double? discountAmount,
  }) async {
    try {
      if (_userId == null) return;

      await _supabase.from('payment_history').insert({
        'user_id': _userId,
        'amount': amount,
        'currency': 'USD',
        'status': status.name,
        'type': type.name,
        'description': description,
        'plan_id': planId,
        'movie_id': movieId,
        'promo_code': promoCode,
        'discount_amount': discountAmount,
        'created_at': DateTime.now().toIso8601String(),
        'completed_at': status == models.PaymentStatus.completed
            ? DateTime.now().toIso8601String()
            : null,
      });
    } catch (e) {
      debugPrint('Error recording payment: $e');
    }
  }

  // ============ PROMO CODES ============

  /// Validate a promo code
  Future<models.PromoCode?> validatePromoCode(String code) async {
    try {
      // Try to validate from Supabase
      if (_saveToSupabase) {
        try {
          final response = await _supabase
              .from('promo_codes')
              .select()
              .eq('code', code.toUpperCase())
              .eq('is_active', true)
              .maybeSingle();

          if (response != null) {
            final promoCode = models.PromoCode.fromJson(response);
            return promoCode.isValid ? promoCode : null;
          }
        } catch (e) {
          debugPrint('Supabase promo code fetch failed: $e');
        }
      }

      // Fallback: Accept "DEMO20" as a valid 20% off code
      if (code.toUpperCase() == 'DEMO20') {
        debugPrint('Using fallback promo code DEMO20');
        return models.PromoCode(
          id: 'demo_promo',
          code: 'DEMO20',
          description: '20% off (Demo)',
          discountPercent: 20,
          validUntil: DateTime.now().add(const Duration(days: 30)),
          maxUses: 100,
          usedCount: 0,
          isActive: true,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error validating promo code: $e');
      return null;
    }
  }

  /// Apply promo code (increment usage)
  Future<void> applyPromoCode(String codeId) async {
    if (!_saveToSupabase) return;
    try {
      await _supabase.rpc('increment_promo_usage', params: {'code_id': codeId});
    } catch (e) {
      debugPrint('Error applying promo code: $e');
    }
  }

  // ============ WALLET ============

  // Local wallet balance for fallback
  static double _localWalletBalance = 25.00;

  /// Get wallet balance
  Future<models.WalletBalance?> getWalletBalance() async {
    try {
      if (_userId == null) return null;

      // Try to get from Supabase first
      if (_saveToSupabase) {
        try {
          final response = await _supabase
              .from('wallets')
              .select()
              .eq('user_id', _userId!)
              .maybeSingle();

          if (response != null) {
            debugPrint('Loaded wallet from Supabase');
            final wallet = models.WalletBalance.fromJson(response);
            _localWalletBalance = wallet.balance;
            return wallet;
          } else {
            // Create wallet if doesn't exist
            final newWallet = {
              'user_id': _userId,
              'balance': 0.0,
              'currency': 'USD',
              'updated_at': DateTime.now().toIso8601String(),
            };
            await _supabase.from('wallets').insert(newWallet);
            _localWalletBalance = 0.0;
            return models.WalletBalance.fromJson(newWallet);
          }
        } catch (e) {
          debugPrint('Supabase wallet fetch failed: $e');
        }
      }

      // Return local wallet as fallback
      debugPrint('Returning local wallet balance: $_localWalletBalance');
      return models.WalletBalance(
        userId: _userId!,
        balance: _localWalletBalance,
        currency: 'USD',
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error getting wallet balance: $e');
      return null;
    }
  }

  /// Add funds to wallet
  Future<bool> addFundsToWallet(double amount) async {
    try {
      if (_userId == null) return false;

      // In production, process payment first
      // Then update wallet balance

      await _supabase.rpc(
        'add_wallet_funds',
        params: {'user_id_param': _userId, 'amount_param': amount},
      );

      await recordPayment(
        amount: amount,
        type: models.PaymentType.purchase,
        status: models.PaymentStatus.completed,
        description: 'Added funds to wallet',
      );

      return true;
    } catch (e) {
      debugPrint('Error adding funds: $e');
      return false;
    }
  }

  /// Use wallet balance for payment
  Future<bool> useWalletBalance(double amount, String description) async {
    try {
      if (_userId == null) return false;

      final wallet = await getWalletBalance();
      if (wallet == null || wallet.balance < amount) {
        return false;
      }

      await _supabase.rpc(
        'deduct_wallet_funds',
        params: {'user_id_param': _userId, 'amount_param': amount},
      );

      return true;
    } catch (e) {
      debugPrint('Error using wallet balance: $e');
      return false;
    }
  }

  // ============ ONE-TIME PURCHASES ============

  /// Rent a movie
  Future<bool> rentMovie(String movieId, double price) async {
    try {
      if (_userId == null) return false;

      // Process payment (simplified for demo)
      // In production, use payment sheet

      await recordPayment(
        amount: price,
        type: models.PaymentType.rental,
        status: models.PaymentStatus.completed,
        description: 'Movie rental',
        movieId: movieId,
      );

      // Grant rental access (expires in 48 hours)
      await _supabase.from('movie_rentals').insert({
        'user_id': _userId,
        'movie_id': movieId,
        'rented_at': DateTime.now().toIso8601String(),
        'expires_at': DateTime.now()
            .add(const Duration(hours: 48))
            .toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Error renting movie: $e');
      return false;
    }
  }

  /// Purchase a movie
  Future<bool> purchaseMovie(String movieId, double price) async {
    try {
      if (_userId == null) return false;

      await recordPayment(
        amount: price,
        type: models.PaymentType.purchase,
        status: models.PaymentStatus.completed,
        description: 'Movie purchase',
        movieId: movieId,
      );

      // Grant permanent access
      await _supabase.from('movie_purchases').insert({
        'user_id': _userId,
        'movie_id': movieId,
        'purchased_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Error purchasing movie: $e');
      return false;
    }
  }

  /// Check if user has access to a movie
  Future<bool> hasMovieAccess(String movieId) async {
    try {
      if (_userId == null) return false;

      // Check subscription
      final subscription = await getUserSubscription();
      if (subscription?.isPremiumOrAbove == true) {
        return true;
      }

      // Check purchase
      final purchase = await _supabase
          .from('movie_purchases')
          .select()
          .eq('user_id', _userId!)
          .eq('movie_id', movieId)
          .maybeSingle();

      if (purchase != null) return true;

      // Check active rental
      final rental = await _supabase
          .from('movie_rentals')
          .select()
          .eq('user_id', _userId!)
          .eq('movie_id', movieId)
          .gt('expires_at', DateTime.now().toIso8601String())
          .maybeSingle();

      return rental != null;
    } catch (e) {
      debugPrint('Error checking movie access: $e');
      return false;
    }
  }
}
