# 🚀 Quick Start Guide - Alpaca API Setup

## Step 1: Generate API Keys (You're Already There!)

You're looking at the Alpaca dashboard. Here's what to do:

1. **Click the yellow "Generate API Key" button** (top right of the main content area)

2. **Fill in the form:**
   - **Key Name**: `Caballo Sandbox` (or `Caballo Production` if you're ready)
   - **Permissions**: Check all three:
     - ✅ Trading
     - ✅ Account Management  
     - ✅ Market Data

3. **Click "Generate"**

4. **⚠️ IMPORTANT**: Copy these values immediately (you won't see the secret again!):
   - **API Key ID** (looks like: `PK...` or `AK...`)
   - **API Secret Key** (long string)
   - **Broker ID** (found in your account settings or URL)

## Step 2: Add Keys to Your App

I've created a settings screen for you! Here's how to use it:

### Option A: Use the Settings Screen (Easiest)

1. **Add a navigation link** to the settings screen in your app (e.g., in `MenuDrawerScreen` or `SettingsScreen`):

```dart
import 'screens/alpaca_settings_screen.dart';

// In your menu or settings
ListTile(
  leading: Icon(Icons.settings),
  title: Text('Alpaca API Settings'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AlpacaSettingsScreen(),
      ),
    );
  },
),
```

2. **Open the app** and navigate to "Alpaca API Settings"

3. **Enter your credentials:**
   - Paste your API Key ID
   - Paste your API Secret Key
   - Paste your Broker ID
   - Toggle "Sandbox" (keep it OFF for testing, ON for production)

4. **Click "Save Credentials"**

5. **Click "Test Connection"** to verify it works!

### Option B: Set Programmatically (For Testing)

If you want to set it in code temporarily:

```dart
import 'services/alpaca_config.dart';
import 'services/alpaca_service.dart';

// In your app initialization or a test function
await AlpacaConfig.instance.saveCredentials(
  apiKeyId: 'YOUR_API_KEY_ID_HERE',
  apiSecretKey: 'YOUR_API_SECRET_KEY_HERE',
  brokerId: 'YOUR_BROKER_ID_HERE',
  useProduction: false, // true for production
);

// Re-initialize the service
AlpacaService.instance.initialize(
  apiKeyId: AlpacaConfig.instance.apiKeyId!,
  apiSecretKey: AlpacaConfig.instance.apiSecretKey!,
  brokerId: AlpacaConfig.instance.brokerId!,
  useProduction: false,
);
```

## Step 3: Test It Works!

After saving your credentials, test the connection:

```dart
import 'services/alpaca_service.dart';

// Test getting accounts
try {
  final accounts = await AlpacaService.instance.listAccounts();
  print('✅ Success! Found ${accounts.length} accounts');
} catch (e) {
  print('❌ Error: $e');
}

// Test market data
try {
  final quote = await AlpacaService.instance.getLatestQuote('AAPL');
  print('✅ AAPL quote: \$${quote['bid_price']}');
} catch (e) {
  print('❌ Error: $e');
}
```

## Step 4: Start Using It!

Now you can use Alpaca API throughout your app. Here are some examples:

### Get Portfolio Balance

```dart
// In your investing_screen.dart
final portfolio = await AlpacaService.instance.getAccountPortfolio(
  accountId: userAlpacaAccountId, // Store this when creating accounts
);
final balance = portfolio['portfolio_value'] as double;
```

### Place an Order

```dart
// In your stock_detail_screen.dart
final order = await AlpacaService.instance.placeOrder(
  accountId: userAlpacaAccountId,
  symbol: 'AAPL',
  qty: 10,
  side: 'buy',
  type: 'market',
  timeInForce: 'day',
);
```

### Get Market Data

```dart
// Get real-time quote
final quote = await AlpacaService.instance.getLatestQuote('AAPL');

// Get historical bars for charts
final bars = await AlpacaService.instance.getBars(
  symbol: 'AAPL',
  timeframe: '1Day',
  limit: 100,
);
```

## What's Already Set Up?

✅ **Alpaca Service** - Full Broker API integration  
✅ **Configuration Service** - Secure credential storage  
✅ **Settings Screen** - UI for entering API keys  
✅ **Auto-initialization** - Service loads on app start  
✅ **Security** - `.gitignore` excludes sensitive files  

## Next Steps

1. ✅ Generate API keys from Alpaca dashboard
2. ✅ Add keys using the settings screen
3. ⏭️ Create accounts for users when they sign up
4. ⏭️ Replace mock data with real Alpaca data
5. ⏭️ Add trading functionality to stock screens

## Need Help?

- Check `ALPACA_SETUP_GUIDE.md` for detailed instructions
- Check `ALPACA_API_GUIDE.md` for API usage examples
- Look at the service code in `lib/services/alpaca_service.dart`

## Important Notes

⚠️ **Sandbox vs Production:**
- **Sandbox**: Free, for testing, no real money
- **Production**: Real trading, requires approval, real money

⚠️ **Security:**
- Never commit API keys to Git (already in `.gitignore`)
- Keys are stored in SharedPreferences (encrypted on device)
- For production, consider using a backend proxy

🎉 **You're all set!** Start by generating your API keys and adding them through the settings screen.

