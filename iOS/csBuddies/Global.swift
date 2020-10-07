//
//  Global.swift
//  csBuddies
//
//  Created by Harry Cha on 5/16/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Firebase
import TrueTime

class Global: ObservableObject {
    // LoadingView
    @Published var db = Firestore.firestore()
    @Published var referenceTime: ReferenceTime?
    @Published var viewId = ViewId(id: .loading)
    @Published var signUpId = SignUpId(id: .selectInterests)
    @Published var isOthersListenerSetUp = false
    @Published var firstLaunchDate = Date()
    @Published var requestedReview = false
    @Published var guestId = ""
    @Published var encodedData = Data()

    // SelectInterestsView
    @Published var interestsOptions = ["C", "C#", "C++", "CSS", "HTML", "Java", "JavaScript", "Kotlin", "PHP", "Python", "SQL", "Swift",
        "Android Development", "Artificial Intelligence", "Competitive Programming", "Data Science", "Ethical Hacking", "Game Development", "iOS Development", "Robotics", "Web Development",
        "Firebase", "Flutter", "Kali Linux", "SwiftUI", "Unity3D", "WordPress"]
    @Published var interests = ""
    @Published var otherInterests = ""
    @Published var levelOptions = ["Beginner", "Experienced"]
    @Published var levelIndex = 0
    
    // SetProfileView
    @Published var genderOptions = ["Male", "Female", "Other", "Private"]
    @Published var genderIndex = 0
    @Published var birthday = Date()
    @Published var countryOptions = ["Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", "Argentina", "Armenia", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Cabo Verde", "Cambodia", "Cameroon", "Canada", "Central African Republic", "Chad", "Chile", "China", "Colombia", "Comoros", "Congo, Democratic Republic of the", "Congo, Republic of the", "Costa Rica", "Cote d'Ivoire", "Croatia", "Cuba", "Cyprus", "Czechia", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Eswatini", "Ethiopia", "Fiji", "Finland", "France", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Greece", "Grenada", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Honduras", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Kosovo", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Mauritania", "Mauritius", "Mexico", "Micronesia", "Moldova", "Monaco", "Mongolia", "Montenegro", "Morocco", "Mozambique", "Myanmar", "Namibia", "Nauru", "Nepal", "Netherlands", "New Zealand", "Nicaragua", "Niger", "Nigeria", "North Korea", "North Macedonia", "Norway", "Oman", "Pakistan", "Palau", "Palestine", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland", "Portugal", "Qatar", "Romania", "Russia", "Rwanda", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Korea", "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname", "Sweden", "Switzerland", "Syria", "Taiwan", "Tajikistan", "Tanzania", "Thailand", "Timor-Leste", "Togo", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "Uruguay", "Uzbekistan", "Vanuatu", "Vatican City", "Venezuela", "Vietnam", "Yemen", "Zambia", "Zimbabwe"]
    @Published var countryIndex = 187 // default is US
    @Published var gitHub = ""
    @Published var linkedIn = ""
    
    // TypeIntroView
    @Published var username = ""
    @Published var image = ""
    @Published var intro = ""
    @Published var password = ""
    @Published var lastVisit = Date()
    @Published var lastUpdate = Date()
    @Published var accountCreation = Date()
    @Published var isPremium = false
    @Published var tabIndex = 0
    
    // SearchView
    @Published var mustSearch = true
    @Published var announcementText = ""
    @Published var announcementLink = ""

    // SearchFilterView
    @Published var filterGenderIndex = 0
    @Published var filterMinAge = 13
    @Published var filterMaxAge = 80
    @Published var filterCountryIndex = 0
    @Published var filterInterests = ""
    @Published var filterLevelIndex = 0
    @Published var filterHasImage = false
    @Published var filterHasGitHub = false
    @Published var filterHasLinkedIn = false
    @Published var filterSortIndex = 0
    
    @Published var newFilterGenderIndex = 0
    @Published var newFilterMinAge = 13
    @Published var newFilterMaxAge = 80
    @Published var newFilterAgeRange = 0.0...1.0
    @Published var newFilterCountryIndex = 0
    @Published var newFilterInterests = ""
    @Published var newFilterLevelIndex = 0
    @Published var newFilterHasImage = false
    @Published var newFilterHasGitHub = false
    @Published var newFilterHasLinkedIn = false
    @Published var newFilterSortIndex = 0
    
    @Published var hasAppliedFilters = false
    var admobRewardedAdsFilter = AdmobRewardedAdsFilter() // if it's not global, it will take some time to load
    
    // ChatView
    @Published var mustVisitChatRoom = false
    @Published var notificationBuddyUsername = ""
    @Published var currentBuddyUsername = ""
    @Published var lastShownPrepermissionAlertInChatView = Date(timeIntervalSince1970: 0)
    @Published var lastShownPrepermissionAlertInChatRoomView = Date(timeIntervalSince1970: 0)
    @Published var mustUpdateBadges = false
    
    @Published var chatHistory = [String: [ChatRoomMessageData]]()
    @Published var buddyImageList = [String: String]()
    @Published var blockedList = [String]()
    var admobRewardedAdsNewChat = AdmobRewardedAdsNewChat() // if it's not global, it will take some time to load

    // ProfileEditView
    @Published var editImage = ""
    @Published var editGenderIndex = 0
    @Published var editBirthday = Date()
    @Published var editCountryIndex = 0
    @Published var editGitHub = ""
    @Published var editLinkedIn = ""
    @Published var editInterests = ""
    @Published var editOtherInterests = ""
    @Published var editLevelIndex = 0
    @Published var editIntro = ""
    
    // Global Functions
    func getUtcTime() -> Date {
        return referenceTime!.now()
    }
    
    func runPhp(script: String, postString: String, completion: @escaping (NSDictionary) -> Void) {
        //print("script: \(script)")
        //print("postString: \(postString)")
        
        let myUrl = URL(string: "http://ec2-54-184-108-149.us-west-2.compute.amazonaws.com/18/\(script).php");
        var request = URLRequest(url: myUrl!)
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            //let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            //print("response string = \(String(describing: responseString))")
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
            DispatchQueue.main.async {
                if json != nil {
                    completion(json!)
                } else {
                    completion([:] as NSDictionary)
                }
            }
        }
        task.resume()
    }
    
