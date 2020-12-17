//
//  BuddiesProfileContentView.swift
//  csBuddies
//
//  Created by Harry Cha on 11/1/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct BuddiesProfileContentView: View {
    @EnvironmentObject var global: Global
    @Environment(\.colorScheme) var colorScheme
    
    var userProfileData: UserProfileData
    var isRefreshing: Bool
    
    @State private var hasRunOnAppear = false
    @State private var mustVisitBigImage = false
    @State private var hasExpanded = false
    @State private var hasTruncated = false
    @State private var bytesTabIndex = 0
    
    @State private var bytes = [BytesPostData]()
    @State private var bottomPostTime = Date()
    @State private var isLoadingBytes = false
    @State private var canLoadMoreBytes = true
    
    @State private var likedBytes = [BytesPostData]()
    @State private var bottomLikeTime = Date()
    @State private var isLoadingLikedBytes = false
    @State private var canLoadMoreLikedBytes = true
    
    var body: some View {
        ZStack {
            if isRefreshing {
                Spacer()
                    .onAppear {
                        bytesTabIndex = 0
                        bottomPostTime = global.getUtcTime()
                        bottomLikeTime = global.getUtcTime()
                        bytes.removeAll()
                        likedBytes.removeAll()
                        getBytes()
                        getLikedBytes()
                    }
            }
            
            List {
                HStack {
                    VStack {
                        Spacer()
                        Button(action: {
                            mustVisitBigImage = true
                        }) {
                            SmallImageView(userId: userProfileData.userId, isOnline: userProfileData.isOnline, size: 75, myImage: global.smallImage)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .fullScreenCover(isPresented: $mustVisitBigImage) {
                            BigImageView(userId: userProfileData.userId)
                        }
                        Spacer()
                    }
                    
                    Spacer()
                        .frame(width: 15)
                    
                    VStack(alignment: .leading) {
                        Text(userProfileData.username)
                            .bold()
                        HStack {
                            if userProfileData.genderIndex == 0 {
                                Text(global.genderOptions[userProfileData.genderIndex])
                                    .font(.footnote)
                                    .foregroundColor(Color.blue) +
                                    Text(",")
                                    .font(.footnote)
                            } else if userProfileData.genderIndex == 1 {
                                Text(global.genderOptions[userProfileData.genderIndex])
                                    .font(.footnote)
                                    .foregroundColor(Color(red: 255 / 255, green: 20 / 255, blue: 147 / 255)) + // This is pink color.
                                    Text(",")
                                    .font(.footnote)
                            } else if userProfileData.genderIndex == 2 ||
                                        userProfileData.genderIndex == 3 {
                                Text(global.genderOptions[userProfileData.genderIndex])
                                    .font(.footnote)
                                    .foregroundColor(Color.gray) +
                                    Text(",")
                                    .font(.footnote)
                            } else {
                                Text("Unknown")
                                    .font(.footnote) +
                                    Text(",")
                                    .font(.footnote)
                            }
                            Text(userProfileData.birthday.toString()[0] != "0" ? "\(userProfileData.birthday.toAge())" : "N/A")
                                .font(.footnote)
                        }
                        Text(global.countryOptions[safe: userProfileData.countryIndex] ?? "Unknown")
                            .font(.footnote)
                        HStack {
                            if userProfileData.isOnline {
                                HStack {
                                    Circle()
                                        .frame(width: 8, height: 8)
                                        .foregroundColor(Color.white)
                                    Text("Online")
                                        .font(.footnote)
                                        .foregroundColor(Color.white)
                                }
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .cornerRadius(5)
                            } else {
                                Text("Online \(Calendar.current.date(byAdding: .second, value: global.onlineTimeout, to: userProfileData.lastVisitTime)!.toTimeDifference(hasExtension: true))")
                                    .font(.footnote)
                            }
                        }
                    }
                }
                
                Section(header: Text("Self-Introduction")) {
                    TruncatedText(text: userProfileData.intro, hasExpanded: $hasExpanded, hasTruncated: $hasTruncated)
                    if userProfileData.gitHub.count != 0 {
                        NavigationLink(destination:
                                        WebView(request: URLRequest(url: (URL(string: "https://www.github.com/\(userProfileData.gitHub)") ?? URL(string: "https://www.github.com"))!))
                                        .navigationBarTitle("GitHub", displayMode: .inline)
                        ) {
                            Image("gitHubLogo")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .if(colorScheme == .dark) { content in
                                    content.colorInvert() // Invert color on dark mode.
                                }
                            Text("github.com/\(userProfileData.gitHub)")
                                .foregroundColor(Color.blue)
                        }
                    }
                    if userProfileData.linkedIn.count != 0 {
                        NavigationLink(destination:
                                        WebView(request: URLRequest(url: (URL(string: "https://linkedin.com/in/\(userProfileData.linkedIn)") ?? URL(string: "https://linkedin.com"))!))
                                        .navigationBarTitle("LinkedIn", displayMode: .inline)
                        ) {
                            Image("linkedInLogo")
                                .resizable()
                                .frame(width: 22, height: 22)
                            Text("linkedin.com/in/\(userProfileData.linkedIn)")
                                .foregroundColor(Color.blue)
                        }
                    }
                }
                
                Section(header: Text("Interests")) {
                    if userProfileData.interests.count == 0 {
                        Text("No interests selected.")
                    } else {
                        TagsView(
                            data: userProfileData.interests
                        ) { interest in
                            InterestsButtonDisabledView(interest: interest, interests: userProfileData.interests)
                        }
                    }
                }
                
                Section(header: EmptyView()) {
                    VStack {
                        SlidingTabView(selection: $bytesTabIndex, tabs: ["Bytes", "Likes"])
                        
                        if bytesTabIndex == 0 {
                            HStack(spacing: 0) {
                                if userProfileData.bytesMade == 0 {
                                    Text("Posted no bytes, ")
                                        .font(.footnote)
                                } else if userProfileData.bytesMade == 1 {
                                    Text("Posted 1 byte, ")
                                        .font(.footnote)
                                } else {
                                    Text("Posted \(userProfileData.bytesMade) bytes, ")
                                        .font(.footnote)
                                }
                                
                                if userProfileData.likesReceived == 0 {
                                    Text("has no likes")
                                        .font(.footnote)
                                } else if userProfileData.likesReceived == 1 {
                                    Text("has 1 like")
                                        .font(.footnote)
                                } else {
                                    Text("has \(userProfileData.likesReceived) likes")
                                        .font(.footnote)
                                }
                            }
                        } else {
                            if userProfileData.likesGiven == 0 {
                                Text("Likes no bytes")
                                    .font(.footnote)
                            } else if userProfileData.likesGiven == 1 {
                                Text("Likes 1 byte")
                                    .font(.footnote)
                            } else {
                                Text("Likes \(userProfileData.likesGiven) bytes")
                                    .font(.footnote)
                            }
                        }
                    }
                    
                    if bytesTabIndex == 0 {
                        if userProfileData.bytesMade > 0 {
                            ForEach(bytes) { bytesPostData in
                                BytesPostView(bytesPostData: bytesPostData)

                                if bytes.firstIndex(where: { $0.id == bytesPostData.id })! % 10 == 9 &&
                                    bytes.firstIndex(where: { $0.id == bytesPostData.id })! < 500 &&
                                    !global.isPremium {
                                    AdmobNativeAdsBytesView()
                                }
                            }
                            // Do not use .id(UUID()) or bytes do not change when they are liked.
                            
                            HStack {
                                Spacer()
                                if isLoadingBytes {
                                    LottieView(name: "load", size: 300, padding: -50, mustLoop: true)
                                } else if bytes.count == 0 {
                                    LottieView(name: "noData", size: 300, padding: -50)
                                } else {
                                    Text("End")
                                        .onAppear {
                                            if canLoadMoreBytes {
                                                getBytes()
                                            }
                                        }
                                }
                                Spacer()
                            }
                        }
                    } else {
                        if userProfileData.likesGiven > 0 {
                            ForEach(likedBytes) { bytesPostData in
                                BytesPostView(bytesPostData: bytesPostData)

                                if likedBytes.firstIndex(where: { $0.id == bytesPostData.id })! % 10 == 9 &&
                                    likedBytes.firstIndex(where: { $0.id == bytesPostData.id })! < 500 &&
                                    !global.isPremium {
                                    AdmobNativeAdsBytesView()
                                }
                            }
                            // Do not use .id(UUID()) or bytes do not change when they are liked.
                            
                            HStack {
                                Spacer()
                                if isLoadingLikedBytes {
                                    LottieView(name: "load", size: 300, padding: -50, mustLoop: true)
                                } else if likedBytes.count == 0 {
                                    LottieView(name: "noData", size: 300, padding: -50)
                                } else {
                                    Text("End")
                                        .onAppear {
                                            if canLoadMoreLikedBytes {
                                                getLikedBytes()
                                            }
                                        }
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .onAppear {
            if !hasRunOnAppear { // Prevent calling PHP on each tab change.
                hasRunOnAppear = true
                bottomPostTime = global.getUtcTime()
                bottomLikeTime = global.getUtcTime()
                getBytes()
                getLikedBytes()
            }
        }
    }
    
    func getBytes() {
        if isLoadingBytes {
            return
        }
        isLoadingBytes = true
        canLoadMoreBytes = true
        
        let postString =
            "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "userId=\(userProfileData.userId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "bottomPostTime=\(bottomPostTime.toString())"
        global.runPhp(script: "getBytes", postString: postString) { json in
            if json.count <= 1 {
                isLoadingBytes = false
                canLoadMoreBytes = false
                return
            }
            
            for i in 1...json.count - 1 {
                let row = json[String(i)] as! NSDictionary
                let bytesPostData = BytesPostData(
                    byteId: row["byteId"] as! String,
                    userId: userProfileData.userId,
                    username: userProfileData.username,
                    isOnline: global.isOnline(lastVisitTimeAny: row["lastVisitTime"]),
                    content: row["content"] as! String,
                    likes: row["likes"] as! Int,
                    isLiked: row["isLiked"] as! Bool,
                    postTime: (row["postTime"] as! String).toDate())
                bytes.append(bytesPostData)
                updateClientData(bytesPostData: bytesPostData)
            }
            
            let lastRow = json[String(json.count)] as! NSDictionary
            bottomPostTime = (lastRow["bottomPostTime"] as! String).toDate()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Prevent calling PHP twice on each load.
                isLoadingBytes = false
            }
        }
    }
    
    func getLikedBytes() {
        if isLoadingLikedBytes {
            return
        }
        isLoadingLikedBytes = true
        canLoadMoreLikedBytes = true
        
        let postString =
            "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "userId=\(userProfileData.userId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "bottomLikeTime=\(bottomLikeTime.toString())"
        global.runPhp(script: "getLikedBytes", postString: postString) { json in
            if json.count <= 1 {
                isLoadingLikedBytes = false
                canLoadMoreLikedBytes = false
                return
            }
            
            for i in 1...json.count - 1 {
                let row = json[String(i)] as! NSDictionary
                let bytesPostData = BytesPostData(
                    byteId: row["byteId"] as! String,
                    userId: row["userId"] as! String,
                    username: row["username"] as! String,
                    isOnline: global.isOnline(lastVisitTimeAny: row["lastVisitTime"]),
                    content: row["content"] as! String,
                    likes: row["likes"] as! Int,
                    isLiked: row["isLiked"] as! Bool,
                    postTime: (row["postTime"] as! String).toDate())
                likedBytes.append(bytesPostData)
                updateClientData(bytesPostData: bytesPostData)
            }
            
            let lastRow = json[String(json.count)] as! NSDictionary
            bottomLikeTime = (lastRow["bottomLikeTime"] as! String).toDate()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Prevent calling PHP twice on each load.
                isLoadingLikedBytes = false
            }
        }
    }
    
    func updateClientData(bytesPostData: BytesPostData) {
        if global.savedBytes.contains(where: { $0.byteId == bytesPostData.byteId }) {
            let index = global.savedBytes.firstIndex(where: { $0.byteId == bytesPostData.byteId })
            global.savedBytes[index!] = bytesPostData
        }
    }
}

struct UserProfileData: Identifiable, Codable {
    var id = UUID()
    var userId: String
    var username: String
    var genderIndex: Int
    var birthday: Date
    var countryIndex: Int
    var interests: [String]
    var intro: String
    var gitHub: String
    var linkedIn: String
    var isOnline: Bool
    var lastVisitTime: Date
    var bytesMade: Int
    var likesReceived: Int
    var likesGiven: Int

    init(userId: String,
         username: String,
         genderIndex: Int,
         birthday: Date,
         countryIndex: Int,
         interests: [String],
         intro: String,
         gitHub: String,
         linkedIn: String,
         isOnline: Bool,
         lastVisitTime: Date,
         bytesMade: Int,
         likesReceived: Int,
         likesGiven: Int) {
        self.userId = userId
        self.username = username
        self.genderIndex = genderIndex
        self.birthday = birthday
        self.countryIndex = countryIndex
        self.interests = interests
        self.intro = intro
        self.gitHub = gitHub
        self.linkedIn = linkedIn
        self.isOnline = isOnline
        self.lastVisitTime = lastVisitTime
        self.bytesMade = bytesMade
        self.likesReceived = likesReceived
        self.likesGiven = likesGiven
    }
}

struct BuddiesProfileContentView_Previews: PreviewProvider {
    static var previews: some View {
        BuddiesProfileContentView(userProfileData: UserProfileData(userId: "", username: "", genderIndex: 0, birthday: Date(), countryIndex: 0, interests: [String](), intro: "", gitHub: "", linkedIn: "", isOnline: true, lastVisitTime: Date(), bytesMade: 0, likesReceived: 0, likesGiven: 0), isRefreshing: false)
            .environmentObject(globalObject)
    }
}
