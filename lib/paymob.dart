import 'package:flutter/material.dart';
import 'paymob_platform_interface.dart';

/// Payment transaction result status
enum PaymobTransactionStatus {
  /// Transaction completed successfully
  successful,

  /// Transaction was rejected
  rejected,

  /// Transaction is pending
  pending,

  /// Unknown or error status
  unknown
}

/// Result of a Paymob payment transaction
class PaymobPaymentResult {
  final PaymobTransactionStatus status;
  final Map<String, dynamic>? transactionDetails;
  final String? errorMessage;

  PaymobPaymentResult({
    required this.status,
    this.transactionDetails,
    this.errorMessage,
  });

  bool get isSuccessful => status == PaymobTransactionStatus.successful;
}

/// Main Paymob SDK class
class Paymob {
  /// Pay with Paymob SDK
  ///
  /// Required parameters:
  /// - [publicKey]: Your Paymob public key from the dashboard
  /// - [clientSecret]: Client secret from the intention creation API
  ///
  /// Optional UI customization parameters:
  /// - [appName]: Custom header name for the SDK
  /// - [buttonBackgroundColor]: Color of buttons throughout the SDK (default: black)
  /// - [buttonTextColor]: Color of button text throughout the SDK (default: white)
  /// - [saveCardDefault]: Initial value for save card checkbox (default: false)
  /// - [showSaveCard]: Whether to show save card checkbox (default: true)
  ///
  /// Returns a [PaymobPaymentResult] with the transaction status
  static Future<PaymobPaymentResult> pay({
    required String publicKey,
    required String clientSecret,
    String? appName,
    Color? buttonBackgroundColor,
    Color? buttonTextColor,
    bool saveCardDefault = false,
    bool showSaveCard = true,
  }) async {
    return PaymobPlatform.instance.payWithPaymob(
      publicKey: publicKey,
      clientSecret: clientSecret,
      appName: appName,
      buttonBackgroundColor: buttonBackgroundColor,
      buttonTextColor: buttonTextColor,
      saveCardDefault: saveCardDefault,
      showSaveCard: showSaveCard,
    );
  }
}