    func linkToReview() {
        let productUrl = URL(string: "https://apps.apple.com/app/id1524982759")
        
        var components = URLComponents(url: productUrl!, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "action", value: "write-review")
        ]
        
        let writeReviewUrl = components?.url
        UIApplication.shared.open(writeReviewUrl!)
    }

    func hasDeterminedPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { notificationSettings in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                completion(false)
            default:
                completion(true)
            }
        }
    }
    
    func requestPermission() {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if granted == true && error == nil { // if permission is granted
                    // FCM takes time to be received and FCM may be received twice on app reinstall, so set FCM here instead of when launching the app.
                    let postString =
                        "username=\(self.username.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                        "password=\(self.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                        "fcm=\(Messaging.messaging().fcmToken!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
                    self.runPhp(script: "updateFcm", postString: postString) { json in }
                }
            }
    }
    
    func listenToNewMessages() {
        db.collection("messages")
            .whereField("receiver", isEqualTo: username)
            .whereField("isRead", isEqualTo: false)
            .whereField("isDeleted", isEqualTo: false)
            .addSnapshotListener { (snapshot, error) in
                snapshot!
                    .documentChanges
                    .forEach { documentChange in
                        if (documentChange.type == .added) {
                            let chatRoomMessageData = ChatRoomMessageData(
                                id: documentChange.document.documentID,
                                sender: documentChange.document.get("sender") as! String,
                                receiver: self.username,
                                sentTime: (documentChange.document.get("sentTime") as! Timestamp).dateValue(),
                                content: documentChange.document.get("content") as! String,
                                isRead: false,
                                isDeleted: false)

                            // Get unread message as long as user didn't already receive it.
                            if !(self.chatHistory[chatRoomMessageData.sender] != nil &&
                                self.chatHistory[chatRoomMessageData.sender]!.filter({$0.id == chatRoomMessageData.id}).count != 0) {
                                self.getMessage(chatRoomMessageData: chatRoomMessageData, documentChange: documentChange)
                            }
                        }
                }
        }
    }
    
    func toResizedString(uiImage: UIImage) -> String {
        var actualHeight = Float(uiImage.size.height)
        var actualWidth = Float(uiImage.size.width)
        let maxHeight: Float = 200.0
        let maxWidth: Float = 200.0
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.5
        
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        uiImage.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = img?.jpegData(compressionQuality: CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        // Change data straight to string here instead of changing data to UIImage to string since the latter results in much longer string.
        return imageData!.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }

    func deleteChatRoom(buddyUsername: String) {
        chatHistory[buddyUsername] = nil
        
        db.collection("messages")
            .whereField("sender", isEqualTo: buddyUsername)
            .whereField("receiver", isEqualTo: username)
            .whereField("isRead", isEqualTo: false)
            .getDocuments() { (querySnapshot, err) in
                for document in querySnapshot!.documents {
                    document.reference
                        .setData(["isDeleted": true], merge: true)
                }
        }
    }
    
    func getUnreadCounter() -> Int {
        var unreadCounter = 0
        for (_, chatRoomMessageDataList) in chatHistory {
            for chatRoomMessageData in chatRoomMessageDataList {
                if chatRoomMessageData.sender != username &&
                    !chatRoomMessageData.isRead {
                    unreadCounter += 1
                }
            }
        }
        return unreadCounter
    }
    
    func getMessage(chatRoomMessageData: ChatRoomMessageData, documentChange: DocumentChange) {
        let buddyUsername = chatRoomMessageData.sender
        
        if chatHistory[buddyUsername] != nil {
            chatHistory[buddyUsername]!.append(chatRoomMessageData)
        } else {
            chatHistory[buddyUsername] = [chatRoomMessageData]
            if buddyImageList[buddyUsername] == nil {
                let postString =
                    "username=\(buddyUsername.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                    "hasImage=true"
                runPhp(script: "getOtherUser", postString: postString) { json in
                    self.buddyImageList[buddyUsername] = (json["image"] as! String)
                }
            }
        }
        
        if currentBuddyUsername == buddyUsername {
            markRead(documentId: documentChange.document.documentID)
        }
    }
    
    func markRead(documentId: String) {
        if chatHistory[currentBuddyUsername] != nil {
            for index in chatHistory[currentBuddyUsername]!.indices {
                if chatHistory[currentBuddyUsername]![index].sender != username &&
                    !chatHistory[currentBuddyUsername]![index].isRead {
                    chatHistory[currentBuddyUsername]![index].isRead = true
                    mustUpdateBadges = true
                }
            }
        }
        
        db.collection("messages")
            .document(documentId)
            .setData(["isRead": true], merge: true)
    }
    
    func block(buddyUsername: String) {
        blockedList.append(buddyUsername)
        
        let postString =
            "username=\(username.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "password=\(password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "buddyUsername=\(buddyUsername.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
        runPhp(script: "blockUser", postString: postString) { json in }
    }
    
    func unblock(buddyUsername: String) {
        blockedList = blockedList.filter { $0 != "\(buddyUsername)" }
        
        let postString =
            "username=\(username.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "password=\(password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "buddyUsername=\(buddyUsername.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
        runPhp(script: "unblockUser", postString: postString) { json in }
    }
    
    func cancelButton(presentation: Binding<PresentationMode>) -> some View {
        return Button(action: {
            presentation.wrappedValue.dismiss()
        }) {
            HStack {
                Text("Cancel")
            }
        }
    }
}

// Global Structs
struct ViewId: Identifiable {
    enum Id {
        case
            maintenance,
            update,
            banned,
            signUp,
            loading,
            tabs
    }
    var id: Id
}

struct SignUpId: Identifiable {
    enum Id {
        case
            selectInterests,
            setProfile,
            typeIntro
    }
    var id: Id
}

// Global Extensions
extension Date {
    // Convert UTC (or GMT) to local time.
    func toLocal() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    // Convert birthday to age.
    func toAge() -> Int {
        return Calendar.current.dateComponents([.year], from: self, to: globalObject.getUtcTime()).year!
    }

    // Convert date to string.
    func toString(toFormat: String, hasTime: Bool = true) -> String {
        let df = DateFormatter()
        df.dateFormat = toFormat
        if hasTime { // if date has time regardless of its format
            df.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        }
        return df.string(from: self)
    }
}

extension String {
    // Check if URL is valid.
    var isValidUrl: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }

    // Convert string in date format to date.
    func toDate(fromFormat: String, hasTime: Bool = true) -> Date {
        let df = DateFormatter()
        df.dateFormat = fromFormat
        if hasTime { // if date has time regardless of its format
            df.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        }
        return df.date(from: self) ?? globalObject.getUtcTime()
    }
    
    // Convert interests to readable interests.
    func toReadableInterests() -> String {
        let droppedFirstAndLast = String(self.dropFirst().dropLast())
        return droppedFirstAndLast.replacingOccurrences(of: "&&", with: ", ", options: .literal, range: nil)
    }

    // Convert string in Base64 to UIImage.
    func toUiImage() -> UIImage {
        let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters)
        return data != nil ? UIImage(data: data!)! : UIImage()
    }

    // Convert interests to isSelected list.
    func toIsSelectedList() -> [Bool] {
        let droppedFirstAndLast = String(self.dropFirst().dropLast())
        let selectedInterests = droppedFirstAndLast.components(separatedBy: "&&")
        var isSelectedList = [Bool](repeating: false, count: globalObject.interestsOptions.count)
        for selectedInterestsIndex in selectedInterests.indices {
            for interestsIndex in globalObject.interestsOptions.indices {
                if selectedInterests[selectedInterestsIndex] == globalObject.interestsOptions[interestsIndex] {
                    isSelectedList[interestsIndex] = true
                }
            }
        }
        return isSelectedList
    }
    
    // Convert blocks to blocked list.
    func toBlockedList() -> [String] {
        if self.count == 0 {
            return [String]()
        }
        
        let droppedFirstAndLast = String(self.dropFirst().dropLast())
        return droppedFirstAndLast.components(separatedBy: "&&")
    }
}

