import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../shared/widgets/app_section_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).valueOrNull;
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final authAction = ref.watch(profileSetupControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: authAction.isLoading
                ? null
                : () => ref.read(profileSetupControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text(
              title,
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
                  Text('Name: ${profile?.name ?? 'Pending'}'),
                  const SizedBox(height: 8),
                  Text('Role: ${profile?.role.value ?? 'Pending'}'),
                  if ((profile?.trainerId ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Trainer ID: ${profile?.trainerId}'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppSectionCard(
              title: 'Next Steps',
              child: Text(
                profile?.isTrainer == true
                    ? 'Trainer view ready. Next we can add client management, workout plans, and progress tracking.'
                    : 'Client view ready. Next we can add trainer linking, workout assignments, and progress check-ins.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
