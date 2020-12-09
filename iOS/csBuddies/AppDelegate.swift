//
//  AppDelegate.swift
//  csBuddies
//
//  Created by Harry Cha on 5/15/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import Firebase

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        return true
    }
    
    // Source: https://stackoverflow.com/a/64516576
    // Contrary to the source, it seems only this function is needed.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // Receive notifications even when app is on foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
        -> Void) {
        // Show notification as long as user is not currently chatting with the buddy.
        let userInfo = notification.request.content.userInfo
        if userInfo["type"] == nil ||
            (userInfo["type"] as! String == "chat" &&
            userInfo["myId"] as! String != globalObject.chatBuddyId) ||
            (userInfo["type"] as! String == "byte") {
            completionHandler([.alert, .badge, .sound])
        }
    }
    
    // Run code when notification is tapped.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if userInfo["type"] != nil &&
            (userInfo["type"] as! String == "chat" || userInfo["type"] as! String == "byte") {
            globalObject.hasClickedNotification = true
            globalObject.notificationBuddyId = userInfo["myId"] as! String
            globalObject.notificationBuddyUsername = ((userInfo["aps"] as! NSDictionary)["alert"] as! NSDictionary)["title"] as! String
            globalObject.notificationType = userInfo["type"] as! String
        }

        completionHandler()
    }
}
