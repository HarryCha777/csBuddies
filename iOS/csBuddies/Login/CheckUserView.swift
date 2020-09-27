//
//  CheckUserView.swift
//  csBuddies
//
//  Created by Harry Cha on 5/15/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase
import TrueTime

struct CheckUserView: View {
    @EnvironmentObject var global: Global
    @FetchRequest(entity: GlobalEntity.entity(), sortDescriptors: []) var globalEntityList: FetchedResults<GlobalEntity>
    
    var body: some View {
        LoadingView()
            .foregroundColor(.blue)
            .onAppear {
                self.getReferenceTime() { referenceTime in
                    self.global.referenceTime = referenceTime
                    self.checkUser()
                }
            }
    }
    
    func getReferenceTime(completion: @escaping (ReferenceTime) -> Void) {
        let client = TrueTimeClient.sharedInstance
        client.start()
        
        client.fetchIfNeeded { result in
            switch result {
            case let .success(referenceTime):
                completion(referenceTime)
            case .failure(_):
                break
            }
        }
    }
    
    func checkUser() {
        let user = Auth.auth().currentUser
        if user == nil {
            self.global.isNewUser = true
            self.global.isCheckingUser = false
        } else {
            self.getUser()
        }
    }
    
    func getUser() {
        let user = Auth.auth().currentUser
        global.username = (user?.displayName!)!
        global.password = (user?.uid)!

        let postString =
            "username=\(global.username.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "hasImage=true"
        global.runPhp(script: "getUser", postString: postString) { json in
            // If document does not exist, force the user to create a new account.
            let isNewUser = json["isNewUser"] as! Bool
            if isNewUser {
                try! Auth.auth().signOut()
                self.global.username = ""
                self.checkUser()
                return
            }
            
            let minimumBuild = json["minimumBuild"] as! Int
            let currentBuild = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as! String)
            if currentBuild! < minimumBuild {
                self.global.mustUpdate = true
                self.global.isNewUser = false
                self.global.isCheckingUser = false
                return
            }
            
            let isBanned = json["isBanned"] as! Bool
            if isBanned {
                self.global.isBanned = true
                self.global.isNewUser = false
                self.global.isCheckingUser = false
                return
            }
            
            self.global.image = json["image"] as! String
            self.global.genderIndex = json["gender"] as! Int
            self.global.birthday = (json["birthday"] as! String).toDate(fromFormat: "yyyy-MM-dd", hasTime: false)
            self.global.countryIndex = json["country"] as! Int
            self.global.interests = json["interests"] as! String
            self.global.otherInterests = json["otherInterests"] as! String
            self.global.levelIndex = json["level"] as! Int
            self.global.intro = json["intro"] as! String
            self.global.gitHub = json["gitHub"] as! String
            self.global.linkedIn = json["linkedIn"] as! String
            self.global.lastVisit = self.global.getUtcTime()
            self.global.lastUpdate = (json["lastUpdate"] as! String).toDate(fromFormat: "yyyy-MM-dd HH:mm:ss")
            self.global.accountCreation = (json["accountCreation"] as! String).toDate(fromFormat: "yyyy-MM-dd HH:mm:ss")
            self.global.blockedList = (json["blocks"] as! String).toBlockedList()
            self.global.announcement = json["announcement"] as! String
            self.global.isPremium = json["isPremium"] as! Bool
            
            self.fetchCoreData()
            self.unarchiveData()
            
            let buddyUsernames = self.getBuddyUsernames()
            let postString =
                "username=\(self.global.username.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "password=\(self.global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "buddyUsernames=\(buddyUsernames.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
            self.global.runPhp(script: "getImages", postString: postString) { json in
                if json.count < 1 {
                    self.global.listenToNewMessages()
                    self.global.isNewUser = false
                    self.global.isCheckingUser = false
                    return
                }
                
                for i in 1...json.count {
                    let row = json[String(i)] as! NSDictionary
                    self.global.buddyImageList[row["username"] as! String] = (row["image"] as! String)
                }
                
                self.global.listenToNewMessages()
                self.global.isNewUser = false
                self.global.isCheckingUser = false
            }
        }
    }
    
    func fetchCoreData() {
        if globalEntityList.count == 0 {
            return
        }
        
        let globalEntity = globalEntityList.first!
        global.filterGenderIndex = Int(globalEntity.filterGenderIndex)
        global.filterMinAge = Int(globalEntity.filterMinAge)
        global.filterMaxAge = Int(globalEntity.filterMaxAge)
        global.filterCountryIndex = Int(globalEntity.filterCountryIndex)
        global.filterHasImage = globalEntity.filterHasImage
        global.filterHasGitHub = globalEntity.filterHasGitHub
        global.filterHasLinkedIn = globalEntity.filterHasLinkedIn
        global.filterInterests = globalEntity.filterInterests!
        global.filterLevelIndex = Int(globalEntity.filterLevelIndex)
        global.filterSortIndex = Int(globalEntity.filterSortIndex)
        global.firstLaunchDate = globalEntity.firstLaunchDate ?? global.getUtcTime()
        global.requestedReview = globalEntity.requestedReview
        global.encodedData = globalEntity.encodedData!
    }
    
    func unarchiveData() {
        if globalEntityList.count == 0 {
            return
        }
        
        let unarchiver = try! NSKeyedUnarchiver(forReadingFrom: global.encodedData)
        global.chatHistory = unarchiver.decodeDecodable([String: [ChatRoomMessageData]].self, forKey: "chatHistory")!
        unarchiver.finishDecoding()
    }
    
    func getBuddyUsernames() -> String {
        var buddyUsernames = ""
        for (key, _) in global.chatHistory {
            buddyUsernames += "&" + key + "&"
        }
        return buddyUsernames
    }
}

struct CheckUserView_Previews: PreviewProvider {
    static var previews: some View {
        CheckUserView()
    }
}
