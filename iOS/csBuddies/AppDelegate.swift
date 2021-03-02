//
//  AppDelegate.swift
//  csBuddies
//
//  Created by Harry Cha on 5/15/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self // This is needed for messaging(messaging, didReceiveRegistrationToken) function.
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Source: https://stackoverflow.com/a/64516576
        // Contrary to the source, it seems only this line is needed.
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // Run code when FCM Token is retrieved.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // Update FCM since FCM changes on app reinstall.
        if globalObject.myId != "" {
            globalObject.firebaseUser!.getIDToken(completion: { (token, error) in
                let postString =
                    "myId=\(globalObject.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                    "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                    "fcm=\(fcmToken!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
                globalObject.runPhp(script: "updateFcm", postString: postString) { json in }
            })
        }
    }
    
    // Receive notifications even when app is on foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
        -> Void) {
        // Show notification as long as user is not currently chatting with the buddy.
        let userInfo = notification.request.content.userInfo
        if userInfo["type"] == nil ||
            userInfo["type"] as! String == "byte like" ||
            userInfo["type"] as! String == "comment like" ||
            userInfo["type"] as! String == "byte comment" ||
            userInfo["type"] as! String == "comment reply" ||
            (userInfo["type"] as! String == "message" &&
            userInfo["myId"] as! String != globalObject.chatBuddyId) {
            completionHandler([.alert, .badge, .sound])
        }
    }
}
