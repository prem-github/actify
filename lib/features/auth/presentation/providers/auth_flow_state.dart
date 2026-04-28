class AuthFlowState {
  const AuthFlowState({
    this.isLoading = false,
    this.otpSent = false,
    this.isAutoVerifying = false,
    this.phoneNumber = '',
    this.verificationId,
    this.resendToken,
    this.errorMessage,
  });

  final bool isLoading;
  final bool otpSent;
  final bool isAutoVerifying;
  final String phoneNumber;
  final String? verificationId;
  final int? resendToken;
  final String? errorMessage;

  AuthFlowState copyWith({
    bool? isLoading,
    bool? otpSent,
    bool? isAutoVerifying,
    String? phoneNumber,
    String? verificationId,
    int? resendToken,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthFlowState(
      isLoading: isLoading ?? this.isLoading,
      otpSent: otpSent ?? this.otpSent,
      isAutoVerifying: isAutoVerifying ?? this.isAutoVerifying,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
