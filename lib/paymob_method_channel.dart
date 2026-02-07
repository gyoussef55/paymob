import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'paymob.dart';
import 'paymob_platform_interface.dart';

/// An implementation of [PaymobPlatform] that uses method channels.
class MethodChannelPaymob extends PaymobPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('paymob_sdk_flutter');

  @override
  Future<PaymobPaymentResult> payWithPaymob({
    required String publicKey,
    required String clientSecret,
    String? appName,
    Color? buttonBackgroundColor,
    Color? buttonTextColor,
    bool saveCardDefault = false,
    bool showSaveCard = true,
  }) async {
    try {
      final result = await methodChannel.invokeMethod('payWithPaymob', {
        "publicKey": publicKey,
        "clientSecret": clientSecret,
        if (appName != null) "appName": appName,
        if (buttonBackgroundColor != null)
          "buttonBackgroundColor": buttonBackgroundColor.toARGB32(),
        if (buttonTextColor != null) "buttonTextColor": buttonTextColor.toARGB32(),
        "saveCardDefault": saveCardDefault,
        "showSaveCard": showSaveCard,
      });

      if (result is Map) {
        final status = result['status'] as String?;

        Map<String, dynamic>? details;
        String? errorMessage;

        final rawDetails = result['details'];

        if (rawDetails is Map) {
          details = Map<String, dynamic>.from(rawDetails);
        } else if (rawDetails is String) {
          errorMessage = rawDetails;
        }

        return PaymobPaymentResult(
          status: _parseStatus(status ?? 'Unknown'),
          transactionDetails: details,
          errorMessage: errorMessage,
        );
      } else if (result is String) {
        return PaymobPaymentResult(
          status: _parseStatus(result),
        );
      } else {
        return PaymobPaymentResult(
          status: PaymobTransactionStatus.unknown,
          errorMessage: 'Unknown response type',
        );
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to call native SDK: '${e.message}'.");
      return PaymobPaymentResult(
        status: PaymobTransactionStatus.unknown,
        errorMessage: e.message,
      );
    } catch (e) {
      debugPrint("Unexpected error: $e");
      return PaymobPaymentResult(
        status: PaymobTransactionStatus.unknown,
        errorMessage: e.toString(),
      );
    }
  }

  PaymobTransactionStatus _parseStatus(String status) {
    switch (status) {
      case 'Successfull':
      case 'Successful':
        return PaymobTransactionStatus.successful;
      case 'Rejected':
        return PaymobTransactionStatus.rejected;
      case 'Pending':
        return PaymobTransactionStatus.pending;
      default:
        return PaymobTransactionStatus.unknown;
    }
  }
}
