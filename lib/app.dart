import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/auth/session_expired_notifier.dart';
import 'screens/login_page.dart';
import 'screens/splash_screen.dart';
import 'state/session_state.dart';

import 'core/theme/app_theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class TksApp extends StatefulWidget {
  const TksApp({super.key});

  @override
  State<TksApp> createState() => _TksAppState();
}

class _TksAppState extends State<TksApp> {
  final _sessionState = SessionState();

  @override
  void initState() {
    super.initState();
    SessionExpiredNotifier.instance.onSessionExpired = _handleSessionExpired;
  }

  void _handleSessionExpired() {
    _sessionState.logout();
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    SessionExpiredNotifier.instance.onSessionExpired = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _sessionState,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'TKS Academy',
        themeMode: ThemeMode.light,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
