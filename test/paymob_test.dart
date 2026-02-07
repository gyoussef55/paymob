import 'package:flutter_test/flutter_test.dart';
import 'package:paymob/paymob.dart';

void main() {
  group('PaymobTransactionStatus', () {
    test('should have all expected status values', () {
      expect(PaymobTransactionStatus.values.length, 4);
      expect(PaymobTransactionStatus.values, contains(PaymobTransactionStatus.successful));
      expect(PaymobTransactionStatus.values, contains(PaymobTransactionStatus.rejected));
      expect(PaymobTransactionStatus.values, contains(PaymobTransactionStatus.pending));
      expect(PaymobTransactionStatus.values, contains(PaymobTransactionStatus.unknown));
    });
  });

  group('PaymobPaymentResult', () {
    test('should create result with successful status', () {
      final result = PaymobPaymentResult(
        status: PaymobTransactionStatus.successful,
      );

      expect(result.status, PaymobTransactionStatus.successful);
      expect(result.isSuccessful, true);
      expect(result.transactionDetails, isNull);
      expect(result.errorMessage, isNull);
    });

    test('should create result with rejected status', () {
      final result = PaymobPaymentResult(
        status: PaymobTransactionStatus.rejected,
      );

      expect(result.status, PaymobTransactionStatus.rejected);
      expect(result.isSuccessful, false);
    });

    test('should create result with pending status', () {
      final result = PaymobPaymentResult(
        status: PaymobTransactionStatus.pending,
      );

      expect(result.status, PaymobTransactionStatus.pending);
      expect(result.isSuccessful, false);
    });

    test('should create result with unknown status', () {
      final result = PaymobPaymentResult(
        status: PaymobTransactionStatus.unknown,
        errorMessage: 'Test error',
      );

      expect(result.status, PaymobTransactionStatus.unknown);
      expect(result.isSuccessful, false);
      expect(result.errorMessage, 'Test error');
    });

    test('should create result with transaction details', () {
      final details = {'transactionId': '123', 'amount': 100.0};
      final result = PaymobPaymentResult(
        status: PaymobTransactionStatus.successful,
        transactionDetails: details,
      );

      expect(result.transactionDetails, details);
      expect(result.transactionDetails!['transactionId'], '123');
      expect(result.transactionDetails!['amount'], 100.0);
    });

    test('isSuccessful should return true only for successful status', () {
      expect(
        PaymobPaymentResult(status: PaymobTransactionStatus.successful).isSuccessful,
        true,
      );
      expect(
        PaymobPaymentResult(status: PaymobTransactionStatus.rejected).isSuccessful,
        false,
      );
      expect(
        PaymobPaymentResult(status: PaymobTransactionStatus.pending).isSuccessful,
        false,
      );
      expect(
        PaymobPaymentResult(status: PaymobTransactionStatus.unknown).isSuccessful,
        false,
      );
    });
  });
}
