//
//  LoadingView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/15/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase
import TrueTime

struct LoadingView: View {
    @EnvironmentObject var global: Global
    @FetchRequest(entity: User.entity(), sortDescriptors: []) var users: FetchedResults<User>
    
    @State private var showLoadingIndicator = false
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 150)
            Image("transparentSmallLogo")
                .resizable()
                .frame(width: 200, height: 200)
            LottieView(name: "load", size: 300, mustLoop: true)
                .opacity(showLoadingIndicator ? 1 : 0)
                .animation(.easeInOut(duration: 2))
        }
        .padding()
        .onAppear {
            global.hasUserDataLoaded = false // Make sure user data does not get changed while loading on sign in.
            if !Reachability.isConnectedToNetwork() {
                global.isOffline = true
                return
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showLoadingIndicator = true
            }
            
            readGlobalDocument() {
                listenToGlobalDocument()
                if global.activeRootView != .maintenance &&
                    global.activeRootView != .update {
                    getReferenceTime() { referenceTime in
                        global.referenceTime = referenceTime
                        handleAuthentication()
                    }
                }
            }
        }
    }
    
    func readGlobalDocument(completion: @escaping () -> Void) {
        global.db.collection("global")
            .document("18")
            .getDocument() { (document, error) in
                global.webServerLink = document!.get("webServerLink") as! String
                global.announcementText = document!.get("announcementText") as! String
                global.announcementLink = document!.get("announcementLink") as! String
                global.maintenanceText = document!.get("maintenanceText") as! String
                global.updateText = document!.get("updateText") as! String
                let isUnderMaintenance = document!.get("isUnderMaintenance") as! Bool
                
                let currentBuild = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as! String)
                let minimumBuild = document!.get("minimumBuild") as! Int
                let mustUpdate = currentBuild! < minimumBuild
                
                if isUnderMaintenance { // MaintenanceView takes precedence.
                    global.activeRootView = .maintenance
                } else if mustUpdate {
                    global.activeRootView = .update
                }
                completion()
            }
    }
    
    func listenToGlobalDocument() {
        if global.isGlobalListenerSetUp {
            return
        }
        global.isGlobalListenerSetUp = true
        
        global.db.collection("global")
            .whereField("id", isEqualTo: "18")
            .addSnapshotListener { (snapshot, error) in
                snapshot!
                    .documentChanges
                    .forEach { documentChange in
                        if documentChange.type == .modified {
                            global.webServerLink = documentChange.document.get("webServerLink") as! String
                            global.announcementText = documentChange.document.get("announcementText") as! String
                            global.announcementLink = documentChange.document.get("announcementLink") as! String
                            global.maintenanceText = documentChange.document.get("maintenanceText") as! String
                            global.updateText = documentChange.document.get("updateText") as! String
                            let isUnderMaintenance = documentChange.document.get("isUnderMaintenance") as! Bool
                            
                            let currentBuild = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as! String)
                            let minimumBuild = documentChange.document.get("minimumBuild") as! Int
                            let mustUpdate = currentBuild! < minimumBuild
                            
                            if isUnderMaintenance { // MaintenanceView takes precedence.
                                global.activeRootView = .maintenance
                            } else if mustUpdate {
                                global.activeRootView = .update
                            } else if global.activeRootView == .maintenance ||
                                        global.activeRootView == .update {
                                global.activeRootView = .loading
                            }
                        }
                    }
            }
    }
    
    func getReferenceTime(completion: @escaping (ReferenceTime) -> Void) {
        let client = TrueTimeClient.sharedInstance
        client.pause() // Prepare client to start again when this view is reloaded.
        client.start()
        
        client.fetchIfNeeded(completion: { result in
            switch result {
            case let .success(referenceTime):
                completion(referenceTime)
            case .failure(_):
                break
            }
        })
    }
    
    func handleAuthentication() {
        let user = Auth.auth().currentUser
        let displayName = user?.displayName ?? ""
        if user == nil ||
            displayName == "" {
            global.activeRootView = .welcome
            return
        }
        
        global.myId = displayName
        global.db.collection("users")
            .document(global.myId)
            .getDocument() { (document, error) in
                global.password = document!.get("password") as! String
                checkUser()
            }
    }
    
    func checkUser() {
        let postString =
            "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
        global.runPhp(script: "checkUser", postString: postString) { json in
            global.likesReceived = json["likesReceived"] as! Int
            global.isPremium = json["isPremium"] as! Bool
            let isBanned = json["isBanned"] as! Bool
            if isBanned {
                global.activeRootView = .banned
                return
            }
            
            global.mustSyncWithServer =
                json["mustSyncWithServer"] as! Bool ||
                global.hasSignedIn || // User may have changed user data on another device.
                users.firstIndex(where: { $0.myId == global.myId }) == nil // The app does not have user's core data.
            getUser()
        }
    }
    
    func getUser() {
        if !global.mustSyncWithServer {
            global.activeRootView = .welcome
            return
        }
        
        let postString =
            "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
        global.runPhp(script: "getUser", postString: postString) { json in
            global.email = json["email"] as! String
            global.username = json["username"] as! String
            global.smallImage = json["smallImage"] as! String
            global.bigImage = json["bigImage"] as! String
            global.genderIndex = json["gender"] as! Int
            global.birthday = (json["birthday"] as! String).toDate(fromFormat: "yyyy-MM-dd")
            global.countryIndex = json["country"] as! Int
            global.interests = (json["interests"] as! String).toInterestsArray()
            global.otherInterests = json["otherInterests"] as! String
            global.intro = json["intro"] as! String
            global.gitHub = json["gitHub"] as! String
            global.linkedIn = json["linkedIn"] as! String
            global.bytesMade = json["bytesMade"] as! Int
            global.likesGiven = json["likesGiven"] as! Int
            global.lastReceivedChatTime = (json["lastReceivedChatTime"] as! String).toDate()
            global.hasByteNotification = json["hasByteNotification"] as! Bool
            global.hasChatNotification = json["hasChatNotification"] as! Bool

            global.blocks = [UserRowData]() // Clear in case mustSyncWithServer is set in server and the app refreshes via CheckUser.
            // If json["blocks"] is empty, it will be NSArray. If not, it will be NSDictionary. So there's no need to make sure blocks.count > 0.
            if let blocks = json["blocks"] as? NSDictionary {
                for i in 1...blocks.count {
                    let row = blocks[String(i)] as! NSDictionary
                    let userRowData = UserRowData(
                        userId: row["buddyId"] as! String,
                        username: row["username"] as! String,
                        isOnline: false,
                        appendTime: (row["blockTime"] as! String).toDate())
                    global.blocks.append(userRowData)
                }
            }
            
            global.activeRootView = .welcome
        }
    }
}
