import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:spendora_app/core/utils/currency_utils.dart';

part 'onboarding_state.freezed.dart';
part 'onboarding_state.g.dart';

@freezed
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    required bool hasCompletedOnboarding,
    required String selectedCurrency,
    required bool hasLoadedDefaultCategories,
  }) = _OnboardingState;

  factory OnboardingState.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStateFromJson(json);

  factory OnboardingState.initial() => const OnboardingState(
    hasCompletedOnboarding: false,
    selectedCurrency: CurrencyUtils.defaultCurrency,
    hasLoadedDefaultCategories: false,
  );
}