extension CharacterSet {
    // Allow sending symbols like & to PHP.
    static let rfc3986Unreserved = CharacterSet(charactersIn:
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
}

extension StringProtocol {
    // Access a character at index of a string.
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: Range<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
}

extension UIImage {
    // Convert UIImage to string in Base64.
    func toString() -> String {
        let data = self.pngData()
        return data!.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
}

extension View {
    // Round list's corners.
    public func roundCorners() -> some View {
        if #available(iOS 14.0, *) {
            return AnyView(self
                .listStyle(InsetGroupedListStyle()))
        } else {
            return AnyView(self
                .listStyle(GroupedListStyle())
                .environment(\.horizontalSizeClass, .regular))
        }
    }
    
    // Remove list's line separators
    public func removeLineSeparators() -> some View {
        if #available(iOS 14.0, *) {
            return AnyView(self
                .listStyle(SidebarListStyle())
                .padding(.horizontal, -20))
        } else {
            return AnyView(self
                .introspectTableView { tableView in // change tableView only for this view
                    tableView.separatorStyle = .none
                })
        }
    }
    
    // Remove list's header padding
    public func removeHeaderPadding() -> some View {
        return AnyView(self
            .introspectTableView { tableView in // change tableView only for this view
                tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
            })
    }

    // Add a modifier based on a condition.
    func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
        if conditional {
            return AnyView(content(self))
        } else {
            return AnyView(self)
        }
    }

    // Flip view to scroll down automatically.
    public func flip() -> some View {
        return self
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}

extension Array {
    // Convert isSelected list to interests.
    func toInterests() -> String {
        var interests = ""
        for index in globalObject.interestsOptions.indices {
            if self[index] as! Bool {
                interests += "&" + globalObject.interestsOptions[index] + "&"
            }
        }
        return interests
    }
}

extension Collection where Indices.Iterator.Element == Index {
    // Provide default value on index out of range error.
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
