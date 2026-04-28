import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/user_role.dart';
import '../providers/auth_providers.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _trainerIdController = TextEditingController();
  UserRole _selectedRole = UserRole.trainer;

  @override
  void dispose() {
    _nameController.dispose();
    _trainerIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileSetupState = ref.watch(profileSetupControllerProvider);

    ref.listen(profileSetupControllerProvider, (_, next) {
      next.whenOrNull(
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    'Tell us who you are',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We use your role to route you to the right experience in Actify.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      hintText: 'Premnath',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SegmentedButton<UserRole>(
                    segments: const [
                      ButtonSegment<UserRole>(
                        value: UserRole.trainer,
                        label: Text('Trainer'),
                        icon: Icon(Icons.fitness_center),
                      ),
                      ButtonSegment<UserRole>(
                        value: UserRole.client,
                        label: Text('Client'),
                        icon: Icon(Icons.person),
                      ),
                    ],
                    selected: {_selectedRole},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _selectedRole = selection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  if (_selectedRole == UserRole.client)
                    TextFormField(
                      controller: _trainerIdController,
                      decoration: const InputDecoration(
                        labelText: 'Trainer ID',
                        hintText: 'Optional: link to your trainer',
                      ),
                    ),
                  if (_selectedRole == UserRole.client)
                    const SizedBox(height: 24),
                  FilledButton(
                    onPressed: profileSetupState.isLoading
                        ? null
                        : _submitProfile,
                    child: profileSetupState.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save and continue'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: profileSetupState.isLoading
                        ? null
                        : () => ref
                            .read(profileSetupControllerProvider.notifier)
                            .signOut(),
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(profileSetupControllerProvider.notifier).saveProfile(
          name: _nameController.text,
          role: _selectedRole,
          trainerId:
              _selectedRole == UserRole.client ? _trainerIdController.text : null,
        );
  }
}
