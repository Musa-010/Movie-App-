import 'package:flutter/material.dart';

import 'core/constants/constants.dart';
import 'features/auth/auth_wrapper.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: AppTheme.light,
      home: const AuthWrapper(),
    );
  }
}
