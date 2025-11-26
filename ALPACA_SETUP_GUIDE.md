# Alpaca API Setup Guide - Step by Step

## Step 1: Generate API Keys from Alpaca Dashboard

Based on the screenshot, you're already in the right place! Here's what to do:

1. **Click the "Generate API Key" button** (yellow button in the top right)
2. **Fill in the details:**
   - **Key Name**: Give it a descriptive name (e.g., "Caballo Production" or "Caballo Sandbox")
   - **Permissions**: Select the permissions you need:
     - ✅ Trading (to place orders)
     - ✅ Account Management (to manage accounts)
     - ✅ Market Data (to get quotes and historical data)
3. **Click "Generate"**
4. **IMPORTANT**: Copy both:
   - **API Key ID** (starts with something like `PK...` or `AK...`)
   - **API Secret Key** (long string - you'll only see this once!)
5. **Store them securely** - You won't be able to see the secret key again!

## Step 2: Get Your Broker ID

1. In the Alpaca dashboard, look for your **Broker ID** or **Account ID**
2. It's usually visible in:
   - The URL (e.g., `https://broker-app.alpaca.markets/balance`)
   - Account settings
   - Or provided when you first signed up

## Step 3: Secure API Key Storage in Flutter

**⚠️ NEVER commit API keys to version control!**

We'll use environment variables and secure storage. Let's set this up:

### Option A: Using Environment Variables (Recommended for Development)

1. Create a `.env` file in your project root:

```bash
# .env
ALPACA_API_KEY_ID=your_api_key_id_here
ALPACA_API_SECRET_KEY=your_api_secret_key_here
ALPACA_BROKER_ID=your_broker_id_here
ALPACA_USE_PRODUCTION=false
```

2. Add `.env` to `.gitignore`:

```gitignore
# .env files
.env
.env.local
.env.production
```

3. Install the `flutter_dotenv` package:

```yaml
# pubspec.yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

4. Update `pubspec.yaml` to include the `.env` file:

```yaml
flutter:
  assets:
    - .env
```

### Option B: Using Secure Storage (Recommended for Production)

For production apps, use `flutter_secure_storage` to encrypt and store keys on the device.

## Step 4: Configure API Keys in Your App

I've already created the configuration service for you! Now you have two options:

### Option A: Set Credentials Programmatically (Quick Start)

Create a simple settings screen or add this to your existing settings:

```dart
import 'package:caballo/services/alpaca_config.dart';
import 'package:caballo/services/alpaca_service.dart';

// In your settings screen or admin panel
Future<void> configureAlpaca() async {
  await AlpacaConfig.instance.saveCredentials(
    apiKeyId: 'YOUR_API_KEY_ID',
    apiSecretKey: 'YOUR_API_SECRET_KEY',
    brokerId: 'YOUR_BROKER_ID',
    useProduction: false, // Set to true for production
  );
  
  // Re-initialize the service
  AlpacaService.instance.initialize(
    apiKeyId: AlpacaConfig.instance.apiKeyId!,
    apiSecretKey: AlpacaConfig.instance.apiSecretKey!,
    brokerId: AlpacaConfig.instance.brokerId!,
    useProduction: AlpacaConfig.instance.useProduction,
  );
}
```

### Option B: Create a Settings UI (Recommended)

I'll create a simple settings screen where you can enter your API keys. This is better for testing and development.

## Step 5: Test the Integration

Once you've configured your API keys, test the connection:

```dart
import 'package:caballo/services/alpaca_service.dart';

// Test: Get account list
Future<void> testConnection() async {
  try {
    final accounts = await AlpacaService.instance.listAccounts();
    print('✅ Connection successful! Found ${accounts.length} accounts');
    
    // Test: Get market data
    final quote = await AlpacaService.instance.getLatestQuote('AAPL');
    print('✅ Market data working! AAPL quote: ${quote['bid_price']}');
    
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

## Step 6: Integration Checklist

Now that your API is set up, here's what to integrate:

### ✅ Already Done:
- [x] Alpaca service created (`lib/services/alpaca_service.dart`)
- [x] Configuration service created (`lib/services/alpaca_config.dart`)
- [x] Service initialization in `main.dart`
- [x] `.gitignore` updated to exclude `.env` files

### ⏭️ Next Steps:

1. **Create API Settings Screen**
   - Add a screen where you can enter API keys
   - Store them securely using `AlpacaConfig`

2. **Integrate Account Creation**
   - When a user signs up, create an Alpaca account for them
   - Store the `account_id` in Supabase linked to the user

3. **Update Investing Screen**
   - Replace mock portfolio data with real data from `getAccountPortfolio()`
   - Show real balances and buying power

4. **Add Trading Functionality**
   - In `stock_detail_screen.dart`, add real order placement
   - Show order history from `getOrders()`

5. **Display Positions**
   - Show real positions from `getPositions()`
   - Update watchlist with real market data

6. **Market Data Integration**
   - Replace Binance data with Alpaca market data for stocks
   - Use `getBars()` for historical charts
   - Use `getLatestQuote()` for real-time prices

## Quick Start Example

Here's a complete example of how to use the service:

```dart
import 'package:caballo/services/alpaca_service.dart';
import 'package:caballo/services/alpaca_config.dart';

// 1. Configure (do this once)
await AlpacaConfig.instance.saveCredentials(
  apiKeyId: 'your_key',
  apiSecretKey: 'your_secret',
  brokerId: 'your_broker_id',
);

// 2. Initialize (already done in main.dart, but you can re-initialize)
AlpacaService.instance.initialize(
  apiKeyId: AlpacaConfig.instance.apiKeyId!,
  apiSecretKey: AlpacaConfig.instance.apiSecretKey!,
  brokerId: AlpacaConfig.instance.brokerId!,
);

// 3. Create an account for a new user
final account = await AlpacaService.instance.createAccount(
  contactEmail: 'user@example.com',
  contactPhoneNumber: '+1234567890',
  contactAddress: '123 Main St',
  contactCity: 'New York',
  contactState: 'NY',
  contactPostalCode: '10001',
  contactCountry: 'USA',
  givenName: 'John',
  familyName: 'Doe',
);

// 4. Get portfolio balance
final portfolio = await AlpacaService.instance.getAccountPortfolio(
  accountId: account['id'] as String,
);
print('Portfolio value: \$${portfolio['portfolio_value']}');

// 5. Place an order
final order = await AlpacaService.instance.placeOrder(
  accountId: account['id'] as String,
  symbol: 'AAPL',
  qty: 10,
  side: 'buy',
  type: 'market',
  timeInForce: 'day',
);

// 6. Get positions
final positions = await AlpacaService.instance.getPositions(
  accountId: account['id'] as String,
);
```

## Troubleshooting

### "AlpacaService not initialized"
- Make sure you've called `AlpacaConfig.instance.saveCredentials()` first
- Check that `main.dart` is loading and initializing the service

### "Failed to create account: 401"
- Check your API keys are correct
- Make sure you're using the right environment (sandbox vs production)
- Verify your Broker API access is approved

### "Failed to get account: 404"
- The account ID might be incorrect
- Make sure the account exists in your Alpaca dashboard

### Rate Limit Errors
- Alpaca allows 200 requests per minute
- Implement caching for market data
- Add retry logic with exponential backoff

## Security Best Practices

1. **Never commit API keys to Git** ✅ (Already in `.gitignore`)
2. **Use environment variables** for development
3. **Use secure storage** (`flutter_secure_storage`) for production
4. **Consider a backend proxy** - For production apps, proxy API calls through your backend server
5. **Rotate keys regularly** - Generate new keys and update them periodically

## Resources

- [Alpaca Broker API Documentation](https://docs.alpaca.markets/docs/broker-api-overview)
- [Alpaca API Reference](https://alpaca.markets/docs/api-references/)
- [Alpaca Dashboard](https://broker-app.alpaca.markets)

## Need Help?

If you run into issues:
1. Check the error messages in the console
2. Verify your API keys in the Alpaca dashboard
3. Make sure you're using the correct environment (sandbox vs production)
4. Check the Alpaca API documentation for specific endpoint requirements

