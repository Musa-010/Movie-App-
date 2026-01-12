-- Supabase Migration for Payment System
-- Run this in Supabase SQL Editor to create the required tables

-- ============ PAYMENT METHODS TABLE ============
CREATE TABLE IF NOT EXISTS payment_methods (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  type TEXT NOT NULL DEFAULT 'card', -- 'card', 'apple_pay', 'google_pay'
  last4 TEXT,
  brand TEXT,
  expiry_month INTEGER,
  expiry_year INTEGER,
  is_default BOOLEAN DEFAULT false,
  stripe_payment_method_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE payment_methods ENABLE ROW LEVEL SECURITY;

-- Users can only see their own payment methods
CREATE POLICY "Users can view own payment methods" ON payment_methods
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own payment methods" ON payment_methods
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own payment methods" ON payment_methods
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own payment methods" ON payment_methods
  FOR DELETE USING (auth.uid() = user_id);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_payment_methods_user_id ON payment_methods(user_id);

-- ============ SUBSCRIPTIONS TABLE ============
CREATE TABLE IF NOT EXISTS subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
  plan_id TEXT NOT NULL,
  tier TEXT NOT NULL DEFAULT 'free', -- 'free', 'premium', 'vip'
  status TEXT NOT NULL DEFAULT 'active', -- 'active', 'cancelled', 'expired', 'pending'
  start_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  end_date TIMESTAMP WITH TIME ZONE,
  cancelled_at TIMESTAMP WITH TIME ZONE,
  stripe_subscription_id TEXT,
  stripe_customer_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- Users can only see their own subscriptions
CREATE POLICY "Users can view own subscriptions" ON subscriptions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own subscriptions" ON subscriptions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own subscriptions" ON subscriptions
  FOR UPDATE USING (auth.uid() = user_id);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status);

-- ============ PAYMENT HISTORY TABLE ============
CREATE TABLE IF NOT EXISTS payment_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  currency TEXT DEFAULT 'USD',
  status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'completed', 'failed', 'refunded', 'cancelled'
  type TEXT NOT NULL, -- 'subscription', 'rental', 'purchase'
  description TEXT,
  plan_id TEXT,
  movie_id TEXT,
  stripe_payment_intent_id TEXT,
  promo_code TEXT,
  discount_amount DECIMAL(10, 2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE
);

-- Enable RLS
ALTER TABLE payment_history ENABLE ROW LEVEL SECURITY;

-- Users can only see their own payment history
CREATE POLICY "Users can view own payment history" ON payment_history
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own payment history" ON payment_history
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_payment_history_user_id ON payment_history(user_id);
CREATE INDEX IF NOT EXISTS idx_payment_history_created_at ON payment_history(created_at DESC);

-- ============ WALLETS TABLE ============
CREATE TABLE IF NOT EXISTS wallets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
  balance DECIMAL(10, 2) DEFAULT 0.00,
  currency TEXT DEFAULT 'USD',
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;

-- Users can only see their own wallet
CREATE POLICY "Users can view own wallet" ON wallets
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own wallet" ON wallets
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own wallet" ON wallets
  FOR UPDATE USING (auth.uid() = user_id);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_wallets_user_id ON wallets(user_id);

-- ============ PROMO CODES TABLE ============
CREATE TABLE IF NOT EXISTS promo_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  description TEXT,
  discount_percent INTEGER DEFAULT 0,
  max_discount DECIMAL(10, 2),
  valid_from TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  valid_until TIMESTAMP WITH TIME ZONE,
  max_uses INTEGER,
  used_count INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE promo_codes ENABLE ROW LEVEL SECURITY;

-- Anyone can read active promo codes
CREATE POLICY "Anyone can view active promo codes" ON promo_codes
  FOR SELECT USING (is_active = true);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_promo_codes_code ON promo_codes(code);

-- ============ HELPER FUNCTIONS ============

-- Function to increment promo code usage
CREATE OR REPLACE FUNCTION increment_promo_usage(code_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE promo_codes
  SET used_count = used_count + 1
  WHERE id = code_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to add wallet funds
CREATE OR REPLACE FUNCTION add_wallet_funds(user_id_param UUID, amount_param DECIMAL)
RETURNS void AS $$
BEGIN
  INSERT INTO wallets (user_id, balance)
  VALUES (user_id_param, amount_param)
  ON CONFLICT (user_id)
  DO UPDATE SET
    balance = wallets.balance + amount_param,
    updated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to deduct wallet funds
CREATE OR REPLACE FUNCTION deduct_wallet_funds(user_id_param UUID, amount_param DECIMAL)
RETURNS void AS $$
BEGIN
  UPDATE wallets
  SET balance = balance - amount_param,
      updated_at = NOW()
  WHERE user_id = user_id_param
    AND balance >= amount_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============ ADD is_premium TO PROFILES (if not exists) ============
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'profiles' AND column_name = 'is_premium'
  ) THEN
    ALTER TABLE profiles ADD COLUMN is_premium BOOLEAN DEFAULT false;
  END IF;
END $$;

-- ============ INSERT SAMPLE PROMO CODE ============
INSERT INTO promo_codes (code, description, discount_percent, valid_until, max_uses, is_active)
VALUES ('DEMO20', '20% off your first subscription', 20, NOW() + INTERVAL '1 year', 1000, true)
ON CONFLICT (code) DO NOTHING;

-- Success message
SELECT 'Payment system tables created successfully!' AS result;
