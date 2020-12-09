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
    // LoadingView
    @Published var db = Firestore.firestore()
    @Published var webServerLink = ""
    @Published var referenceTime: ReferenceTime?
    @Published var activeRootView: RootViews = .loading
    @Published var myId = ""
    @Published var isGlobalListenerSetUp = false
    @Published var firstLaunchTime = Date()
    @Published var hasAskedReview = false
    @Published var hasUserDataLoaded = false
    @Published var onlineTimeout = 60 * 5
    
    // WelcomeView
    @Published var hasLoggedIn = false
    @Published var mustSyncWithServer = false
    @Published var isMessageUpdatesListenerSetUp = false
    @Published var messageUpdatesListener: ListenerRegistration?

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
    @Published var interests = [String]()
    @Published var otherInterests = ""

    // SetProfileView
    @Published var genderOptions = ["Male", "Female", "Other", "Private"]
    @Published var genderIndex = 0
    @Published var birthday = Date(timeIntervalSince1970: 946684800) // Default birthday is 1/1/2000 12:00:00 AM UTC.
    @Published var countryOptions = ["Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", "Argentina", "Armenia", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Cabo Verde", "Cambodia", "Cameroon", "Canada", "Central African Republic", "Chad", "Chile", "China", "Colombia", "Comoros", "Congo, Democratic Republic of the", "Congo, Republic of the", "Costa Rica", "Cote d'Ivoire", "Croatia", "Cuba", "Cyprus", "Czechia", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Eswatini", "Ethiopia", "Fiji", "Finland", "France", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Greece", "Grenada", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Honduras", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Kosovo", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Mauritania", "Mauritius", "Mexico", "Micronesia", "Moldova", "Monaco", "Mongolia", "Montenegro", "Morocco", "Mozambique", "Myanmar", "Namibia", "Nauru", "Nepal", "Netherlands", "New Zealand", "Nicaragua", "Niger", "Nigeria", "North Korea", "North Macedonia", "Norway", "Oman", "Pakistan", "Palau", "Palestine", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland", "Portugal", "Qatar", "Romania", "Russia", "Rwanda", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Korea", "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname", "Sweden", "Switzerland", "Syria", "Taiwan", "Tajikistan", "Tanzania", "Thailand", "Timor-Leste", "Togo", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "Uruguay", "Uzbekistan", "Vanuatu", "Vatican City", "Venezuela", "Vietnam", "Yemen", "Zambia", "Zimbabwe"]
    @Published var countryIndex = 187 // Default country is US.
    @Published var gitHub = ""
    @Published var linkedIn = ""
    
    // TypeIntroView
    @Published var username = ""
    @Published var smallImage = ""
    @Published var bigImage = ""
    @Published var smallImageCaches = NSCache<NSString, ImageCache>()
    @Published var bigImageCaches = NSCache<NSString, ImageCache>()
    @Published var hasImageCachesUpdated = false
    @Published var intro = ""
    @Published var password = ""
    @Published var isPremium = false
    @Published var tabIndex = 0
    
    // TabsView
    @Published var isKeyboardHidden = true
    @Published var hasClickedNotification = false
    @Published var notificationBuddyId = ""
    @Published var notificationBuddyUsername = ""
    @Published var notificationType = ""
    
    // ConfirmationView
    @Published var confirmationText = ""

    // BuddiesView
    @Published var announcementText = ""
    @Published var announcementLink = ""
    
    // BuddiesProfileView
    @Published var savedUsers = [UserRowData]()
    @Published var blocks = [UserRowData]()

    // BuddiesFilterView
    @Published var buddiesFilterGenderIndex = 0
    @Published var buddiesFilterMinAge = 13
    @Published var buddiesFilterMaxAge = 130
    @Published var buddiesFilterCountryIndex = 0
    @Published var buddiesFilterInterests = [String]()
    @Published var buddiesFilterSortIndex = 0

    @Published var newBuddiesFilterGenderIndex = 0
    @Published var newBuddiesFilterMinAge = 13
    @Published var newBuddiesFilterMaxAge = 130
    @Published var newBuddiesFilterCountryIndex = 0
    @Published var newBuddiesFilterInterests = [String]()
    @Published var newBuddiesFilterSortIndex = 0

    // BytesView
    @Published var lastPostTime = Date()
    @Published var bytesToday = 0
    @Published var firebaseServerKey = "INSERT FIREBASE SERVER KEY HERE"
    @Published var savedBytes = [BytesPostData]()
    
    // BytesFilterView
    @Published var bytesFilterSortIndex = 1
    @Published var bytesFilterTimeIndex = 0

    @Published var newBytesFilterSortIndex = 1
    @Published var newBytesFilterTimeIndex = 0
    
    // BytesWriteView
    @Published var byteDraft = ""

    // ChatView
    @Published var hasAskedNotification = false
    @Published var lastReceivedChatTime = Date()
    
    @Published var chatBuddyId = ""
    @Published var chatBuddyUsername = ""
    @Published var lastFirstChatTime = Date()
    @Published var firstChatsToday = 0
    @Published var mustUpdateBadges = false
    
    @Published var chatData = [String: ChatRoomData]()

    // ChatRoomInputView
    @Published var messageDrafts = [String: String]()

    // ProfileView
    @Published var bytesMade = 0
    @Published var likesReceived = 0
    @Published var likesGiven = 0

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
    
    // ProfileSettingsAccountView
    @Published var hasByteNotification = true
    @Published var hasChatNotification = true

    // Global Functions
    func resetUserData() {
        myId = ""
        email = ""
        username = ""
        password = ""
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
        byteDraft = ""
        isPremium = false
        
        savedUsers = [UserRowData]()
        savedBytes = [BytesPostData]()
        blocks = [UserRowData]()
        chatData = [String: ChatRoomData]()
        messageDrafts = [String: String]()
        
        messageUpdatesListener!.remove()
        isMessageUpdatesListenerSetUp = false
    }
    
    func saveUserData() {
        // Archive data.
        let savedUsersArchiver = NSKeyedArchiver(requiringSecureCoding: true)
        try! savedUsersArchiver.encodeEncodable(savedUsers, forKey: "savedUsers")
        savedUsersArchiver.finishEncoding()
        let savedUsersBinaryData = savedUsersArchiver.encodedData
        
        let savedBytesArchiver = NSKeyedArchiver(requiringSecureCoding: true)
        try! savedBytesArchiver.encodeEncodable(savedBytes, forKey: "savedBytes")
        savedBytesArchiver.finishEncoding()
        let savedBytesBinaryData = savedBytesArchiver.encodedData
        
        let blocksArchiver = NSKeyedArchiver(requiringSecureCoding: true)
        try! blocksArchiver.encodeEncodable(blocks, forKey: "blocks")
        blocksArchiver.finishEncoding()
        let blocksBinaryData = blocksArchiver.encodedData
        
        let chatDataArchiver = NSKeyedArchiver(requiringSecureCoding: true)
        try! chatDataArchiver.encodeEncodable(chatData, forKey: "chatData")
        chatDataArchiver.finishEncoding()
        let chatBinaryData = chatDataArchiver.encodedData

        // Find user.
        let moc = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.sortDescriptors = []
        let users = try! moc.fetch(fetchRequest)

        let index = users.firstIndex(where: { $0.myId == myId })
        var user = User()
        if index == nil {
            user = User(context: moc)
            user.myId = myId
        } else {
            user = users[index!]
        }

        // Save client data.
        user.buddiesFilterGenderIndex = Int16(buddiesFilterGenderIndex)
        user.buddiesFilterMinAge = Int16(buddiesFilterMinAge)
        user.buddiesFilterMaxAge = Int16(buddiesFilterMaxAge)
        user.buddiesFilterCountryIndex = Int16(buddiesFilterCountryIndex)
        user.buddiesFilterInterests = buddiesFilterInterests as NSObject
        user.buddiesFilterSortIndex = Int16(buddiesFilterSortIndex)
        user.bytesFilterSortIndex = Int16(bytesFilterSortIndex)
        user.bytesFilterTimeIndex = Int16(bytesFilterTimeIndex)
        user.byteDraft = byteDraft
        user.messageDrafts = messageDrafts as NSObject
        user.firstLaunchTime = firstLaunchTime
        user.hasAskedReview = hasAskedReview
        user.hasAskedNotification = hasAskedNotification
        user.hasByteNotification = hasByteNotification
        user.hasChatNotification = hasChatNotification
        user.savedUsersBinaryData = savedUsersBinaryData
        user.savedBytesBinaryData = savedBytesBinaryData
        user.chatBinaryData = chatBinaryData

        // Save server data.
        user.email = email
        user.username = username
        user.smallImage = smallImage
        user.bigImage = bigImage
        user.genderIndex = Int16(genderIndex)
        user.birthday = birthday
        user.countryIndex = Int16(countryIndex)
        user.interests = interests as NSObject
        user.otherInterests = otherInterests
        user.intro = intro
        user.gitHub = gitHub
        user.linkedIn = linkedIn
        user.bytesMade = Int16(bytesMade)
        user.likesGiven = Int16(likesGiven)
        user.lastPostTime = lastPostTime
        user.bytesToday = Int16(bytesToday)
        user.lastFirstChatTime = lastFirstChatTime
        user.firstChatsToday = Int16(firstChatsToday)
        user.lastReceivedChatTime = lastReceivedChatTime
        user.blocksBinaryData = blocksBinaryData
        try? moc.save()
    }
    
    func getUtcTime() -> Date {
        return referenceTime?.now() ?? Date()
    }
    
    func runPhp(script: String, postString: String, completion: @escaping (NSDictionary) -> Void) {
        print("script: \(script)")
        print("postString: \(postString)")
        
        let scriptUrl = URL(string: "\(webServerLink)/19/\(script).php");
        var request = URLRequest(url: scriptUrl!)
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            if script == "getImage" {
                print("response string = some image probably")
            } else {
                print("response string = \(String(describing: responseString))")
            }
            
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
                if granted == true && error == nil { // Check if permission is granted.
                    // FCM takes time to be received and FCM may be received twice on app reinstall, so set FCM here instead of when launching the app.
                    let postString =
                        "myId=\(self.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                        "password=\(self.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                        "fcm=\(Messaging.messaging().fcmToken!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
                    self.runPhp(script: "updateFcm", postString: postString) { json in }
                }
            }
    }
    
    func sendNotification(body: String, fcm: String, badges: Int, type: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let params: [String: Any] = ["to": fcm,
                                     "priority": "high",
                                     "notification": ["title": username, "body": body, "badge": badges + 1, "sound": "default"],
                                     "data": ["myId": myId, "type": type]
        ]

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(firebaseServerKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in }
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

    func isOnline(lastVisitTimeAny: Any?) -> Bool {
        let lastVisitTime = (lastVisitTimeAny as! String).toDate()
        return Int(getUtcTime().timeIntervalSince(lastVisitTime)) <= onlineTimeout
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
    
    func getUnreadCounter() -> Int {
        var unreadCounter = 0
        for (_, chatRoomData) in chatData {
            for chatRoomMessageData in chatRoomData.messages {
                if !chatRoomMessageData.isMine &&
                    chatRoomMessageData.sendTime > chatRoomData.lastMyReadTime {
                    unreadCounter += 1
                }
            }
        }
        return unreadCounter
    }

    func saveUser(buddyId: String, buddyUsername: String) {
        let userRowData = UserRowData(userId: buddyId, username: buddyUsername, isOnline: false, appendTime: getUtcTime())
        savedUsers.append(userRowData)
        
        confirmationText = "Saved"
    }
    
    func forgetUser(buddyId: String) {
        savedUsers = savedUsers.filter() { $0.userId != buddyId }
        
        confirmationText = "Forgotten"
    }
    
    func saveByte(bytesPostData: BytesPostData) {
        savedBytes.append(bytesPostData)
        
        confirmationText = "Saved"
    }
    
    func forgetByte(byteId: String) {
        savedBytes = savedBytes.filter() { $0.byteId != byteId }
        
        confirmationText = "Forgotten"
    }
    
    func block(buddyId: String, buddyUsername: String) {
        let postString =
            "myId=\(myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "password=\(password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "buddyId=\(buddyId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
        runPhp(script: "blockBuddy", postString: postString) { json in
            let userRowData = UserRowData(userId: buddyId, username: buddyUsername, isOnline: false, appendTime: self.getUtcTime())
            self.blocks.append(userRowData)

            self.confirmationText = "Blocked"
        }
    }
    
    func unblock(buddyId: String) {
        let postString =
            "myId=\(myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "password=\(password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "buddyId=\(buddyId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
        runPhp(script: "unblockBuddy", postString: postString) { json in
            self.blocks = self.blocks.filter() { $0.userId != buddyId }
            
            self.confirmationText = "Unblocked"
        }
    }
    
    func backButton(presentation: Binding<PresentationMode>, title: String) -> some View {
        Button(action: {
            presentation.wrappedValue.dismiss()
        }) {
            Text(title)
        }
    }
    
    func blueButton(title: String, reversed: Bool = false) -> some View {
        Text(title)
            .bold()
            .frame(width: 250)
            .padding()
            .foregroundColor(!reversed ? Color.white : Color.blue)
            .background(!reversed ? Color.blue : Color.clear)
            .cornerRadius(20)
    }
}

// Global Classes
class ImageCache: NSObject, NSDiscardableContent, ObservableObject {
    @Published var image: String
    @Published var lastCacheTime: Date

    init(image: String,
         lastCacheTime: Date) {
        self.image = image
        self.lastCacheTime = lastCacheTime
        
        // View does not update unless at least one other global variables updates for an unknown reason.
        globalObject.hasImageCachesUpdated = true
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
        join,
        welcome,
        tabs,
        maintenance,
        update,
        banned
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
        let df = DateFormatter()
        df.dateFormat = toFormat
        let hasTime = toFormat.rangeOfCharacter(from: CharacterSet(charactersIn: "HhmsSa")) != nil
        if hasTime {
            df.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        }
        return df.string(from: self)
    }
    
    // Convert date to string with default format.
    func toTimeDifference(hasExtension: Bool = false) -> String {
        let timeDifference = Int(globalObject.getUtcTime().timeIntervalSince(self))

        let endingText = hasExtension ? " ago" : ""
        let beginningText = hasExtension ? "in " : ""
        
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
        let df = DateFormatter()
        df.dateFormat = fromFormat
        let hasTime = fromFormat.rangeOfCharacter(from: CharacterSet(charactersIn: "HhmsSa")) != nil
        if hasTime {
            df.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        }
        return df.date(from: self)!
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
