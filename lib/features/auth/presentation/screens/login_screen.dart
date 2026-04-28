import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authFlowControllerProvider);

    ref.listen(authFlowControllerProvider, (_, next) {
      final message = next.errorMessage;
      if (message != null && message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
          ref.read(authFlowControllerProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Actify Login'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    'Welcome to Actify',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sign in with your Indian mobile number to receive an OTP.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      hintText: '9876543210',
                      prefixText: '+91 ',
                    ),
                    validator: (value) {
                      final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
                      if (digits.length != 10) {
                        return 'Enter a valid 10-digit mobile number.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (authState.otpSent) ...[
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      decoration: const InputDecoration(
                        labelText: 'OTP',
                        hintText: '6-digit code',
                      ),
                      validator: (value) {
                        if (!authState.otpSent) {
                          return null;
                        }
                        final digits =
                            value?.replaceAll(RegExp(r'\D'), '') ?? '';
                        if (digits.length != 6) {
                          return 'Enter the 6-digit OTP.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Code sent to ${authState.phoneNumber}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                  ],
                  FilledButton.icon(
                    onPressed: authState.isLoading ? null : _onPrimaryAction,
                    icon: authState.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(authState.otpSent ? Icons.verified : Icons.sms),
                    label: Text(
                      authState.otpSent ? 'Verify OTP' : 'Send OTP',
                    ),
                  ),
                  if (authState.otpSent) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: authState.isLoading
                          ? null
                          : () => ref
                              .read(authFlowControllerProvider.notifier)
                              .sendOtp(_phoneController.text),
                      child: const Text('Resend OTP'),
                    ),
                  ],
                  if (authState.isAutoVerifying) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Trying instant verification...',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onPrimaryAction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = ref.read(authFlowControllerProvider.notifier);
    final authState = ref.read(authFlowControllerProvider);

    if (authState.otpSent) {
      await controller.verifyOtp(_otpController.text);
      return;
    }

    await controller.sendOtp(_phoneController.text);
  }
}
