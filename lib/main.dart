import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/injection/injection_container.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/pages/point_of_sale/select_point_of_sale_page.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite FFI for Windows, Linux and macOS
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize date formatting for Spanish locale
  await initializeDateFormatting('es_ES', null);

  // Initialize dependency injection
  await InjectionContainer().init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Restobar POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: const AuthCheck(),
    );
  }
}

// Global navigator key para poder navegar desde cualquier lugar
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

// Global scaffold messenger key para mostrar mensajes desde cualquier lugar
final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Navegar al login desde cualquier parte de la app
void navigateToLogin() {
  _navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const LoginPage()),
    (route) => false,
  );
}

/// Widget to check authentication and point of sale status on app start
class AuthCheck extends ConsumerStatefulWidget {
  const AuthCheck({super.key});

  @override
  ConsumerState<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends ConsumerState<AuthCheck> {
  @override
  void initState() {
    super.initState();
    // Registrar callback para cuando la sesión expire
    _registerSessionExpiredCallback();
    
    // Defer navigation until after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndNavigate();
    });
  }

  void _registerSessionExpiredCallback() {
    final sessionManager = InjectionContainer().sessionManager;
    
    // Registrar callback de navegación
    sessionManager.registerSessionExpiredCallback(() {
      // Navegar al login cuando la sesión expire
      navigateToLogin();
    });
    
    // Registrar scaffold messenger key para mensajes globales
    sessionManager.registerScaffoldMessengerKey(_scaffoldMessengerKey);
  }

  Future<void> _checkAndNavigate() async {
    final container = InjectionContainer();

    // Check if logged in
    final isLoggedIn = container.authRepository.isLoggedIn();

    if (!isLoggedIn) {
      // Not logged in -> go to Login
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
      return;
    }

    // Verificar si el token ha expirado
    final user = await container.getCurrentUser.call();
    if (user != null && user.isTokenExpired) {
      // Token expirado, cerrar sesión y ir al login
      await container.sessionManager.handleSessionExpired();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
      return;
    }

    // Check if point of sale is selected
    final selectedPos = await container.getSelectedPointOfSale.call();

    if (mounted) {
      if (selectedPos == null) {
        // No point of sale -> select one
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => const SelectPointOfSalePage()),
        );
      } else {
        // All good -> go to home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Cargando...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
