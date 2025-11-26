import '../services/alpaca_config.dart';
import '../services/alpaca_service.dart';

/// Quick configuration helper for Alpaca API
/// 
/// Call this function once to configure your Alpaca credentials.
/// You can call this from main.dart or any initialization code.
Future<void> configureAlpacaCredentials() async {
  // Your Alpaca Broker API credentials
  const String clientId = 'CKA5SUPP5WL7AUVKD2NT5WRTHF';
  const String clientSecret = 'CVRMP7aWeDhsv1nnEeW3Y8DEuKvhrQEk7UxKi2LXz97V';
  const bool useProduction = false; // Set to true for production

  // Save credentials
  await AlpacaConfig.instance.saveCredentials(
    apiKeyId: clientId,
    apiSecretKey: clientSecret,
    brokerId: null, // Will use Client ID as Broker ID
    useProduction: useProduction,
  );

  // Initialize the service
  AlpacaService.instance.initialize(
    apiKeyId: clientId,
    apiSecretKey: clientSecret,
    brokerId: null, // Will use Client ID
    useProduction: useProduction,
  );

  print('✅ Alpaca API configured successfully!');
  print('   Client ID: $clientId');
  print('   Environment: ${useProduction ? "Production" : "Sandbox"}');
}

