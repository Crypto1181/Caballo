import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/alpaca_config.dart';
import '../services/alpaca_service.dart';

/// Settings screen for configuring Alpaca API credentials
/// 
/// This screen allows you to enter and save your Alpaca API keys.
/// The keys are stored securely using SharedPreferences.
class AlpacaSettingsScreen extends StatefulWidget {
  const AlpacaSettingsScreen({super.key});

  @override
  State<AlpacaSettingsScreen> createState() => _AlpacaSettingsScreenState();
}

class _AlpacaSettingsScreenState extends State<AlpacaSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyIdController = TextEditingController();
  final _apiSecretKeyController = TextEditingController();
  final _brokerIdController = TextEditingController();
  bool _useProduction = false;
  bool _isLoading = false;
  bool _obscureSecret = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    await AlpacaConfig.instance.loadFromStorage();
    if (AlpacaConfig.instance.isConfigured) {
      setState(() {
        _apiKeyIdController.text = AlpacaConfig.instance.apiKeyId ?? '';
        _apiSecretKeyController.text = AlpacaConfig.instance.apiSecretKey ?? '';
        _brokerIdController.text = AlpacaConfig.instance.brokerId ?? '';
        _useProduction = AlpacaConfig.instance.useProduction;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AlpacaConfig.instance.saveCredentials(
        apiKeyId: _apiKeyIdController.text.trim(),
        apiSecretKey: _apiSecretKeyController.text.trim(),
        brokerId: _brokerIdController.text.trim().isEmpty 
            ? null 
            : _brokerIdController.text.trim(),
        useProduction: _useProduction,
      );

      // Re-initialize the service
      AlpacaService.instance.initialize(
        apiKeyId: AlpacaConfig.instance.apiKeyId!,
        apiSecretKey: AlpacaConfig.instance.apiSecretKey!,
        brokerId: AlpacaConfig.instance.brokerId,
        useProduction: _useProduction,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ API credentials saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error saving credentials: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _testConnection() async {
    if (!AlpacaConfig.instance.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please save your credentials first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Test by getting account list
      final accounts = await AlpacaService.instance.listAccounts();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Connection successful! Found ${accounts.length} accounts'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Connection failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _apiKeyIdController.dispose();
    _apiSecretKeyController.dispose();
    _brokerIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Alpaca API Settings',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Get your API keys from Alpaca Dashboard',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Go to broker-app.alpaca.markets\n'
                      '2. Navigate to API/Devs section\n'
                      '3. Click "Generate API Key"\n'
                      '4. Copy your API Key ID, Secret Key, and Broker ID',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Environment toggle
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Environment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  Switch(
                    value: _useProduction,
                    onChanged: (value) {
                      setState(() => _useProduction = value);
                    },
                  ),
                  Text(
                    _useProduction ? 'Production' : 'Sandbox',
                    style: TextStyle(
                      fontSize: 14,
                      color: _useProduction ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // API Key ID (Client ID)
              TextFormField(
                controller: _apiKeyIdController,
                decoration: InputDecoration(
                  labelText: 'Client ID',
                  hintText: 'Enter your Alpaca Client ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.key),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your API Key ID';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // API Secret Key (Client Secret)
              TextFormField(
                controller: _apiSecretKeyController,
                decoration: InputDecoration(
                  labelText: 'Client Secret',
                  hintText: 'Enter your Alpaca Client Secret',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureSecret ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _obscureSecret = !_obscureSecret);
                    },
                  ),
                ),
                obscureText: _obscureSecret,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your API Secret Key';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Broker ID
              TextFormField(
                controller: _brokerIdController,
                decoration: InputDecoration(
                  labelText: 'Broker ID',
                  hintText: 'Enter your Alpaca Broker ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.business),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your Broker ID';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save Credentials',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),

              const SizedBox(height: 12),

              // Test connection button
              OutlinedButton(
                onPressed: _isLoading ? null : _testConnection,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Test Connection',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Status indicator
              if (AlpacaConfig.instance.isConfigured)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'API credentials are configured',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

