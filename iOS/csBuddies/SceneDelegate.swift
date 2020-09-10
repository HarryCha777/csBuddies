//
//  SceneDelegate.swift
//  csBuddies
//
//  Created by Harry Cha on 5/15/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import UIKit
import SwiftUI
import CoreData
import Firebase

// Make Global object variable so classes can access its content in addition to structs.
var globalObject = Global()

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Get the managed object context from the shared persistent container.
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        // Create the SwiftUI view and set the context as the value for the managedObjectContext environment keyPath.
        // Add `@Environment(\.managedObjectContext)` in the views that will need the context.
        let appView = AppView()
            .environmentObject(globalObject)
            .environment(\.managedObjectContext, context)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: appView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        
        // Handle core data only if user check is finished or all core data will be deleted.
        if !globalObject.isCheckingUser {
            archiveData() // archive first since it will change globalObject.encodedData
            deleteCoreData()
            saveCoreData()
            updateBadges()
        }
    }
    
    func archiveData() {
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        try! archiver.encodeEncodable(globalObject.chatHistory, forKey: "chatHistory")
        archiver.finishEncoding()
        globalObject.encodedData = archiver.encodedData
    }
    
    func deleteCoreData() {
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GlobalEntity")
        fetchRequest.returnsObjectsAsFaults = false
        
        let results = try? moc.fetch(fetchRequest)
        for managedObject in results! {
            if let managedObjectData: NSManagedObject = managedObject as? NSManagedObject {
                moc.delete(managedObjectData)
            }
        }
        try? moc.save()
    }
    
    func saveCoreData() {
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let globalEntity = GlobalEntity(context: moc)
        globalEntity.filterGenderIndex = Int16(globalObject.filterGenderIndex)
        globalEntity.filterMinAge = Int16(globalObject.filterMinAge)
        globalEntity.filterMaxAge = Int16(globalObject.filterMaxAge)
        globalEntity.filterCountryIndex = Int16(globalObject.filterCountryIndex)
        globalEntity.filterHasGitHub = globalObject.filterHasGitHub
        globalEntity.filterHasLinkedIn = globalObject.filterHasLinkedIn
        globalEntity.filterInterests = globalObject.filterInterests
        globalEntity.filterLevelIndex = Int16(globalObject.filterLevelIndex)
        globalEntity.filterSortIndex = Int16(globalObject.filterSortIndex)
        globalEntity.firstLaunchDate = globalObject.firstLaunchDate
        globalEntity.requestedReview = globalObject.requestedReview
        globalEntity.encodedData = globalObject.encodedData
        try? moc.save()
    }
    
    func hasPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { notificationSettings in
            switch notificationSettings.authorizationStatus {
            case .authorized:
                completion(true)
            default:
                completion(false)
            }
        }
    }
    
    func updateBadges() {
        hasPermission() { (hasPermission) in
            DispatchQueue.main.async {
                // Update badge only if permission is granted or badge count will be inaccurate.
                if hasPermission {
                    UIApplication.shared.applicationIconBadgeNumber = globalObject.getUnreadCounter()
                    
                    if globalObject.mustUpdateBadges {
                        globalObject.mustUpdateBadges = false
                        
                        let postString =
                            "username=\(globalObject.username.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                            "badges=\(globalObject.getUnreadCounter())"
                        globalObject.runPhp(script: "updateBadges", postString: postString) { json in }
                    }
                } else {
                    UIApplication.shared.applicationIconBadgeNumber = 0
                }
            }
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
