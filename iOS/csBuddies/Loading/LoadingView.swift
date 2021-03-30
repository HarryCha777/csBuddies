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
    @FetchRequest(entity: User.entity(), sortDescriptors: []) var coreDataUsers: FetchedResults<User>
    
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
            //global.hasUserDataLoaded = false // Make sure user data does not get changed while loading on sign in.
            if !Reachability.isConnectedToNetwork() {
                global.isOffline = true
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showLoadingIndicator = true
            }
            
            getConfig {
                if global.activeRootView == .loading {
                    getReferenceTime() { referenceTime in
                        global.referenceTime = referenceTime
                        
                        if !global.hasUserDataLoaded {
                            loadUserData()
                            global.hasUserDataLoaded = true
                        }
                        
                        global.firebaseUser = Auth.auth().currentUser
                        getMyId() { myId in
                            global.myId = myId
                            
                            if global.myId == "" {
                                global.activeRootView = .tabs
                            } else {
                                global.smallImageCache.setObject(ImageCache(image: global.smallImage, lastCachedAt: global.getUtcTime()), forKey: global.myId as NSString)
                                global.bigImageCache.setObject(ImageCache(image: global.bigImage, lastCachedAt: global.getUtcTime()), forKey: global.myId as NSString)
                                
                                signIn() {
                                    global.websocket = Websocket()
                                    if global.username == "" { // The app does not have user's core data or isClientOutdated cleared global.username. Use global.username because global.myId cannot be used.
                                        getUser() {
                                            global.activeRootView = .welcome
                                        }
                                    } else {
                                        global.activeRootView = .tabs
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getConfig(completion: @escaping () -> Void) {
        global.runHttp(script: "getConfig", postString: "") { json in
            global.announcementText = json["announcementText"] as! String
            global.announcementLink = json["announcementLink"] as! String
            global.maintenanceText = json["maintenanceText"] as! String
            global.updateText = json["updateText"] as! String
            let isUnderMaintenance = json["isUnderMaintenance"] as! Bool
            
            let currentVersion = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as! String)
            let updateVersion = json["updateVersion"] as! Int
            let mustUpdate = currentVersion! < updateVersion
            
            if isUnderMaintenance { // MaintenanceView takes precedence.
                global.activeRootView = .maintenance
            } else if mustUpdate {
                global.activeRootView = .update
            }
            
            completion()
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
    
    func loadUserData() {
        if coreDataUsers.count == 0 {
            return
        }
        
        let coreDataUser = coreDataUsers[0]
        
        global.username = coreDataUser.username ?? ""
        global.smallImage = coreDataUser.smallImage ?? ""
        global.bigImage = coreDataUser.bigImage ?? ""
        global.gender = Int(coreDataUser.gender)
        global.birthday = coreDataUser.birthday ?? Date(timeIntervalSince1970: 946684800) // Default birthday is 1/1/2000 12:00:00 AM UTC.
        global.country = Int(coreDataUser.country)
        global.interests = coreDataUser.interests as? [String] ?? [String]()
        global.otherInterests = coreDataUser.otherInterests ?? ""
        global.intro = coreDataUser.intro ?? ""
        global.github = coreDataUser.github ?? ""
        global.linkedin = coreDataUser.linkedin ?? ""
        
        global.notifyLikes = coreDataUser.notifyLikes
        global.notifyComments = coreDataUser.notifyComments
        global.notifyMessages = coreDataUser.notifyMessages
        global.bytesMade = Int(coreDataUser.bytesMade)
        global.commentsMade = Int(coreDataUser.commentsMade)
        global.byteLikesReceived = Int(coreDataUser.byteLikesReceived)
        global.commentLikesReceived = Int(coreDataUser.commentLikesReceived)
        global.byteLikesGiven = Int(coreDataUser.byteLikesGiven)
        global.commentLikesGiven = Int(coreDataUser.commentLikesGiven)
        global.blockedBuddyIds = coreDataUser.blockedBuddyIds as? [String] ?? [String]()
        do {
            global.inboxData = try JSONDecoder().decode(InboxData.self, from: coreDataUser.inboxBinaryData ?? Data())
            global.chatData = try JSONDecoder().decode([String: ChatRoomData].self, from: coreDataUser.chatBinaryData ?? Data())
            for buddyId in global.chatData.keys {
                for index in global.chatData[buddyId]!.messages.indices {
                    global.chatData[buddyId]!.messages[index].isSending = false
                }
            }
        } catch {}
        
        global.byteDraft = coreDataUser.byteDraft ?? ""
        global.commentDraft = coreDataUser.commentDraft ?? ""
        global.messageDrafts = coreDataUser.messageDrafts as? [String: String] ?? [String: String]()
        
        global.buddiesFilterGender = Int(coreDataUser.buddiesFilterGender)
        global.buddiesFilterMinAge = Int(coreDataUser.buddiesFilterMinAge)
        global.buddiesFilterMaxAge = Int(coreDataUser.buddiesFilterMaxAge)
        if global.buddiesFilterMinAge < 13 || global.buddiesFilterMinAge > 130 ||
            global.buddiesFilterMaxAge < 13 || global.buddiesFilterMaxAge > 130 ||
            global.buddiesFilterMinAge > global.buddiesFilterMaxAge {
            global.buddiesFilterMinAge = 13
            global.buddiesFilterMaxAge = 130
        }
        global.buddiesFilterCountry = Int(coreDataUser.buddiesFilterCountry)
        global.buddiesFilterInterests = coreDataUser.buddiesFilterInterests as? [String] ?? [String]()
        global.buddiesFilterSort = Int(coreDataUser.buddiesFilterSort)
        global.bytesFilterSort = Int(coreDataUser.bytesFilterSort)
        global.firstLaunchedAt = coreDataUser.firstLaunchedAt ?? global.getUtcTime()
        global.hasAskedReview = coreDataUser.hasAskedReview
        global.hasAskedNotification = coreDataUser.hasAskedNotification
    }
    
    func getMyId(completion: @escaping (String) -> Void) {
        if global.firebaseUser == nil {
            completion("")
            return
        }
        
        global.firebaseUser!.getIDTokenResult(completion: { (result, error) in
            if result!.claims["userId"] as? String == nil { // User verified email but didn't make a profile.
                completion("")
                return
            }
            
            completion(result!.claims["userId"] as! String)
        })
    }
    
    func signIn(completion: @escaping () -> Void) {
        if !global.hasSignedIn {
            completion()
            return
        }
        
        global.firebaseUser!.getIDToken(completion: { (token, error) in
            let postString =
                "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "fcmToken=\(Messaging.messaging().fcmToken!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
            global.runHttp(script: "signIn", postString: postString) { json in
                global.hasSignedIn = false
                completion()
            }
        })
    }
    
    func getUser(completion: @escaping () -> Void) {
        global.firebaseUser!.getIDToken(completion: { (token, error) in
            let postString =
                "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
            global.runHttp(script: "getUser", postString: postString) { json in
                global.username = json["username"] as! String
                global.smallImage = json["smallImage"] as! String
                global.bigImage = json["bigImage"] as! String
                global.gender = json["gender"] as! Int
                global.birthday = (json["birthday"] as! String).toDate(hasTime: false)
                global.country = json["country"] as! Int
                global.interests = (json["interests"] as! String).toInterestsArray()
                global.otherInterests = json["otherInterests"] as! String
                global.intro = json["intro"] as! String
                global.github = json["github"] as! String
                global.linkedin = json["linkedin"] as! String
                
                global.notifyLikes = json["notifyLikes"] as! Bool
                global.notifyComments = json["notifyComments"] as! Bool
                global.notifyMessages = json["notifyMessages"] as! Bool
                global.bytesMade = json["bytesMade"] as! Int
                global.commentsMade = json["commentsMade"] as! Int
                global.byteLikesReceived = json["byteLikesReceived"] as! Int
                global.commentLikesReceived = json["commentLikesReceived"] as! Int
                global.byteLikesGiven = json["byteLikesGiven"] as! Int
                global.commentLikesGiven = json["commentLikesGiven"] as! Int
                
                global.blockedBuddyIds = [String]()
                if let blockedBuddyIds = json["blockedBuddyIds"] as? NSArray {
                    for i in 0...blockedBuddyIds.count - 1 {
                        let row = blockedBuddyIds[i] as! NSDictionary
                        global.blockedBuddyIds.append(row["buddyId"] as! String)
                    }
                }
                
                completion()
            }
        })
    }
}
