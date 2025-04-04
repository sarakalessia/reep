import UIKit
import Flutter
import os.log
import Firebase
import FirebaseAuth
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {

            FirebaseApp.configure()

            // APP CHECK
            #if DEBUG
            let providerFactory = AppCheckDebugProviderFactory()
            #else
            let providerFactory = YourSimpleAppCheckProviderFactory()
            #endif
            AppCheck.setAppCheckProviderFactory(providerFactory)


            // NOTIFICATIONS
            FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
                    GeneratedPluginRegistrant.register(with: registry)
            }
            if #available(iOS 10.0, *) {
                 UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
            }

            // STANDARD CONFIG
            GeneratedPluginRegistrant.register(with: self)
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }

        
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let firebaseAuth = Auth.auth()
        firebaseAuth.setAPNSToken(deviceToken, type: AuthAPNSTokenType.unknown)
    }
    
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
}

class YourSimpleAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
  func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
    return AppAttestProvider(app: app)
  }
}
