import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../shared/widgets/app_section_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).valueOrNull;
    final authAction = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Actify'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: authAction.isLoading
                ? null
                : () => ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text(
              'Home',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            AppSectionCard(
              title: 'Session',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Signed in UID: ${user?.uid ?? 'Unknown'}'),
                  const SizedBox(height: 8),
                  Text('Anonymous session: ${user?.isAnonymous ?? false}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const AppSectionCard(
              title: 'Platform Services',
              child: Text(
                'Firebase Auth, Firestore, and Storage services are registered and ready for feature work.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
