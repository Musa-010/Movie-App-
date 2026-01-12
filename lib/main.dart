import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'src/app.dart';
import 'src/core/config/supabase_config.dart';
import 'src/core/providers/auth_provider.dart';
import 'src/core/providers/theme_provider.dart';
import 'src/core/providers/payment_provider.dart';
import 'src/core/services/stripe_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Initialize Stripe (non-blocking - app continues if it fails)
  try {
    await StripeService.initialize();
  } catch (e) {
    debugPrint('Stripe init error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: const App(),
    ),
  );
}
