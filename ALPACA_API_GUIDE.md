# Alpaca API Integration Guide

## Overview

This document explains the differences between Alpaca's **Trading API** and **Broker API**, and which one you need for your Caballo trading application.

## Which API Do You Need?

### ✅ **Broker API** (Recommended for Caballo)

**Use Broker API if:**
- You're building a multi-user trading platform (like Caballo)
- You need to manage multiple user accounts
- You want to handle user onboarding and KYC/AML
- You need to execute trades on behalf of your users
- You want to manage funding (deposits/withdrawals) for multiple accounts
- You're building a white-label trading solution

**This is what Caballo needs** because you have:
- User login/signup system
- Multiple user accounts
- Profile management
- A platform where users trade through your app

### ❌ **Trading API** (Not suitable for Caballo)

**Use Trading API if:**
- You're building a personal trading app for yourself
- Users manage their own Alpaca accounts directly
- You only need to trade for a single account
- You don't need to manage multiple user accounts

## What You Get from Each API

### Broker API Features

#### 1. **Account Management**
```dart
// Create a new user account
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

// Get account details
final accountDetails = await AlpacaService.instance.getAccount(accountId);

// List all accounts
final accounts = await AlpacaService.instance.listAccounts();
```

**What you get:**
- Create and manage multiple user accounts
- Account status tracking (pending, active, closed, etc.)
- KYC/AML compliance handling
- Account information retrieval

#### 2. **Trading Operations**
```dart
// Place a market order
final order = await AlpacaService.instance.placeOrder(
  accountId: 'user-account-id',
  symbol: 'AAPL',
  qty: 10,
  side: 'buy',
  type: 'market',
  timeInForce: 'day',
);

// Get all orders for an account
final orders = await AlpacaService.instance.getOrders(
  accountId: 'user-account-id',
  status: 'all', // 'all', 'open', 'closed'
);

// Cancel an order
await AlpacaService.instance.cancelOrder(
  accountId: 'user-account-id',
  orderId: 'order-id',
);
```

**What you get:**
- Place orders on behalf of users
- Market, limit, stop, and stop-limit orders
- Order status tracking
- Order history
- Order cancellation

#### 3. **Position Management**
```dart
// Get all positions
final positions = await AlpacaService.instance.getPositions(
  accountId: 'user-account-id',
);

// Get specific position
final position = await AlpacaService.instance.getPosition(
  accountId: 'user-account-id',
  symbol: 'AAPL',
);

// Close a position
await AlpacaService.instance.closePosition(
  accountId: 'user-account-id',
  symbol: 'AAPL',
);
```

**What you get:**
- View all user positions
- Position details (quantity, average entry price, market value, etc.)
- Close positions
- Real-time position updates

#### 4. **Portfolio Information**
```dart
// Get account portfolio
final portfolio = await AlpacaService.instance.getAccountPortfolio(
  accountId: 'user-account-id',
);
// Returns: cash, buying_power, portfolio_value, etc.
```

**What you get:**
- Account balances
- Buying power
- Portfolio value
- Equity
- Cash available
- Pattern day trader status

#### 5. **Market Data**
```dart
// Get latest quote
final quote = await AlpacaService.instance.getLatestQuote('AAPL');
// Returns: bid_price, ask_price, bid_size, ask_size, timestamp

// Get latest trade
final trade = await AlpacaService.instance.getLatestTrade('AAPL');
// Returns: price, size, timestamp

// Get historical bars (OHLCV data)
final bars = await AlpacaService.instance.getBars(
  symbol: 'AAPL',
  timeframe: '1Day', // '1Min', '5Min', '15Min', '30Min', '1Hour', '1Day'
  start: '2024-01-01T00:00:00Z',
  end: '2024-12-31T23:59:59Z',
  limit: 100,
);

// Search for assets
final assets = await AlpacaService.instance.searchAssets(
  query: 'Apple',
  assetClass: 'us_equity',
);
```

**What you get:**
- Real-time quotes
- Latest trade data
- Historical OHLCV (candlestick) data
- Asset search
- Market hours information

### Trading API Features (For Reference)

The Trading API provides similar trading and market data features, but:
- **Only works for a single account** (the account associated with your API keys)
- **No account management** - users must create their own Alpaca accounts
- **No multi-user support** - each user needs their own API keys
- **Limited to personal trading** - can't trade on behalf of others

