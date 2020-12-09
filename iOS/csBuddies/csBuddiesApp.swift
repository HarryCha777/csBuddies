//
//  csBuddiesApp.swift
//  csBuddies
//
//  Created by Harry Cha on 11/16/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import CoreData
import Firebase
//import GoogleMobileAds

@main
struct csBuddiesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var phase
    let persistenceController = PersistenceController.shared
    
    init() {
        FirebaseApp.configure()
        //GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(globalObject)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
                .onChange(of: phase) { newPhase in
                    switch newPhase {
                    case .active:
                        setHasCrashed(hasCrashed: true)
                    case .inactive, .background:
                        // Make sure user data loaded or user data will reset.
                        if globalObject.hasUserDataLoaded {
                            globalObject.saveUserData()
                            setHasCrashed(hasCrashed: false)
                        }
                        updateBadges()
                    @unknown default:
                        break
                    }
                }
        }
    }

    func setHasCrashed(hasCrashed: Bool) {
        let moc = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.sortDescriptors = []
        let users = try! moc.fetch(fetchRequest)

        let index = users.firstIndex(where: { $0.myId == globalObject.myId })
        var user = User()
        if index == nil {
            user = User(context: moc)
            user.myId = globalObject.myId
        } else {
            user = users[index!]
        }

        user.hasCrashed = hasCrashed
        try? moc.save()
    }
    
    func updateBadges() {
        hasPermission() { hasPermission in
            DispatchQueue.main.async {
                // Update badge only if permission is granted or badge count will be inaccurate.
                if !hasPermission {
                    UIApplication.shared.applicationIconBadgeNumber = 0
                } else {
                    UIApplication.shared.applicationIconBadgeNumber = globalObject.getUnreadCounter()
                    
                    if globalObject.mustUpdateBadges {
                        globalObject.mustUpdateBadges = false
                        
                        let postString =
                            "myId=\(globalObject.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                            "password=\(globalObject.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                            "badges=\(globalObject.getUnreadCounter())"
                        globalObject.runPhp(script: "updateBadges", postString: postString) { json in }
                    }
                }
            }
        }
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
}

extension UIApplication {
    // Hide keyboard on tap outside.
    // Source: https://stackoverflow.com/a/60010955
    // Don't make gestureRecognizer extension since while it allows onTapGesture(count: x), it prevents pasting or selecting texts being written.
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action:#selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    // Enable addTapGestureRecognizer()
    // Source: https://stackoverflow.com/a/63942065
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
