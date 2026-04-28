import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/auth/domain/models/user_role.dart';
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
        path: AppRoutes.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.trainerHome,
        builder: (context, state) => const HomeScreen(title: 'Trainer Home'),
      ),
      GoRoute(
        path: AppRoutes.clientHome,
        builder: (context, state) => const HomeScreen(title: 'Client Home'),
      ),
    ],
    redirect: (context, state) {
      final isLoading = refreshNotifier.isLoading;
      final isAuthenticated = refreshNotifier.currentUser != null;
      final isProfileLoading = refreshNotifier.isProfileLoading;
      final profile = refreshNotifier.currentProfile;
      final location = state.matchedLocation;

      if (isLoading || (isAuthenticated && isProfileLoading)) {
        return location == AppRoutes.splash ? null : AppRoutes.splash;
      }

      if (!isAuthenticated) {
        return location == AppRoutes.login ? null : AppRoutes.login;
      }

      if (profile == null) {
        return location == AppRoutes.roleSelection
            ? null
            : AppRoutes.roleSelection;
      }

      final roleHome = profile.role == UserRole.trainer
          ? AppRoutes.trainerHome
          : AppRoutes.clientHome;

      if (location == AppRoutes.splash ||
          location == AppRoutes.login ||
          location == AppRoutes.roleSelection) {
        return roleHome;
      }

      if (profile.role == UserRole.trainer &&
          location == AppRoutes.clientHome) {
        return AppRoutes.trainerHome;
      }

      if (profile.role == UserRole.client &&
          location == AppRoutes.trainerHome) {
        return AppRoutes.clientHome;
      }

      return null;
    },
  );
});
