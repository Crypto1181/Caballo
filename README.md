# Caballo

A Flutter trading application with Alpaca integration, Stripe payments, and Privy wallet support.

## Features

- 📈 Stock and crypto trading via Alpaca Broker API
- 💳 Stripe payment integration for deposits
- 🔐 Privy embedded MPC wallets
- 📱 Cross-platform support (iOS, Android, Web)
- 🌓 Dark/Light theme support
- 🌍 Multi-language support

## Getting Started

### Prerequisites

- Flutter SDK 3.35.6 or higher
- Dart 3.9.2 or higher
- Supabase account
- Alpaca API credentials
- Stripe account
- Privy account

### Installation

1. Clone the repository:
```bash
git clone https://github.com/YOUR_USERNAME/caballo.git
cd caballo
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure your services:
   - Set up Supabase (see `supabase/SUPABASE_EDGE_FUNCTIONS_SETUP.md`)
   - Configure Alpaca API (see `ALPACA_SETUP_GUIDE.md`)
   - Set up Stripe and Privy credentials

4. Run the app:
```bash
flutter run
```

## Web Deployment

To deploy the web app to GitHub Pages for iOS testing, see [DEPLOYMENT.md](DEPLOYMENT.md).

Quick deployment:
1. Enable GitHub Pages in repository settings (Source: GitHub Actions)
2. Push to `main` branch
3. Access at: `https://YOUR_USERNAME.github.io/Caballo/`

## Documentation

- [Alpaca API Guide](ALPACA_API_GUIDE.md)
- [Alpaca Setup Guide](ALPACA_SETUP_GUIDE.md)
- [Supabase Edge Functions Setup](supabase/SUPABASE_EDGE_FUNCTIONS_SETUP.md)
- [Deployment Guide](DEPLOYMENT.md)
- [Quick Start](QUICK_START.md)

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/                  # UI screens
├── services/                 # API services (Alpaca, Stripe, Privy, etc.)
├── providers/                # State management
├── widgets/                  # Reusable widgets
└── utils/                    # Utilities and helpers

supabase/
├── functions/                # Edge Functions (backend API)
└── setup_tables.sql         # Database schema
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

[Add your license here]
