/// Stripe publishable key for the Flutter app.
/// Provided via --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...
const String stripePublishableKey = String.fromEnvironment(
  'STRIPE_PUBLISHABLE_KEY',
  defaultValue: '',
);

bool get isStripeConfigured => stripePublishableKey.isNotEmpty;

