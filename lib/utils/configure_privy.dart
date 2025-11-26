import '../services/privy_config.dart';
import '../services/privy_service.dart';

/// Quick configuration helper for Privy API
/// 
/// Call this function once to configure your Privy credentials.
/// You can call this from main.dart or any initialization code.
Future<void> configurePrivyCredentials() async {
  // Your Privy credentials
  const String appId = 'cmifywhd900djl40e48qmym21';
  const String appSecret = '5gNykCui39XTyToNcybLys2gYkiqWzp8vDCjPphvU6dfFkMXeRV4ujnJXKuzmNnQNZj4StxLYh7NoXzTUsmVKffe';
  const bool useProduction = false; // Set to true for production

  // Save credentials
  await PrivyConfig.instance.saveCredentials(
    appId: appId,
    appSecret: appSecret,
    useProduction: useProduction,
  );

  // Initialize the service
  PrivyService.instance.initialize(
    appId: appId,
    appSecret: appSecret,
    useProduction: useProduction,
  );

  print('✅ Privy API configured successfully!');
  print('   App ID: $appId');
  print('   Environment: ${useProduction ? "Production" : "Development"}');
}

