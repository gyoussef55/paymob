import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paymob/paymob.dart';
import 'package:paymob/paymob_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannelPaymob', () {
    late MethodChannelPaymob methodChannelPaymob;
    const MethodChannel methodChannel = MethodChannel('paymob_sdk_flutter');

    setUp(() {
      methodChannelPaymob = MethodChannelPaymob();
    });

    test('should parse successful status correctly', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (MethodCall methodCall) async {
        if (methodCall.method == 'payWithPaymob') {
          return {'status': 'Successful'};
        }
        return null;
      });

      final result = await methodChannelPaymob.payWithPaymob(
        publicKey: 'test_public_key',
        clientSecret: 'test_client_secret',
      );

      expect(result.status, PaymobTransactionStatus.successful);
      expect(result.isSuccessful, true);
    });

    test('should parse rejected status correctly', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (MethodCall methodCall) async {
        if (methodCall.method == 'payWithPaymob') {
          return {'status': 'Rejected'};
        }
        return null;
      });

      final result = await methodChannelPaymob.payWithPaymob(
        publicKey: 'test_public_key',
        clientSecret: 'test_client_secret',
      );

      expect(result.status, PaymobTransactionStatus.rejected);
      expect(result.isSuccessful, false);
    });

    test('should parse pending status correctly', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (MethodCall methodCall) async {
        if (methodCall.method == 'payWithPaymob') {
          return {'status': 'Pending'};
        }
        return null;
      });

      final result = await methodChannelPaymob.payWithPaymob(
        publicKey: 'test_public_key',
        clientSecret: 'test_client_secret',
      );

      expect(result.status, PaymobTransactionStatus.pending);
      expect(result.isSuccessful, false);
    });

    test('should handle unknown status', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (MethodCall methodCall) async {
        if (methodCall.method == 'payWithPaymob') {
          return {'status': 'UnknownStatus'};
        }
        return null;
      });

      final result = await methodChannelPaymob.payWithPaymob(
        publicKey: 'test_public_key',
        clientSecret: 'test_client_secret',
      );

      expect(result.status, PaymobTransactionStatus.unknown);
      expect(result.isSuccessful, false);
    });

    test('should parse transaction details correctly', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (MethodCall methodCall) async {
        if (methodCall.method == 'payWithPaymob') {
          return {
            'status': 'Successful',
            'details': {
              'transactionId': '12345',
              'amount': 100.0,
            },
          };
        }
        return null;
      });

      final result = await methodChannelPaymob.payWithPaymob(
        publicKey: 'test_public_key',
        clientSecret: 'test_client_secret',
      );

      expect(result.status, PaymobTransactionStatus.successful);
      expect(result.transactionDetails, isNotNull);
      expect(result.transactionDetails!['transactionId'], '12345');
      expect(result.transactionDetails!['amount'], 100.0);
    });

    test('should handle error message in details', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (MethodCall methodCall) async {
        if (methodCall.method == 'payWithPaymob') {
          return {
            'status': 'Unknown',
            'details': 'Payment failed',
          };
        }
        return null;
      });

      final result = await methodChannelPaymob.payWithPaymob(
        publicKey: 'test_public_key',
        clientSecret: 'test_client_secret',
      );

      expect(result.status, PaymobTransactionStatus.unknown);
      expect(result.errorMessage, 'Payment failed');
    });

    test('should handle PlatformException', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (MethodCall methodCall) async {
        if (methodCall.method == 'payWithPaymob') {
          throw PlatformException(
            code: 'PAYMENT_ERROR',
            message: 'Payment processing failed',
          );
        }
        return null;
      });

      final result = await methodChannelPaymob.payWithPaymob(
        publicKey: 'test_public_key',
        clientSecret: 'test_client_secret',
      );

      expect(result.status, PaymobTransactionStatus.unknown);
      expect(result.errorMessage, 'Payment processing failed');
    });

    test('should handle generic exceptions', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (MethodCall methodCall) async {
        if (methodCall.method == 'payWithPaymob') {
          throw Exception('Unexpected error');
        }
        return null;
      });

      final result = await methodChannelPaymob.payWithPaymob(
        publicKey: 'test_public_key',
        clientSecret: 'test_client_secret',
      );

      expect(result.status, PaymobTransactionStatus.unknown);
      expect(result.errorMessage, isNotNull);
    });

    test('should pass UI customization parameters', () async {
      Map<String, dynamic>? receivedArguments;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (MethodCall methodCall) async {
        if (methodCall.method == 'payWithPaymob') {
          if (methodCall.arguments is Map) {
            receivedArguments = Map<String, dynamic>.from(
              methodCall.arguments as Map,
            );
          }
          return {'status': 'Successful'};
        }
        return null;
      });

      await methodChannelPaymob.payWithPaymob(
        publicKey: 'test_public_key',
        clientSecret: 'test_client_secret',
        appName: 'Test App',
        buttonBackgroundColor: Colors.blue,
        buttonTextColor: Colors.white,
        saveCardDefault: true,
        showSaveCard: false,
      );

      expect(receivedArguments, isNotNull);
      expect(receivedArguments!['publicKey'], 'test_public_key');
      expect(receivedArguments!['clientSecret'], 'test_client_secret');
      expect(receivedArguments!['appName'], 'Test App');
      expect(receivedArguments!['buttonBackgroundColor'], Colors.blue.toARGB32());
      expect(receivedArguments!['buttonTextColor'], Colors.white.toARGB32());
      expect(receivedArguments!['saveCardDefault'], true);
      expect(receivedArguments!['showSaveCard'], false);
    });

    test('should handle string response type', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (MethodCall methodCall) async {
        if (methodCall.method == 'payWithPaymob') {
          return 'Successful';
        }
        return null;
      });

      final result = await methodChannelPaymob.payWithPaymob(
        publicKey: 'test_public_key',
        clientSecret: 'test_client_secret',
      );

      expect(result.status, PaymobTransactionStatus.successful);
    });

    test('should handle unknown response type', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, (MethodCall methodCall) async {
        if (methodCall.method == 'payWithPaymob') {
          return 12345; // Invalid response type
        }
        return null;
      });

      final result = await methodChannelPaymob.payWithPaymob(
        publicKey: 'test_public_key',
        clientSecret: 'test_client_secret',
      );

      expect(result.status, PaymobTransactionStatus.unknown);
      expect(result.errorMessage, 'Unknown response type');
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(methodChannel, null);
    });
  });
}
