import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';

class TranslationService {
  static const String _libreTranslateApiUrl = 'https://libretranslate.de/translate';
  
  // Cache for translations
  static final Map<String, Map<String, String>> _cache = {};
  
  // Predefined translations for common UI strings
  static const Map<String, Map<String, String>> _predefinedTranslations = {
    'en': {
      'welcome': 'Welcome to',
      'get_started': 'Get access to the tools you need to invest, spend, and put your money in motion.',
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
      'choose_country': 'Choose the country or region where you currently live and pay taxes.',
      'select_country': 'Select your country or region',
      'whats_email': 'What\'s your email?',
      'email_description': 'We\'ll use this email to keep your account secure and send you important updates.',
      'email': 'Email',
      'whats_name': 'What\'s your name?',
      'name_description': 'This is how we\'ll address you in the app.',
      'full_name': 'Full name',
      'create_password': 'Create a password',
      'password_description': 'Use at least 8 characters with a mix of letters and numbers.',
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
      'premium_card_desc': 'Earn Bitcoin back - the fastest growing asset of the decade, with every swipe.',
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
    },
    'es': {
      'welcome': 'Bienvenido a',
      'get_started': 'Obtén acceso a las herramientas que necesitas para invertir, gastar y poner tu dinero en movimiento.',
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
      'send_crypto': 'Envía cripto a cualquier número de teléfono o correo electrónico, gratis',
      'create_account': 'Crea tu cuenta',
      'where_live': '¿Dónde vives?',
      'choose_country': 'Elige el país o región donde vives actualmente y pagas impuestos.',
      'select_country': 'Selecciona tu país o región',
      'whats_email': '¿Cuál es tu correo electrónico?',
      'email_description': 'Usaremos este correo electrónico para mantener tu cuenta segura y enviarte actualizaciones importantes.',
      'email': 'Correo electrónico',
      'whats_name': '¿Cuál es tu nombre?',
      'name_description': 'Así es como te diremos en la aplicación.',
      'full_name': 'Nombre completo',
      'create_password': 'Crea una contraseña',
      'password_description': 'Usa al menos 8 caracteres con una mezcla de letras y números.',
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
      'premium_card_desc': 'Gana Bitcoin de vuelta - el activo de más rápido crecimiento de la década, con cada deslizamiento.',
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

  static Future<String> translateText(String text, String fromLang, String toLang) async {
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

