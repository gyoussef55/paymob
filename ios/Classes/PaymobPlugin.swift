import Flutter
import UIKit
import PaymobSDK

public class PaymobPlugin: NSObject, FlutterPlugin {
    private var SDKResult: FlutterResult?
    private var viewController: UIViewController?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "paymob_sdk_flutter", binaryMessenger: registrar.messenger())
        let instance = PaymobPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "payWithPaymob",
           let args = call.arguments as? [String: Any] {
            self.SDKResult = result
            
            if let window = UIApplication.shared.windows.first,
               let rootViewController = window.rootViewController {
                var topController = rootViewController
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                self.viewController = topController
                callNativeSDK(arguments: args, VC: topController)
            } else {
                result(FlutterError(code: "NO_VIEW_CONTROLLER",
                                  message: "Could not find view controller",
                                  details: nil))
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func callNativeSDK(arguments: [String: Any], VC: UIViewController) {
        let paymob = PaymobSDK()
        paymob.delegate = self
        
        if let appName = arguments["appName"] as? String {
            paymob.paymobSDKCustomization.appName = appName
        }
        
        if let buttonBackgroundColor = arguments["buttonBackgroundColor"] as? NSNumber {
            let colorInt = buttonBackgroundColor.intValue
            let alpha = CGFloat((colorInt >> 24) & 0xFF) / 255.0
            let red = CGFloat((colorInt >> 16) & 0xFF) / 255.0
            let green = CGFloat((colorInt >> 8) & 0xFF) / 255.0
            let blue = CGFloat(colorInt & 0xFF) / 255.0
            
            let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
            paymob.paymobSDKCustomization.buttonBackgroundColor = color
        }
        
        if let buttonTextColor = arguments["buttonTextColor"] as? NSNumber {
            let colorInt = buttonTextColor.intValue
            let alpha = CGFloat((colorInt >> 24) & 0xFF) / 255.0
            let red = CGFloat((colorInt >> 16) & 0xFF) / 255.0
            let green = CGFloat((colorInt >> 8) & 0xFF) / 255.0
            let blue = CGFloat(colorInt & 0xFF) / 255.0
            
            let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
            paymob.paymobSDKCustomization.buttonTextColor = color
        }
        
        if let saveCardDefault = arguments["saveCardDefault"] as? Bool {
            paymob.paymobSDKCustomization.saveCardDefault = saveCardDefault
        }
        
        if let showSaveCard = arguments["showSaveCard"] as? Bool {
            paymob.paymobSDKCustomization.showSaveCard = showSaveCard
        }
        
        if let publicKey = arguments["publicKey"] as? String,
           let clientSecret = arguments["clientSecret"] as? String {
            do {
                try paymob.presentPayVC(VC: VC, PublicKey: publicKey, ClientSecret: clientSecret)
            } catch let error {
                print(error.localizedDescription)
                SDKResult?(FlutterError(code: "SDK_ERROR",
                                       message: error.localizedDescription,
                                       details: nil))
            }
            return
        }
        
        SDKResult?(FlutterError(code: "MISSING_PARAMETERS",
                               message: "publicKey and clientSecret are required",
                               details: nil))
    }
}

extension PaymobPlugin: PaymobSDKDelegate {
    public func transactionAccepted(transactionDetails: [String: Any]) {
        self.SDKResult?(["status": "Successfull", "details": transactionDetails])
    }
    
    public func transactionRejected(message: String) {
        self.SDKResult?([
            "status": "Rejected",
            "details": ["message": message]
        ])
    }

    public func transactionPending() {
        self.SDKResult?([
            "status": "Pending",
        ])
    }
}
