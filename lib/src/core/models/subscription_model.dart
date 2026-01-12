enum SubscriptionTier { free, premium, vip }

enum SubscriptionStatus { active, cancelled, expired, pending }

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String interval; // 'month' or 'year'
  final SubscriptionTier tier;
  final List<String> features;
  final String? stripePriceId;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.currency = 'USD',
    required this.interval,
    required this.tier,
    required this.features,
    this.stripePriceId,
    this.isPopular = false,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      interval: json['interval'] ?? 'month',
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      features: List<String>.from(json['features'] ?? []),
      stripePriceId: json['stripe_price_id'],
      isPopular: json['is_popular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'interval': interval,
      'tier': tier.name,
      'features': features,
      'stripe_price_id': stripePriceId,
      'is_popular': isPopular,
    };
  }

  // Default plans
  static List<SubscriptionPlan> get defaultPlans => [
    const SubscriptionPlan(
      id: 'free',
      name: 'Free',
      description: 'Basic access to movies',
      price: 0,
      interval: 'month',
      tier: SubscriptionTier.free,
      features: [
        'Browse movies',
        'View trailers',
        'Basic search',
        'Limited watchlist (10 movies)',
      ],
    ),
    const SubscriptionPlan(
      id: 'premium_monthly',
      name: 'Premium',
      description: 'Full access to all features',
      price: 9.99,
      interval: 'month',
      tier: SubscriptionTier.premium,
      features: [
        'Everything in Free',
        'Ad-free experience',
        'HD streaming',
        'Unlimited watchlist',
        'Download for offline',
        'Early access to new releases',
      ],
      stripePriceId: 'price_premium_monthly',
      isPopular: true,
    ),
    const SubscriptionPlan(
      id: 'premium_yearly',
      name: 'Premium Yearly',
      description: 'Full access - Save 20%',
      price: 95.88,
      interval: 'year',
      tier: SubscriptionTier.premium,
      features: [
        'Everything in Free',
        'Ad-free experience',
        'HD streaming',
        'Unlimited watchlist',
        'Download for offline',
        'Early access to new releases',
        '2 months free!',
      ],
      stripePriceId: 'price_premium_yearly',
    ),
    const SubscriptionPlan(
      id: 'vip_monthly',
      name: 'VIP',
      description: 'Ultimate movie experience',
      price: 19.99,
      interval: 'month',
      tier: SubscriptionTier.vip,
      features: [
        'Everything in Premium',
        '4K Ultra HD',
        'Dolby Atmos sound',
        'Exclusive VIP content',
        'Priority customer support',
        'Family sharing (up to 5)',
        'Exclusive premiere invites',
      ],
      stripePriceId: 'price_vip_monthly',
    ),
  ];
}

class UserSubscription {
  final String id;
  final String userId;
  final String planId;
  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? cancelledAt;
  final String? stripeSubscriptionId;
  final String? stripeCustomerId;

  const UserSubscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.tier,
    required this.status,
    required this.startDate,
    this.endDate,
    this.cancelledAt,
    this.stripeSubscriptionId,
    this.stripeCustomerId,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      planId: json['plan_id'] ?? '',
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.active,
      ),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'])
          : null,
      stripeSubscriptionId: json['stripe_subscription_id'],
      stripeCustomerId: json['stripe_customer_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_id': planId,
      'tier': tier.name,
      'status': status.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'stripe_subscription_id': stripeSubscriptionId,
      'stripe_customer_id': stripeCustomerId,
    };
  }

  bool get isActive => status == SubscriptionStatus.active;
  bool get isPremiumOrAbove =>
      tier == SubscriptionTier.premium || tier == SubscriptionTier.vip;
  bool get isVip => tier == SubscriptionTier.vip;
}
