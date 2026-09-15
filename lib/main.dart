import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/di/di.dart';
import 'core/routes_manager/route_generator.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/widgets/network_status_listener.dart';
import 'splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/client_home.dart';
import 'features/home/presentation/screens/admin_home.dart';
import 'features/home/presentation/screens/delegate_home.dart';
import 'features/home/presentation/screens/center_home.dart';

import 'package:firebase_core/firebase_core.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  configureDependencies();
  await Firebase.initializeApp();
  await NotificationService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: RouteGenerator.navigatorKey,
      title: 'نجيك - Nagek',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFC107),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'SA'), // Arabic
      ],
      locale: const Locale('ar', 'SA'), // Force Arabic RTL
      builder: (context, child) => NetworkStatusListener(
        child: child ?? const SizedBox.shrink(),
      ),
      onGenerateRoute: RouteGenerator.getRoute,
      home: const AppNavigator(),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  bool _showSplash = true;
  bool _isLoggedIn = false;
  String _userRole = 'client';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await getIt<SecureStorageService>().isLoggedIn();
    if (loggedIn) {
      final role = await getIt<SecureStorageService>().getUserRole() ?? 'client';
      setState(() {
        _isLoggedIn = true;
        _userRole = role.toLowerCase();
      });
      if (_userRole == 'delegate' || _userRole == 'center' || _userRole == 'admin') {
        debugPrint('🔄 [AUTO-SYNC] App launched with logged-in role: $_userRole, syncing push token...');
        NotificationService.instance.sendTokenToBackend(roleOverride: _userRole);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      child: _showSplash
          ? SplashScreen(
              key: const ValueKey('splash'),
              onInitializationComplete: () {
                setState(() {
                  _showSplash = false;
                });
              },
            )
          : _isLoggedIn
              ? _getHomeWidget()
              : const LoginScreen(key: ValueKey('login')),
    );
  }

  Widget _getHomeWidget() {
    switch (_userRole) {
      case 'admin':
        return const AdminHome(key: ValueKey('admin_home'));
      case 'delegate':
        return const DelegateHome(key: ValueKey('delegate_home'));
      case 'center':
        return const CenterHome(key: ValueKey('center_home'));
      case 'client':
      default:
        return const ClientHome(key: ValueKey('client_home'));
    }
  }
}
