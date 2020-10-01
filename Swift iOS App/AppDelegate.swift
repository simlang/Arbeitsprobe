//
//  AppDelegate.swift
//  sporthealth
//
//  Created by Simon Langrieger on 29.10.19.
//  Copyright © 2019 TUM. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    var surveyModel: SurveyModel?
    var userDefaultsPublisher: UserDefaultsPublisher?
    var apiRequestManager: ApiRequestManagerWithHandling?
    
    /// Case1: app wasn’t running
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Check if launched from notification
        surveyModel = SurveyModel()
        userDefaultsPublisher = UserDefaultsPublisher()
        apiRequestManager = ApiRequestManagerWithHandling(surveyModel: surveyModel,
                                                          userDefaultsPublisher: userDefaultsPublisher)
        apiRequestManager?.getLatestSurveys()
        registerForPushNotifications()
        print("was not running")
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
          print("applicationWillEnterForeground, trying to update surveys now.")
          apiRequestManager?.getLatestSurveys()
    }

    /// Case2: app was running either in the foreground or the background,
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("Notification received, trying to update surveys now.")
        apiRequestManager?.getLatestSurveys()
        print("background")
    }
    
    /// Case others
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        apiRequestManager?.getLatestSurveys()
        print("case others")
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print("Push notification permission granted: \(granted)")
            /// 1. Get permission
            guard granted else {
                return
            }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            /// 2. Register APN (Apple Push Notification)
            guard settings.authorizationStatus == .authorized else {
                return
            }
            DispatchQueue.main.async {  // need to call it on the main thread, or you’ll receive a runtime warning.
              UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    // calls if APN registeration succeed
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        UserDefaults.standard.set(token, forKey: "deviceId")
    }
    
    // calls if APN registeration failed
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // 1. Print out error if PNs registration not successful
        print("Failed to register for remote notifications with error: \(error)")
    }
}
