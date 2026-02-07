import 'package:flutter/material.dart';
import 'package:paymob/paymob.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _publicKeyController = TextEditingController();
  final _clientSecretController = TextEditingController();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  String _lastTransactionStatus = 'No transaction yet';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _publicKeyController.text = 'YOUR_PUBLIC_KEY_HERE';
    _clientSecretController.text = 'YOUR_CLIENT_SECRET_HERE';
  }

  @override
  void dispose() {
    _publicKeyController.dispose();
    _clientSecretController.dispose();
    super.dispose();
  }

  Future<void> _payWithPaymob() async {
    if (_publicKeyController.text.isEmpty ||
        _clientSecretController.text.isEmpty) {
      _showSnackBar('Please enter both public key and client secret');
      return;
    }

    setState(() {
      _isProcessing = true;
      _lastTransactionStatus = 'Processing...';
    });

    try {
      final result = await Paymob.pay(
        publicKey: _publicKeyController.text,
        clientSecret: _clientSecretController.text,
        appName: 'Paymob Flutter Demo',
        buttonBackgroundColor: Colors.blue,
        buttonTextColor: Colors.white,
        saveCardDefault: false,
        showSaveCard: true,
      );

      setState(() {
        switch (result.status) {
          case PaymobTransactionStatus.successful:
            _lastTransactionStatus = 'Transaction Successful! ✅';
            if (result.transactionDetails != null) {
              debugPrint('Transaction Details: ${result.transactionDetails}');
            }
            _showSnackBar('Payment successful!', isError: false);
            break;
          case PaymobTransactionStatus.rejected:
            _lastTransactionStatus = 'Transaction Rejected ❌';
            _showSnackBar('Payment was rejected', isError: true);
            break;
          case PaymobTransactionStatus.pending:
            _lastTransactionStatus = 'Transaction Pending ⏳';
            _showSnackBar('Payment is pending', isError: false);
            break;
          case PaymobTransactionStatus.unknown:
            _lastTransactionStatus =
                'Unknown Status ⚠️\nError: ${result.errorMessage ?? "Unknown error"}';
            _showSnackBar(
                'Unknown response: ${result.errorMessage ?? "Unknown error"}',
                isError: true);
            break;
        }
      });
    } catch (e) {
      setState(() {
        _lastTransactionStatus = 'Error: $e';
      });
      _showSnackBar('Error: $e', isError: true);
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paymob Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Paymob Flutter Example'),
          elevation: 2,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Paymob Payment SDK',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your credentials to test the payment',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _publicKeyController,
                decoration: const InputDecoration(
                  labelText: 'Public Key',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key),
                  helperText: 'Get this from your Paymob dashboard',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _clientSecretController,
                decoration: const InputDecoration(
                  labelText: 'Client Secret',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  helperText: 'Get this from the intention creation API',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isProcessing ? null : _payWithPaymob,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Pay with Paymob',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Last Transaction Status:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastTransactionStatus,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '📝 Instructions:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Get your Public Key from Paymob dashboard\n'
                      '2. Create a payment intention via API to get Client Secret\n'
                      '3. Enter both values above\n'
                      '4. Click "Pay with Paymob" to start the payment flow\n'
                      '5. Configure callback URL: https://accept.paymob.com/api/acceptance/post_pay',
                      style: TextStyle(fontSize: 12),
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
