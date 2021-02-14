//
//  Global.swift
//  csBuddies
//
//  Created by Harry Cha on 5/16/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import CoreData
import Firebase
import TrueTime

var globalObject = Global()

class Global: ObservableObject {
    // AppView
    @Published var isOffline = false
    
    @Published var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            cannotBlockAdmin
    }

    // LoadingView
    @Published var db = Firestore.firestore()
    @Published var webServerLink = ""
    @Published var referenceTime: ReferenceTime?
    @Published var activeRootView: RootViews = .loading
    @Published var firebaseUser = Auth.auth().currentUser
    @Published var myId = ""
    @Published var isGlobalListenerSetUp = false
    @Published var firstLaunchedAt = Date() { didSet { saveUserData() } }
    @Published var hasAskedReview = false { didSet { saveUserData() } }
    @Published var hasUserDataLoaded = false
    @Published var onlineTimeout = 60 * 3
    
    // WelcomeView
    @Published var hasSignedIn = false
    @Published var isAccountsListenerSetUp = false
    @Published var accountsListener: ListenerRegistration?

    // MaintenanceView
    @Published var maintenanceText = ""

    // UpdateView
    @Published var updateText = ""
    
    // TypeEmailView
    @Published var email = ""
    
    // SetInterestsView
    // Sort interestsOptions case insensitive for words like "iOS".
    @Published var interestOptions = ["C", "C#", "C++", "CSS", "Dart", "Go", "HTML", "Java", "JavaScript", "Kotlin", "MATLAB", "Obj-C", "Perl", "PHP", "Python", "R", "Ruby", "Rust", "Scala", "SQL", "Swift", "TypeScript", "Visual Basic",
                                       "AngularJS", "Django", "Firebase", "Flask", "Flutter", "Kali Linux", "NodeJS", "React Native", "ReactJS", "SwiftUI", "Unity3D", "VueJS", "Weebly", "Wix", "WordPress", "Xamarin",
                                       "AI", "Android Dev", "Architecture", "Competitive Programming", "Cybersecurity", "Data Science", "DB", "Game Dev", "Hardware", "iOS Dev", "IoT", "Network", "OS", "Robotics", "UI / UX Design", "Web Dev"]
    @Published var interests = [String]() { didSet { saveUserData() } }
    @Published var otherInterests = "" { didSet { saveUserData() } }

    // SetUserProfileView
    @Published var genderOptions = ["Male", "Female", "Other", "Private"]
    @Published var genderIndex = 0 { didSet { saveUserData() } }
    @Published var birthday = Date(timeIntervalSince1970: 946684800) { didSet { saveUserData() } } // Default birthday is 1/1/2000 12:00:00 AM UTC.
    @Published var countryOptions = ["Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", "Argentina", "Armenia", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Cabo Verde", "Cambodia", "Cameroon", "Canada", "Central African Republic", "Chad", "Chile", "China", "Colombia", "Comoros", "Congo, Democratic Republic of the", "Congo, Republic of the", "Costa Rica", "Cote d'Ivoire", "Croatia", "Cuba", "Cyprus", "Czechia", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Eswatini", "Ethiopia", "Fiji", "Finland", "France", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Greece", "Grenada", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Honduras", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Kosovo", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Mauritania", "Mauritius", "Mexico", "Micronesia", "Moldova", "Monaco", "Mongolia", "Montenegro", "Morocco", "Mozambique", "Myanmar", "Namibia", "Nauru", "Nepal", "Netherlands", "New Zealand", "Nicaragua", "Niger", "Nigeria", "North Korea", "North Macedonia", "Norway", "Oman", "Pakistan", "Palau", "Palestine", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland", "Portugal", "Qatar", "Romania", "Russia", "Rwanda", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Korea", "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname", "Sweden", "Switzerland", "Syria", "Taiwan", "Tajikistan", "Tanzania", "Thailand", "Timor-Leste", "Togo", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "Uruguay", "Uzbekistan", "Vanuatu", "Vatican City", "Venezuela", "Vietnam", "Yemen", "Zambia", "Zimbabwe"]
    @Published var countryIndex = 187 { didSet { saveUserData() } } // Default country is US.
    @Published var gitHub = "" { didSet { saveUserData() } }
    @Published var linkedIn = "" { didSet { saveUserData() } }
    
    // TypeIntroView
    @Published var username = "" { didSet { saveUserData() } }
    @Published var smallImage = "" {
        didSet {
            saveUserData()
            smallImageCache.setObject(ImageCache(image: smallImage, lastCachedAt: getUtcTime()), forKey: myId as NSString)
        }
    }
    @Published var bigImage = "" {
        didSet {
            saveUserData()
            bigImageCache.setObject(ImageCache(image: bigImage, lastCachedAt: getUtcTime()), forKey: myId as NSString)
        }
    }
    @Published var smallImageCache = NSCache<NSString, ImageCache>()
    @Published var bigImageCache = NSCache<NSString, ImageCache>()
    @Published var hasImageCacheUpdated = false
    @Published var intro = "" { didSet { saveUserData() } }
    @Published var isPremium = false
    @Published var isAdmin = false
    @Published var tabIndex = 0
    
    // TabsView
    @Published var isKeyboardHidden = true

    // ConfirmationView
    @Published var confirmationText = ""

    // BuddiesView
    @Published var announcementText = ""
    @Published var announcementLink = ""
    
    // UserView
    @Published var userPreviews = [String: UserPreviewData]()
    @Published var users = [String: UserData]()
    @Published var blockedBuddyIds = [String]() { didSet { saveUserData() } }

    // BuddiesFilterView
    @Published var buddiesFilterGenderIndex = 0 { didSet { saveUserData() } }
    @Published var buddiesFilterMinAge = 13 { didSet { saveUserData() } }
    @Published var buddiesFilterMaxAge = 130 { didSet { saveUserData() } }
    @Published var buddiesFilterCountryIndex = 0 { didSet { saveUserData() } }
    @Published var buddiesFilterInterests = [String]() { didSet { saveUserData() } }
    @Published var buddiesFilterSortIndex = 0 { didSet { saveUserData() } }

    @Published var newBuddiesFilterGenderIndex = 0
    @Published var newBuddiesFilterMinAge = 13
    @Published var newBuddiesFilterMaxAge = 130
    @Published var newBuddiesFilterCountryIndex = 0
    @Published var newBuddiesFilterInterests = [String]()
    @Published var newBuddiesFilterSortIndex = 0

    // BytesView
    @Published var bytes = [String: ByteData]()
    
    // InboxView
    @Published var inboxData = InboxData() {
        didSet {
            saveUserData()
            UIApplication.shared.applicationIconBadgeNumber = self.getUnreadNotificationsCounter() + self.getUnreadMessagesCounter()
        }
    }
    
    // ByteWriteView
    @Published var byteDraft = "" { didSet { saveUserData() } }
    
    // CommentView
    @Published var comments = [String: CommentData]()
    
    // CommentWriteView
    @Published var commentDraft = "" { didSet { saveUserData() } }
    
    // BytesFilterView
    @Published var bytesFilterSortIndex = 0 { didSet { saveUserData() } }
    
    @Published var newBytesFilterSortIndex = 0 { didSet { saveUserData() } }
    
    // ChatView
    @Published var hasAskedNotification = false { didSet { saveUserData() } }

    @Published var chatBuddyId = ""
    @Published var chatBuddyUsername = ""

    @Published var chatData = [String: ChatRoomData]() {
        didSet {
            saveUserData()
            UIApplication.shared.applicationIconBadgeNumber = self.getUnreadNotificationsCounter() + self.getUnreadMessagesCounter()
            for buddyId in chatData.keys {
                if chatData[buddyId]!.messages.count == 0 {
                    chatData[buddyId] = nil
                }
            }
        }
    }

    // MessageInputView
    @Published var messageDrafts = [String: String]() { didSet { saveUserData() } }

    // UserProfileView
    @Published var bytesMade = 0 { didSet { saveUserData() } }
    @Published var commentsMade = 0 { didSet { saveUserData() } }
    @Published var byteLikesReceived = 0
    @Published var commentLikesReceived = 0
    @Published var byteLikesGiven = 0 { didSet { saveUserData() } }
    @Published var commentLikesGiven = 0 { didSet { saveUserData() } }

    // ProfileEditView
    @Published var newSmallImage = ""
    @Published var newBigImage = ""
    @Published var newGenderIndex = 0
    @Published var newBirthday = Date()
    @Published var newCountryIndex = 0
    @Published var newGitHub = ""
    @Published var newLinkedIn = ""
    @Published var newInterests = [String]()
    @Published var newOtherInterests = ""
    @Published var newIntro = ""
    
    // AccountView
    @Published var notifyLikes = true { didSet { updateNotifications() } }
    @Published var notifyComments = true { didSet { updateNotifications() } }
    @Published var notifyMessages = true { didSet { updateNotifications() } }
    
    // Global Functions
    func resetUserData() {
        myId = ""
        email = ""
        username = ""
        smallImage = ""
        bigImage = ""
        genderIndex = 0
        birthday = Date(timeIntervalSince1970: 946684800) // Default birthday is 1/1/2000 12:00:00 AM UTC.
        countryIndex = 187 // Default country is US.
        interests = [String]()
        otherInterests = ""
        intro = ""
        gitHub = ""
        linkedIn = ""
        
        notifyLikes = false
        notifyComments = false
        notifyMessages = false
        bytesMade = 0
        commentsMade = 0
        byteLikesGiven = 0
        commentLikesGiven = 0
        blockedBuddyIds = [String]()
        inboxData = InboxData()
        chatData = [String: ChatRoomData]()
        
        byteDraft = ""
        commentDraft = ""
        messageDrafts = [String: String]()
        
        isPremium = false
        isAdmin = false
        
        accountsListener!.remove()
        isAccountsListenerSetUp = false
    }
    
    func saveUserData() {
        // Make sure user data is loaded or user data will reset.
        if !hasUserDataLoaded {
            return
        }

        let moc = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        let coreDataUsers = try! moc.fetch(fetchRequest)
        let coreDataUser = coreDataUsers.count == 0 ? User(context: moc) : coreDataUsers[0]
        
        coreDataUser.username = username
        coreDataUser.smallImage = smallImage
        coreDataUser.bigImage = bigImage
        coreDataUser.genderIndex = Int16(genderIndex)
        coreDataUser.birthday = birthday
        coreDataUser.countryIndex = Int16(countryIndex)
        coreDataUser.interests = interests as NSObject
        coreDataUser.otherInterests = otherInterests
        coreDataUser.intro = intro
        coreDataUser.gitHub = gitHub
        coreDataUser.linkedIn = linkedIn
        
        coreDataUser.notifyLikes = notifyLikes
        coreDataUser.notifyComments = notifyComments
        coreDataUser.notifyMessages = notifyMessages
        coreDataUser.bytesMade = Int16(bytesMade)
        coreDataUser.commentsMade = Int16(commentsMade)
        coreDataUser.byteLikesGiven = Int16(byteLikesGiven)
        coreDataUser.commentLikesGiven = Int16(commentLikesGiven)
        coreDataUser.blockedBuddyIds = blockedBuddyIds as NSObject
        coreDataUser.inboxBinaryData = try? JSONEncoder().encode(inboxData)
        coreDataUser.chatBinaryData = try? JSONEncoder().encode(chatData)

        coreDataUser.byteDraft = byteDraft
        coreDataUser.commentDraft = commentDraft
        coreDataUser.messageDrafts = messageDrafts as NSObject
        
        coreDataUser.buddiesFilterGenderIndex = Int16(buddiesFilterGenderIndex)
        coreDataUser.buddiesFilterMinAge = Int16(buddiesFilterMinAge)
        coreDataUser.buddiesFilterMaxAge = Int16(buddiesFilterMaxAge)
        coreDataUser.buddiesFilterCountryIndex = Int16(buddiesFilterCountryIndex)
        coreDataUser.buddiesFilterInterests = buddiesFilterInterests as NSObject
        coreDataUser.buddiesFilterSortIndex = Int16(buddiesFilterSortIndex)
        coreDataUser.bytesFilterSortIndex = Int16(bytesFilterSortIndex)
        coreDataUser.firstLaunchedAt = firstLaunchedAt
        coreDataUser.hasAskedReview = hasAskedReview
        coreDataUser.hasAskedNotification = hasAskedNotification
        
        try? moc.save()
    }
    
    func getUtcTime() -> Date {
        return referenceTime?.now() ?? Date()
    }
    
    func getTokenIfSignedIn(completion: @escaping (String) -> Void) {
        if firebaseUser == nil {
            completion("")
            return
        }
        
        firebaseUser!.getIDToken(completion: { (token, error) in
            completion(token!)
            return
        })
    }
    
    func runPhp(script: String, postString: String, completion: @escaping (NSDictionary) -> Void) {
        if !Reachability.isConnectedToNetwork() {
            isOffline = true
            return
        }

        //print("DEBUG - script: \(script)")
        //print("DEBUG - postString: \(postString)")
        
        let scriptUrl = URL(string: "\(webServerLink)/21/\(script).php");
        var request = URLRequest(url: scriptUrl!)
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            /*let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            if script == "getImage" {
                print("DEBUG - \(script) response string = some image probably")
            } else {
                print("DEBUG - \(script) response string = \(String(describing: responseString))")
            }*/
            
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
    
    func askNotification() {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                DispatchQueue.main.async {
                    self.hasAskedNotification = true
                }
            }
    }
    
    func updateNotifications() {
        if myId == "" || !hasUserDataLoaded {
            return
        }
        
        firebaseUser!.getIDToken(completion: { (token, error) in
            let postString =
                "myId=\(self.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "notifyLikes=\(self.notifyLikes)&" +
                "notifyComments=\(self.notifyComments)&" +
                "notifyMessages=\(self.notifyMessages)"
            self.runPhp(script: "updateNotifications", postString: postString) { json in
                self.saveUserData()
            }
        })
    }

    func updateBadges() {
        firebaseUser!.getIDToken(completion: { (token, error) in
            let postString =
                "myId=\(self.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "badges=\(self.getUnreadNotificationsCounter() + self.getUnreadMessagesCounter())"
            self.runPhp(script: "updateBadges", postString: postString) { json in }
        })
    }
    
    func getUnreadNotificationsCounter() -> Int {
        var unreadCounter = 0
        for notificationData in inboxData.notifications {
            if notificationData.notifiedAt > inboxData.lastReadAt {
                unreadCounter += 1
            }
        }
        return unreadCounter
    }
    
    func getUnreadMessagesCounter() -> Int {
        var unreadCounter = 0
        for (_, chatRoomData) in chatData {
            for messageData in chatRoomData.messages {
                if !messageData.isMine &&
                    messageData.sentAt > chatRoomData.lastMyReadAt {
                    unreadCounter += 1
                }
            }
        }
        return unreadCounter
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

    func hasInvalidCharacterInUsername(username: String) -> Bool {
        for index in username.indices {
            let c = username[index]
            if !(c.isASCII && c.isLetter) &&
                !(c.isASCII && c.isNumber) &&
                c != " " {
                return true
            }
        }
        return false
    }
    
    func hasImproperSpacingInUsername(username: String) -> Bool {
        if username.first == " " ||
            username.last == " " ||
            username.contains("  ") {
            return true
        }
        return false
    }

    func isOnline(lastVisitedAt: Date) -> Bool {
        return Int(getUtcTime().timeIntervalSince(lastVisitedAt)) <= onlineTimeout
    }
    
    func toResizedString(uiImage: UIImage, maxSize: Float) -> String {
        var actualHeight = Float(uiImage.size.height)
        var actualWidth = Float(uiImage.size.width)
        let maxHeight: Float = maxSize
        let maxWidth: Float = maxSize
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.5
        
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            } else if imgRatio > maxRatio {
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            } else {
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
        return imageData!.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
    func block(buddyId: String) {
        firebaseUser!.getIDToken(completion: { (token, error) in
            let postString =
                "myId=\(self.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "buddyId=\(buddyId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
            self.runPhp(script: "blockBuddy", postString: postString) { json in
                if json["isAdmin"] != nil &&
                    json["isAdmin"] as! Bool {
                    self.activeAlert = .cannotBlockAdmin
                    return
                }
                
                self.blockedBuddyIds.append(buddyId)
                self.confirmationText = "Blocked"
            }
        })
    }
    
    func unblock(buddyId: String) {
        firebaseUser!.getIDToken(completion: { (token, error) in
            let postString =
                "myId=\(self.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "buddyId=\(buddyId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
            self.runPhp(script: "unblockBuddy", postString: postString) { json in
                self.blockedBuddyIds = self.blockedBuddyIds.filter() { $0 != buddyId }
                self.confirmationText = "Unblocked"
            }
        })
    }
}

// Global Classes
class ImageCache: NSObject, NSDiscardableContent, ObservableObject {
    @Published var image: String
    @Published var lastCachedAt: Date

    init(image: String,
         lastCachedAt: Date) {
        self.image = image
        self.lastCachedAt = lastCachedAt
        
        // View does not update unless at least one other global variables updates for an unknown reason.
        globalObject.hasImageCacheUpdated = true
    }
    
    func beginContentAccess() -> Bool {
        return true
    }
    
    func endContentAccess() {
    }
    
    func discardContentIfPossible() {
    }
    
    func isContentDiscarded() -> Bool {
        return false
    }
}

// Global Structs
enum RootViews: Identifiable {
    var id: Int { self.hashValue }
    case
        loading,
        welcome,
        join,
        tabs,
        maintenance,
        update
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

    // Convert date to string with custom format.
    func toString(toFormat: String = "yyyy-MM-dd HH:mm:ss.SSS") -> String {
        // Read about preventing common DateFormatter pitfalls using .calendar, .locale, and .timeZone:
        // https://blog.sparksuite.com/avoiding-common-lesser-known-pitfalls-with-dates-in-swift-297d0e33c74a
        
        let df = DateFormatter()
        df.dateFormat = toFormat
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "en_US_POSIX")
        
        let hasTime = toFormat.rangeOfCharacter(from: CharacterSet(charactersIn: "HhmsSa")) != nil
        if hasTime { // Prevent birthday from changing by a day depending on time zone.
            df.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        }
        
        return df.string(from: self)
    }
    
    // Convert date to string with default format.
    func toTimeDifference(hasExtension: Bool = false) -> String {
        let timeDifference = Int(globalObject.getUtcTime().timeIntervalSince(self))

        let endingText = hasExtension ? " ago" : ""
        let beginningText = hasExtension ? "on " : ""
        
        if timeDifference < 60 {
            return "\(timeDifference)s" + endingText
        } else if timeDifference < 60 * 60 {
            return "\(timeDifference / 60)m" + endingText
        } else if timeDifference < 60 * 60 * 24 {
            return "\(timeDifference / 60 / 60)h" + endingText
        } else if timeDifference < 60 * 60 * 24 * 7 {
            return "\(timeDifference / 60 / 60 / 24)d" + endingText
        } else if timeDifference < 60 * 60 * 24 * 7 * 5 {
            return "\(timeDifference / 60 / 60 / 24 / 7)w" + endingText
        }
        return beginningText + toLocal().toString(toFormat: "M/d/yy")
    }

    // Convert to yesterday.
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
}

extension String {
    // Check if URL is valid.
    var isValidUrl: Bool {
        // Only valid characters are numbers, letters, -, ., _, ~, :, /, ?, #, [, ], @, !, $, &, ', (, ), *, +, ,, ;, %, and =.
        // For example, emoji is not allowed.
        // Source: https://stackoverflow.com/a/7109208
        for index in self.indices {
            let c = self[index]
            if !(c.isASCII && c.isLetter) &&
                !(c.isASCII && c.isNumber) &&
                c != "-" && c != "." && c != "_" && c != "~" && c != ":" && c != "/" &&
                c != "?" && c != "#" && c != "[" && c != "]" && c != "@" && c != "!" &&
                c != "$" && c != "&" && c != "'" && c != "(" && c != ")" && c != "*" &&
                c != "+" && c != "," && c != ";" && c != "%" && c != "=" {
                return false
            }
        }

        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
    
    // Convert string in date format to date.
    func toDate(fromFormat: String = "yyyy-MM-dd HH:mm:ss.SSS") -> Date {
        // Read about preventing common DateFormatter pitfalls using .calendar, .locale, and .timeZone:
        // https://blog.sparksuite.com/avoiding-common-lesser-known-pitfalls-with-dates-in-swift-297d0e33c74a
        
        let df = DateFormatter()
        df.dateFormat = fromFormat
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "en_US_POSIX")
        
        let hasTime = fromFormat.rangeOfCharacter(from: CharacterSet(charactersIn: "HhmsSa")) != nil
        if hasTime { // Prevent birthday from changing by a day depending on time zone.
            df.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        }
        
        // PostgreSQL truncates timestamp's trailing zeroes for milliseconds, so add them back.
        var milliseconds = ""
        if fromFormat == "yyyy-MM-dd HH:mm:ss.SSS" {
            if self.count == 19 {
                milliseconds = ".000"
            } else if self.count == 21 {
                milliseconds = "00"
            } else if self.count == 22 {
                milliseconds = "0"
            }
        }
        
        return df.date(from: self + milliseconds)!
    }

    // Convert interests from string array.
    func toInterestsArray() -> [String] {
        if self.count == 0 {
            return []
        }
        return String(dropFirst().dropLast()).components(separatedBy: "&&")
    }

    // Convert string in Base64 to UIImage.
    func toUiImage() -> UIImage {
        let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters)
        return data != nil ? UIImage(data: data!)! : UIImage()
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

extension View {
    // Remove List's line separators
    public func removeLineSeparators() -> some View {
        AnyView(self
                    .listStyle(SidebarListStyle())
                    .padding(.horizontal, -20))
    }
    
    // Remove Form's header padding
    public func removeHeaderPadding() -> some View {
        AnyView(self
            .introspectTableView { tableView in // Change tableView only for this view.
                tableView.contentInset.top = -35
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
        self
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
    
    // Disable and gray out the view with a loading screen while loading.
    public func disabledOnLoad(isLoading: Bool, showLoading: Bool = true) -> some View {
        ZStack {
            self
                .disabled(isLoading)
                .opacity(isLoading ? 0.3 : 1)
            
            if isLoading && showLoading {
                LottieView(name: "load", size: 300, mustLoop: true)
            }
        }
    }
}

extension Array where Element == String {
    // Convert interests from array to string.
    func toInterestsString() -> String {
        if self.count == 0 {
            return ""
        }
        return "&" + self.joined(separator: "&&") + "&"
    }
}

extension Collection where Indices.Iterator.Element == Index {
    // Provide default value on index out of range error.
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
