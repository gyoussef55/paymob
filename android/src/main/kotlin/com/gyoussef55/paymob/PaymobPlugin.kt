package com.gyoussef55.paymob

import android.app.Activity
import android.graphics.Color
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.paymob.paymob_sdk.PaymobSdk
import com.paymob.paymob_sdk.ui.PaymobSdkListener

class PaymobPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PaymobSdkListener {
    private val CHANNEL = "paymob_sdk_flutter"
    private var SDKResult: MethodChannel.Result? = null
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "payWithPaymob") {
            SDKResult = result
            callNativeSDK(call)
        } else {
            result.notImplemented()
        }
    }

    private fun callNativeSDK(call: MethodCall) {
        val currentActivity = activity
        if (currentActivity == null) {
            SDKResult?.error("NO_ACTIVITY", "Activity not available", null)
            return
        }

        val publicKey = call.argument<String>("publicKey")
        val clientSecret = call.argument<String>("clientSecret")

        if (publicKey == null || clientSecret == null) {
            SDKResult?.error("MISSING_PARAMETERS", "publicKey and clientSecret are required", null)
            return
        }

        var buttonBackgroundColor: Int? = null
        var buttonTextColor: Int? = null
        val appName = call.argument<String>("appName")
        val buttonBackgroundColorData = call.argument<Number>("buttonBackgroundColor")?.toInt()
        val buttonTextColorData = call.argument<Number>("buttonTextColor")?.toInt()
        val saveCardDefault = call.argument<Boolean>("saveCardDefault") ?: false
        val showSaveCard = call.argument<Boolean>("showSaveCard") ?: true

        if (buttonTextColorData != null) {
            buttonTextColor = Color.argb(
                (buttonTextColorData shr 24) and 0xFF,  // Alpha
                (buttonTextColorData shr 16) and 0xFF,  // Red
                (buttonTextColorData shr 8) and 0xFF,   // Green
                buttonTextColorData and 0xFF            // Blue
            )
        }

        if (buttonBackgroundColorData != null) {
            buttonBackgroundColor = Color.argb(
                (buttonBackgroundColorData shr 24) and 0xFF,  // Alpha
                (buttonBackgroundColorData shr 16) and 0xFF,  // Red
                (buttonBackgroundColorData shr 8) and 0xFF,   // Green
                buttonBackgroundColorData and 0xFF            // Blue
            )
        }

        val paymobsdk = PaymobSdk.Builder(
            context = currentActivity,
            clientSecret = clientSecret,
            publicKey = publicKey,
            paymobSdkListener = this,
        ).setButtonBackgroundColor(buttonBackgroundColor ?: Color.BLACK)
            .setButtonTextColor(buttonTextColor ?: Color.WHITE)
            .setAppName(appName)
            .showSaveCard(showSaveCard)
            .saveCardByDefault(saveCardDefault)
            .build()

        paymobsdk.start()
    }

    override fun onSuccess(payResponse: HashMap<String, String?>) {
        val responseMap = payResponse.mapValues { it.value ?: "" }
        SDKResult?.success(mapOf(
            "status" to "Successfull",
            "details" to responseMap
        ))
    }

    override fun onFailure(msg: String?) {
        SDKResult?.success(mapOf(
            "status" to "Rejected"
        ))
    }

    override fun onPending() {
        SDKResult?.success(mapOf(
            "status" to "Pending"
        ))
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}