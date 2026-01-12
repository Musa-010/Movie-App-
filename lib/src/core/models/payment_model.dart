enum PaymentStatus { pending, completed, failed, refunded, cancelled }

enum PaymentType { subscription, rental, purchase }

class PaymentMethod {
  final String id;
  final String userId;
  final String type; // 'card', 'apple_pay', 'google_pay'
  final String? last4;
  final String? brand;
  final int? expiryMonth;
  final int? expiryYear;
  final bool isDefault;
  final String? stripePaymentMethodId;
  final DateTime createdAt;

  const PaymentMethod({
    required this.id,
    required this.userId,
    required this.type,
    this.last4,
    this.brand,
    this.expiryMonth,
    this.expiryYear,
    this.isDefault = false,
    this.stripePaymentMethodId,
    required this.createdAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      type: json['type'] ?? 'card',
      last4: json['last4'],
      brand: json['brand'],
      expiryMonth: json['expiry_month'],
      expiryYear: json['expiry_year'],
      isDefault: json['is_default'] ?? false,
      stripePaymentMethodId: json['stripe_payment_method_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'last4': last4,
      'brand': brand,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'is_default': isDefault,
      'stripe_payment_method_id': stripePaymentMethodId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get displayName {
    if (type == 'apple_pay') return 'Apple Pay';
    if (type == 'google_pay') return 'Google Pay';
    return '${brand ?? 'Card'} •••• $last4';
  }

  String get expiryDate {
    if (expiryMonth == null || expiryYear == null) return '';
    return '${expiryMonth.toString().padLeft(2, '0')}/${expiryYear.toString().substring(2)}';
  }
}

class PaymentHistory {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final PaymentType type;
  final String? description;
  final String? planId;
  final String? movieId;
  final String? stripePaymentIntentId;
  final String? promoCode;
  final double? discountAmount;
  final DateTime createdAt;
  final DateTime? completedAt;

  const PaymentHistory({
    required this.id,
    required this.userId,
    required this.amount,
    this.currency = 'USD',
    required this.status,
    required this.type,
    this.description,
    this.planId,
    this.movieId,
    this.stripePaymentIntentId,
    this.promoCode,
    this.discountAmount,
    required this.createdAt,
    this.completedAt,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      type: PaymentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PaymentType.subscription,
      ),
      description: json['description'],
      planId: json['plan_id'],
      movieId: json['movie_id'],
      stripePaymentIntentId: json['stripe_payment_intent_id'],
      promoCode: json['promo_code'],
      discountAmount: json['discount_amount']?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'currency': currency,
      'status': status.name,
      'type': type.name,
      'description': description,
      'plan_id': planId,
      'movie_id': movieId,
      'stripe_payment_intent_id': stripePaymentIntentId,
      'promo_code': promoCode,
      'discount_amount': discountAmount,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  double get finalAmount => amount - (discountAmount ?? 0);
}

class PromoCode {
  final String id;
  final String code;
  final String? description;
  final double discountPercent;
  final double? maxDiscount;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final int? maxUses;
  final int usedCount;
  final bool isActive;

  const PromoCode({
    required this.id,
    required this.code,
    this.description,
    required this.discountPercent,
    this.maxDiscount,
    this.validFrom,
    this.validUntil,
    this.maxUses,
    this.usedCount = 0,
    this.isActive = true,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      description: json['description'],
      discountPercent: (json['discount_percent'] ?? 0).toDouble(),
      maxDiscount: json['max_discount']?.toDouble(),
      validFrom: json['valid_from'] != null
          ? DateTime.parse(json['valid_from'])
          : null,
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'])
          : null,
      maxUses: json['max_uses'],
      usedCount: json['used_count'] ?? 0,
      isActive: json['is_active'] ?? true,
    );
  }

  bool get isValid {
    if (!isActive) return false;
    final now = DateTime.now();
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;
    if (maxUses != null && usedCount >= maxUses!) return false;
    return true;
  }

  double calculateDiscount(double amount) {
    double discount = amount * (discountPercent / 100);
    if (maxDiscount != null && discount > maxDiscount!) {
      return maxDiscount!;
    }
    return discount;
  }
}

class WalletBalance {
  final String userId;
  final double balance;
  final String currency;
  final DateTime updatedAt;

  const WalletBalance({
    required this.userId,
    required this.balance,
    this.currency = 'USD',
    required this.updatedAt,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      userId: json['user_id'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'balance': balance,
      'currency': currency,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
