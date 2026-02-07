import 'package:flutter/material.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'paymob.dart';
import 'paymob_method_channel.dart';

abstract class PaymobPlatform extends PlatformInterface {
  /// Constructs a PaymobPlatform.
  PaymobPlatform() : super(token: _token);

  static final Object _token = Object();

  static PaymobPlatform _instance = MethodChannelPaymob();

  /// The default instance of [PaymobPlatform] to use.
  ///
  /// Defaults to [MethodChannelPaymob].
  static PaymobPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PaymobPlatform] when
  /// they register themselves.
  static set instance(PaymobPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<PaymobPaymentResult> payWithPaymob({
    required String publicKey,
    required String clientSecret,
    String? appName,
    Color? buttonBackgroundColor,
    Color? buttonTextColor,
    bool saveCardDefault = false,
    bool showSaveCard = true,
  }) {
    throw UnimplementedError('payWithPaymob() has not been implemented.');
  }
}
