import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/logic/auth_provider.dart';
import 'features/announcements/logic/announcement_provider.dart';
import 'features/dues/logic/due_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/admin/presentation/dashboard_screen.dart' as admin;
import 'features/warga/presentation/dashboard_screen.dart' as warga;
import 'features/announcements/presentation/announcement_list_screen.dart';
import 'features/dues/presentation/due_history_screen.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/auth/presentation/invite_handler_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (_) => DueProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RT/RW Digital',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/invite') ?? false) {
          final uri = Uri.parse(settings.name!);
          final token = uri.queryParameters['token'];
          return MaterialPageRoute(
            builder: (context) => InviteHandlerScreen(token: token ?? ''),
          );
        }
        return null;
      },
      routes: {
        '/': (context) => const SplashScreen(),
        '/auth-wrapper': (context) => const AuthWrapper(),
        '/invite': (context) => const InviteHandlerScreen(token: ''),
        '/announcements': (context) => const AnnouncementListScreen(),
        '/dues-history': (context) => const DueHistoryScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isAuthenticated) {
      if (authProvider.isWarga) {
        return const warga.WargaDashboardScreen();
      }
      return const admin.DashboardScreen();
    }

    return const LoginScreen();
  }
}
