import 'package:flutter/foundation.dart';
import '../models/payment_model.dart';
import '../models/subscription_model.dart';
import '../services/stripe_service.dart';

class PaymentProvider extends ChangeNotifier {
  final StripeService _stripeService = StripeService();

  bool _isLoading = false;
  String? _errorMessage;
  UserSubscription? _subscription;
  List<PaymentMethod> _paymentMethods = [];
  List<PaymentHistory> _paymentHistory = [];
  WalletBalance? _wallet;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserSubscription? get subscription => _subscription;
  List<PaymentMethod> get paymentMethods => _paymentMethods;
  List<PaymentHistory> get paymentHistory => _paymentHistory;
  WalletBalance? get wallet => _wallet;

  bool get isPremium => _subscription?.isPremiumOrAbove ?? false;
  bool get isVip => _subscription?.isVip ?? false;
  SubscriptionTier get currentTier =>
      _subscription?.tier ?? SubscriptionTier.free;

  // ============ SUBSCRIPTION ============

  /// Load user's subscription
  Future<void> loadSubscription() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _subscription = await _stripeService.getUserSubscription();
    } catch (e) {
      _errorMessage = 'Failed to load subscription';
      debugPrint('Error loading subscription: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Subscribe to a plan
  Future<bool> subscribeToPlan(SubscriptionPlan plan) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _stripeService.subscribeToPlan(plan);
      if (success) {
        await loadSubscription();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Failed to subscribe';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cancel subscription
  Future<bool> cancelSubscription() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _stripeService.cancelSubscription();
      if (success) {
        await loadSubscription();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Failed to cancel subscription';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============ PAYMENT METHODS ============

  /// Load payment methods
  Future<void> loadPaymentMethods() async {
    _isLoading = true;
    notifyListeners();

    try {
      _paymentMethods = await _stripeService.getPaymentMethods();
      await loadWallet();
    } catch (e) {
      debugPrint('Error loading payment methods: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Add payment method
  Future<bool> addPaymentMethod() async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _stripeService.addPaymentMethod();
      if (success) {
        await loadPaymentMethods();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Add card with details
  Future<bool> addCardWithDetails({
    required String cardNumber,
    required String expiry,
    required String cvv,
    required String cardholderName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _stripeService.addCardWithDetails(
        cardNumber: cardNumber,
        expiry: expiry,
        cvv: cvv,
        cardholderName: cardholderName,
      );
      if (success) {
        await loadPaymentMethods();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('Error adding card: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete payment method
  Future<bool> deletePaymentMethod(String id) async {
    try {
      final success = await _stripeService.deletePaymentMethod(id);
      if (success) {
        _paymentMethods.removeWhere((m) => m.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Set default payment method
  Future<bool> setDefaultPaymentMethod(String id) async {
    try {
      final success = await _stripeService.setDefaultPaymentMethod(id);
      if (success) {
        await loadPaymentMethods();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // ============ PAYMENT HISTORY ============

  /// Load payment history
  Future<void> loadPaymentHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      _paymentHistory = await _stripeService.getPaymentHistory();
    } catch (e) {
      debugPrint('Error loading payment history: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ============ PROMO CODES ============

  /// Validate promo code
  Future<PromoCode?> validatePromoCode(String code) async {
    try {
      return await _stripeService.validatePromoCode(code);
    } catch (e) {
      return null;
    }
  }

  /// Apply promo code
  Future<void> applyPromoCode(String codeId) async {
    await _stripeService.applyPromoCode(codeId);
  }

  // ============ WALLET ============

  /// Load wallet balance
  Future<void> loadWallet() async {
    try {
      _wallet = await _stripeService.getWalletBalance();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading wallet: $e');
    }
  }

  /// Add funds to wallet
  Future<bool> addFundsToWallet(double amount) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _stripeService.addFundsToWallet(amount);
      if (success) {
        await loadWallet();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Use wallet balance
  Future<bool> useWalletBalance(double amount, String description) async {
    try {
      final success = await _stripeService.useWalletBalance(
        amount,
        description,
      );
      if (success) {
        await loadWallet();
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // ============ MOVIE PURCHASES ============

  /// Rent a movie
  Future<bool> rentMovie(String movieId, double price) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _stripeService.rentMovie(movieId, price);
      if (success) {
        await loadPaymentHistory();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Purchase a movie
  Future<bool> purchaseMovie(String movieId, double price) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _stripeService.purchaseMovie(movieId, price);
      if (success) {
        await loadPaymentHistory();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Check movie access
  Future<bool> hasMovieAccess(String movieId) async {
    return await _stripeService.hasMovieAccess(movieId);
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