## Setup Instructions

### 1. Get Alpaca API Credentials

1. Sign up at [alpaca.markets](https://alpaca.markets)
2. Apply for Broker API access (if building a multi-user platform)
3. Get your API credentials:
   - API Key ID
   - API Secret Key
   - Broker ID (for Broker API)

### 2. Initialize the Service

In your app initialization (e.g., `main.dart`):

```dart
import 'package:caballo/services/alpaca_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Alpaca Service
  AlpacaService.instance.initialize(
    apiKeyId: 'YOUR_API_KEY_ID',
    apiSecretKey: 'YOUR_API_SECRET_KEY',
    brokerId: 'YOUR_BROKER_ID',
    useProduction: false, // Set to true for production
  );
  
  // ... rest of your initialization
}
```

**⚠️ Security Note:** Never hardcode API keys in your source code. Use:
- Environment variables
- Secure storage (e.g., `flutter_secure_storage`)
- Backend proxy (recommended for production)

### 3. Use the Service in Your App

Example: Creating an account when a user signs up:

```dart
// In your signup screen or service
try {
  final account = await AlpacaService.instance.createAccount(
    contactEmail: userEmail,
    contactPhoneNumber: userPhone,
    contactAddress: userAddress,
    contactCity: userCity,
    contactState: userState,
    contactPostalCode: userZip,
    contactCountry: userCountry,
    givenName: firstName,
    familyName: lastName,
  );
  
  // Store account_id in your database (Supabase)
  final accountId = account['id'] as String;
  // Save to user profile in Supabase
  
} catch (e) {
  print('Error creating Alpaca account: $e');
}
```

Example: Placing an order:

```dart
// When user clicks "Buy" button
try {
  final order = await AlpacaService.instance.placeOrder(
    accountId: userAlpacaAccountId, // From your database
    symbol: 'AAPL',
    qty: 10,
    side: 'buy',
    type: 'market',
    timeInForce: 'day',
  );
  
  // Show success message
  // Update UI with new order
  
} catch (e) {
  print('Error placing order: $e');
  // Show error to user
}
```

Example: Getting portfolio balance:

```dart
// In your investing screen
Future<void> loadPortfolio() async {
  try {
    final portfolio = await AlpacaService.instance.getAccountPortfolio(
      accountId: userAlpacaAccountId,
    );
    
    final portfolioValue = portfolio['portfolio_value'] as double;
    final cash = portfolio['cash'] as double;
    final buyingPower = portfolio['buying_power'] as double;
    
    // Update UI with portfolio data
    
  } catch (e) {
    print('Error loading portfolio: $e');
  }
}
```

## API Environments

### Sandbox (Testing)
- **Broker API**: `https://broker-api.sandbox.alpaca.markets`
- **Trading API**: `https://paper-api.alpaca.markets`
- **Data API**: `https://data.sandbox.alpaca.markets`
- Use for development and testing
- Free, no real money

### Production (Live)
- **Broker API**: `https://broker-api.alpaca.markets`
- **Trading API**: `https://api.alpaca.markets`
- **Data API**: `https://data.alpaca.markets`
- Use for real trading
- Requires approval and real money

## Rate Limits

- **Broker API**: 200 requests per minute per API key
- **Trading API**: 200 requests per minute per API key
- **Data API**: Varies by subscription tier

## Best Practices

1. **Store API keys securely** - Never commit to version control
2. **Use a backend proxy** - For production, proxy API calls through your backend
3. **Handle errors gracefully** - Show user-friendly error messages
4. **Cache market data** - Reduce API calls by caching quotes and bars
5. **Implement retry logic** - Handle rate limits and temporary failures
6. **Store account IDs** - Link Alpaca account IDs to your user accounts in Supabase

## Next Steps

1. ✅ Alpaca service created (`lib/services/alpaca_service.dart`)
2. ⏭️ Integrate account creation in signup flow
3. ⏭️ Add portfolio loading in investing screen
4. ⏭️ Implement order placement in stock detail screen
5. ⏭️ Add position tracking
6. ⏭️ Replace mock data with real Alpaca data

## Resources

- [Alpaca Broker API Docs](https://docs.alpaca.markets/docs/broker-api-overview)
- [Alpaca Trading API Docs](https://docs.alpaca.markets/docs)
- [Alpaca Market Data Docs](https://docs.alpaca.markets/docs/market-data)

