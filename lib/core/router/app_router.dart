import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(routerRefreshNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    redirect: (context, state) {
      final isLoading = refreshNotifier.isLoading;
      final isAuthenticated = refreshNotifier.currentUser != null;
      final location = state.matchedLocation;

      if (isLoading) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      if (!isAuthenticated) {
        return location == AppRoutes.login ? null : AppRoutes.login;
      }

      if (location == AppRoutes.splash || location == AppRoutes.login) {
        return AppRoutes.home;
      }

      return null;
    },
  );
});

