import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/privy_config.dart';
import '../services/privy_service.dart';

/// Settings screen for configuring Privy API credentials
class PrivySettingsScreen extends StatefulWidget {
  const PrivySettingsScreen({super.key});

  @override
  State<PrivySettingsScreen> createState() => _PrivySettingsScreenState();
}

class _PrivySettingsScreenState extends State<PrivySettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appIdController = TextEditingController();
  final _appSecretController = TextEditingController();
  bool _useProduction = false;
  bool _isLoading = false;
  bool _obscureSecret = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    await PrivyConfig.instance.loadFromStorage();
    if (PrivyConfig.instance.isConfigured) {
      setState(() {
        _appIdController.text = PrivyConfig.instance.appId ?? '';
        _appSecretController.text = PrivyConfig.instance.appSecret ?? '';
        _useProduction = PrivyConfig.instance.useProduction;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await PrivyConfig.instance.saveCredentials(
        appId: _appIdController.text.trim(),
        appSecret: _appSecretController.text.trim(),
        useProduction: _useProduction,
      );

      // Re-initialize the service
      PrivyService.instance.initialize(
        appId: PrivyConfig.instance.appId!,
        appSecret: PrivyConfig.instance.appSecret!,
        useProduction: _useProduction,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Privy credentials saved successfully!'),
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

  @override
  void dispose() {
    _appIdController.dispose();
    _appSecretController.dispose();
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
          'Privy Settings',
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
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.purple, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Get your Privy credentials',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Go to privy.io and create an account\n'
                      '2. Create a new app\n'
                      '3. Go to App Settings > Basics\n'
                      '4. Copy your App ID and App Secret',
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
                    _useProduction ? 'Production' : 'Development',
                    style: TextStyle(
                      fontSize: 14,
                      color: _useProduction ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // App ID
              TextFormField(
                controller: _appIdController,
                decoration: InputDecoration(
                  labelText: 'App ID',
                  hintText: 'Enter your Privy App ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.key),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your App ID';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // App Secret
              TextFormField(
                controller: _appSecretController,
                decoration: InputDecoration(
                  labelText: 'App Secret',
                  hintText: 'Enter your Privy App Secret',
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
                    return 'Please enter your App Secret';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
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

              const SizedBox(height: 24),

              // Status indicator
              if (PrivyConfig.instance.isConfigured)
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
                          'Privy credentials are configured',
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

