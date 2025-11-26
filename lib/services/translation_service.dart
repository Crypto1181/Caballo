import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';

class TranslationService {
  static const String _libreTranslateApiUrl =
      'https://libretranslate.de/translate';

  // Cache for translations
  static final Map<String, Map<String, String>> _cache = {};

  // Predefined translations for common UI strings
  static const Map<String, Map<String, String>> _predefinedTranslations = {
    'en': {
      'welcome': 'Welcome to',
      'log_in': 'Log in',
      'sign_up': 'Sign up',
      'home': 'Home',
      'trade': 'Trade',
      'ai': 'AI',
      'pay': 'Pay',
      'transactions': 'Transactions',
      'search': 'Search',
      'buy': 'Buy',
      'sell': 'Sell',
      'deposit': 'Deposit',
      'watchlist': 'Watchlist',
      'crypto': 'Crypto',
      'cash': 'Cash',
      'balance': 'Balance',
      'insights': 'Insights',
      'transfer': 'Transfer',
      'buy_sell': 'Buy & sell',
      'pay_anyone': 'Pay anyone, anywhere',
      'send_crypto': 'Send crypto to any phone number or email, for free',
      'create_account': 'Create your account',
      'where_live': 'Where do you live?',
      'choose_country':
          'Choose the country or region where you currently live and pay taxes.',
      'select_country': 'Select your country or region',
      'whats_email': 'What\'s your email?',
      'email_description':
          'We\'ll use this email to keep your account secure and send you important updates.',
      'email': 'Email',
      'whats_name': 'What\'s your name?',
      'name_description': 'This is how we\'ll address you in the app.',
      'full_name': 'Full name',
      'create_password': 'Create a password',
      'password_description':
          'Use at least 8 characters with a mix of letters and numbers.',
      'password': 'Password',
      'all_set': 'You\'re all set!',
      'welcome_user': 'Welcome to Caballo',
      'start_trading': 'Start Trading',
      'continue': 'Continue',
      'united_states': 'United States',
      'canada': 'Canada',
      'united_kingdom': 'United Kingdom',
      'mexico': 'Mexico',
      'other': 'Other',
      'account_settings': 'Account & settings',
      'premium_card': 'Caballo Premium Card',
      'premium_card_desc':
          'Earn Bitcoin back - the fastest growing asset of the decade, with every swipe.',
      'learn_more': 'Learn more',
      'trade_section': 'TRADE',
      'advanced': 'Advanced',
      'caballo_one': 'Caballo One',
      'recurring_buys': 'Recurring buys',
      'limit_orders': 'Limit orders',
      'derivatives': 'Derivatives',
      'earn_section': 'EARN',
      'cash_menu': 'Cash',
      'earn_apy': 'Earn 3.85% APY',
      'lending': 'Lending',
      'earn_percent': 'Earn 7.81%',
      'staking': 'Staking',
      'earn_staking': 'Earn 15.21% APY',
      'testing': 'TESTING',
      'generate_qr': 'Generate QR Code',
      'test_scanner': 'Test Scanner',
      'withdrew_funds': 'Withdrew funds',
      'sold_btc': 'Sold BTC',
      'bought_btc': 'Bought BTC',
      'received': 'Received',
      'type': 'Type',
      'status': 'Status',
      'asset': 'Asset',
      'date': 'Date',
      'ai_assistant': 'Caballo AI Assistant',
      'online': 'Online',
      'suggested_prompts': 'Suggested prompts',
      'prompt_market': 'What\'s the current market trend?',
      'prompt_analysis': 'Analyze Bitcoin price movement',
      'prompt_portfolio': 'Give me portfolio advice',
      'enter_message': 'Type your message...',
      'send': 'Send',
      'welcome_back': 'Welcome back',
      'login_description': 'Log in to continue your investment journey',
      'email_address': 'Email address',
      'forgot_password': 'Forgot password?',
      'crypto_section': 'Crypto',
      'buy_sell_button': 'Buy & sell',
      'trending': 'Trending',
      'gainers': 'Gainers',
      'losers': 'Losers',
      'new': 'New',
      'transfer_button': 'Transfer',
      'pay_button': 'Pay',
      'amount': 'Amount',
      'select_crypto': 'Select crypto',
      'scan_qr': 'Scan QR Code',
      'dont_have_account': 'Don\'t have an account? ',
      'top_volume': 'Top volume',
      'top_gainers': 'Top gainers',
      'top_losers': 'Top losers',
      'available': 'available',
      'receive': 'Receive',
      'browse_assets': 'Browse assets',
      'browse_all': 'Browse all',
      'try_crypto_earn': 'Try crypto, earn up to \$2,000 in BTC!',
      'first_buy_reward':
          'Make a first buy of \$50 or more to earn your first reward from Caballo. Average reward is approx. \$50.',
      'track_prices': 'Track prices on all cryptocurrencies',
      'price_alerts':
          'Set up automatic price alerts to let you know about price movements for a specific cryptocurrency.',
      'buy_sell_hold': 'Buy, sell & hold hundreds of cryptocurrencies',
      'buy_sell_easy':
          'From Bitcoin to Dogecoin, we make it easy to buy and sell cryptocurrency.',
      'terms_apply': 'Terms apply',
      'get_started': 'Get started',
      'or': 'OR',
      'continue_with_google': 'Continue with Google',
      'already_have_account': 'I already have an account. ',
      'sign_in': 'Sign in',
      'sign_in_to_coinbase': 'Sign in to Caballo',
      'your_email_address': 'Your email address',
      'sign_in_with_passkey': 'Sign in with Passkey',
      'sign_in_with_google': 'Sign in with Google',
      'sign_in_with_apple': 'Sign in with Apple',
      'cookie_policy_text':
          'We use strictly necessary cookies to enable essential functions, such as security and authentication. For more information, see our ',
      'cookie_policy': 'Cookie Policy',
      'privacy_policy': 'Privacy Policy',
      'and': ' and ',
      'create_your_account': 'Create your account',
      'access_coinbase':
          'Access all that Caballo has to offer with a single account.',
      'account_certify':
          'By creating an account you certify that you are over the age of 18 and agree to the ',
      'financial_privacy_notice': 'Financial Privacy Notice',
    },
    'es': {
      'welcome': 'Bienvenido a',
      'log_in': 'Iniciar sesión',
      'sign_up': 'Registrarse',
      'home': 'Inicio',
      'trade': 'Comerciar',
      'ai': 'IA',
      'pay': 'Pagar',
      'transactions': 'Transacciones',
      'search': 'Buscar',
      'buy': 'Comprar',
      'sell': 'Vender',
      'deposit': 'Depositar',
      'watchlist': 'Lista de seguimiento',
      'crypto': 'Cripto',
      'cash': 'Efectivo',
      'balance': 'Balance',
      'insights': 'Análisis',
      'transfer': 'Transferir',
      'buy_sell': 'Comprar y vender',
      'pay_anyone': 'Paga a cualquiera, en cualquier lugar',
      'send_crypto':
          'Envía cripto a cualquier número de teléfono o correo electrónico, gratis',
      'create_account': 'Crea tu cuenta',
      'where_live': '¿Dónde vives?',
      'choose_country':
          'Elige el país o región donde vives actualmente y pagas impuestos.',
      'select_country': 'Selecciona tu país o región',
      'whats_email': '¿Cuál es tu correo electrónico?',
      'email_description':
          'Usaremos este correo electrónico para mantener tu cuenta segura y enviarte actualizaciones importantes.',
      'email': 'Correo electrónico',
      'whats_name': '¿Cuál es tu nombre?',
      'name_description': 'Así es como te diremos en la aplicación.',
      'full_name': 'Nombre completo',
      'create_password': 'Crea una contraseña',
      'password_description':
          'Usa al menos 8 caracteres con una mezcla de letras y números.',
      'password': 'Contraseña',
      'all_set': '¡Todo está listo!',
      'welcome_user': 'Bienvenido a Caballo',
      'start_trading': 'Comenzar a Comerciar',
      'continue': 'Continuar',
      'united_states': 'Estados Unidos',
      'canada': 'Canadá',
      'united_kingdom': 'Reino Unido',
      'mexico': 'México',
      'other': 'Otro',
      'account_settings': 'Cuenta y configuración',
      'premium_card': 'Tarjeta Premium Caballo',
      'premium_card_desc':
          'Gana Bitcoin de vuelta - el activo de más rápido crecimiento de la década, con cada deslizamiento.',
      'learn_more': 'Saber más',
      'trade_section': 'COMERCIAR',
      'advanced': 'Avanzado',
      'caballo_one': 'Caballo Uno',
      'recurring_buys': 'Compras recurrentes',
      'limit_orders': 'Órdenes límite',
      'derivatives': 'Derivados',
      'earn_section': 'GANAR',
      'cash_menu': 'Efectivo',
      'earn_apy': 'Gana 3.85% APY',
      'lending': 'Préstamos',
      'earn_percent': 'Gana 7.81%',
      'staking': 'Staking',
      'earn_staking': 'Gana 15.21% APY',
      'testing': 'PRUEBAS',
      'generate_qr': 'Generar código QR',
      'test_scanner': 'Probar escáner',
      'withdrew_funds': 'Retiró fondos',
      'sold_btc': 'Vendió BTC',
      'bought_btc': 'Compró BTC',
      'received': 'Recibido',
      'type': 'Tipo',
      'status': 'Estado',
      'asset': 'Activo',
      'date': 'Fecha',
      'ai_assistant': 'Asistente IA de Caballo',
      'online': 'En línea',
      'suggested_prompts': 'Sugerencias',
      'prompt_market': '¿Cuál es la tendencia actual del mercado?',
      'prompt_analysis': 'Analiza el movimiento del precio de Bitcoin',
      'prompt_portfolio': 'Dame consejos de cartera',
      'enter_message': 'Escribe tu mensaje...',
      'send': 'Enviar',
      'welcome_back': 'Bienvenido de nuevo',
      'login_description': 'Inicia sesión para continuar tu viaje de inversión',
      'email_address': 'Dirección de correo electrónico',
      'forgot_password': '¿Olvidaste tu contraseña?',
      'crypto_section': 'Cripto',
      'buy_sell_button': 'Comprar y vender',
      'trending': 'Tendencias',
      'gainers': 'Ganadores',
      'losers': 'Perdedores',
      'new': 'Nuevo',
      'transfer_button': 'Transferir',
      'pay_button': 'Pagar',
      'amount': 'Cantidad',
      'select_crypto': 'Seleccionar cripto',
      'scan_qr': 'Escanear código QR',
      'dont_have_account': '¿No tienes una cuenta? ',
      'top_volume': 'Mayor volumen',
      'top_gainers': 'Mayores ganadores',
      'top_losers': 'Mayores perdedores',
      'available': 'disponible',
      'receive': 'Recibir',
      'browse_assets': 'Explorar activos',
      'browse_all': 'Explorar todo',
      'try_crypto_earn': '¡Prueba cripto, gana hasta \$2,000 en BTC!',
      'first_buy_reward':
          'Haz una primera compra de \$50 o más para ganar tu primera recompensa de Caballo. La recompensa promedio es aprox. \$50.',
      'track_prices': 'Rastrea precios de todas las criptomonedas',
      'price_alerts':
          'Configura alertas de precio automáticas para que te informen sobre movimientos de precio de una criptomoneda específica.',
      'buy_sell_hold': 'Compra, vende y mantén cientos de criptomonedas',
      'buy_sell_easy':
          'Desde Bitcoin hasta Dogecoin, facilitamos la compra y venta de criptomonedas.',
      'terms_apply': 'Términos aplican',
      'get_started': 'Comenzar',
      'or': 'O',
      'continue_with_google': 'Continuar con Google',
      'already_have_account': 'Ya tengo una cuenta. ',
      'sign_in': 'Iniciar sesión',
      'sign_in_to_coinbase': 'Iniciar sesión en Caballo',
      'your_email_address': 'Tu dirección de correo electrónico',
      'sign_in_with_passkey': 'Iniciar sesión con Passkey',
      'sign_in_with_google': 'Iniciar sesión con Google',
      'sign_in_with_apple': 'Iniciar sesión con Apple',
      'cookie_policy_text':
          'Utilizamos cookies estrictamente necesarias para habilitar funciones esenciales, como seguridad y autenticación. Para más información, consulta nuestra ',
      'cookie_policy': 'Política de Cookies',
      'privacy_policy': 'Política de Privacidad',
      'and': ' y ',
      'create_your_account': 'Crea tu cuenta',
      'access_coinbase':
          'Accede a todo lo que Caballo tiene para ofrecer con una sola cuenta.',
      'account_certify':
          'Al crear una cuenta, certificas que eres mayor de 18 años y aceptas la ',
      'financial_privacy_notice': 'Aviso de Privacidad Financiera',
    },
  };

  static String translate(String key, String languageCode) {
    // First check predefined translations
    if (_predefinedTranslations.containsKey(languageCode) &&
        _predefinedTranslations[languageCode]!.containsKey(key)) {
      return _predefinedTranslations[languageCode]![key]!;
    }

    // If not found, return the key or English fallback
    return _predefinedTranslations['en']?[key] ?? key;
  }

  static Future<String> translateText(
    String text,
    String fromLang,
    String toLang,
  ) async {
    if (fromLang == toLang) return text;

    // Check cache
    final cacheKey = '$fromLang-$toLang-$text';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]![toLang] ?? text;
    }

    try {
      final response = await http.post(
        Uri.parse(_libreTranslateApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'source': fromLang,
          'target': toLang,
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final translated = data['translatedText'] as String? ?? text;

        // Cache the translation
        if (!_cache.containsKey(cacheKey)) {
          _cache[cacheKey] = {};
        }
        _cache[cacheKey]![toLang] = translated;

        return translated;
      }
    } catch (e) {
      // Translation error - return original text
      debugPrint('Translation error: $e');
    }

    return text;
  }
}
