//
//  ByteWriteView.swift
//  csBuddies
//
//  Created by Harry Cha on 10/15/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Combine

struct ByteWriteView: View {
    @EnvironmentObject var global: Global
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentation
    
    @Binding var newByteId: String
    
    @State private var isPosting = false
    @State private var dailyLimit = 0
    
    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            tooLongByte,
            tooManyBytesToday,
            prepermission
    }
    
    var body: some View {
        List {
            VStack {
                BetterTextEditor(placeholder: "Type your byte here...", text: $global.byteDraft)
                Spacer()
                HStack {
                    Spacer()
                    Text("\(global.byteDraft.count)/256")
                        .padding()
                        .foregroundColor(global.byteDraft.count > 256 ? .red : colorScheme == .light ? .black : .white)
                }
            }

            if !global.hasAskedNotification {
                Button(action: {
                    activeAlert = .prepermission
                }) {
                    Text("Turn on Notification")
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .disabledOnLoad(isLoading: isPosting)
        .navigationBarTitle("Post a Byte", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                BackButton(title: "Cancel", presentation: presentation)
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    isPosting = true
                    
                    if global.byteDraft.count > 256 {
                        activeAlert = .tooLongByte
                    } else {
                        addByte()
                    }
                }) {
                    Text("Post")
                }
                .disabled(global.byteDraft.count == 0 || global.byteDraft.count > 256 || isPosting)
            }
        }
        .alert(item: $activeAlert) { alert in
            DispatchQueue.main.async {
                isPosting = false
            }
            
            switch alert {
            case .tooLongByte:
                return Alert(title: Text("Too Long Byte"), message: Text("You currently typed \(global.byteDraft.count) characters. Please type no more than 256 characters."), dismissButton: .default(Text("OK")))
            case .tooManyBytesToday:
                return Alert(title: Text("Reached Daily Byte Limit"), message: Text("You already posted \(dailyLimit) bytes today. Please come back tomorrow."), dismissButton: .default(Text("OK")))
            case .prepermission:
                return Alert(title: Text("Get notified when someone comments!"),
                      message: Text("Would you like to receive a notification when you get comments?"),
                      primaryButton: .destructive(Text("Not Now")),
                      secondaryButton: .default(Text("Notify Me"), action: {
                        global.askNotification()
                      }))
            }
        }
    }
    
    func addByte() {
        global.firebaseUser!.getIDToken(completion: { (token, error) in
            let postString =
                "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "content=\(global.byteDraft.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
            global.runPhp(script: "addByte", postString: postString) { json in
                if json["isTooMany"] != nil &&
                    json["isTooMany"] as! Bool {
                    dailyLimit = json["dailyLimit"] as! Int
                    activeAlert = .tooManyBytesToday
                    return
                }
                
                newByteId = json["byteId"] as! String
                let byteData = ByteData(
                    byteId: newByteId,
                    userId: global.myId,
                    username: global.username,
                    lastVisitedAt: global.getUtcTime(),
                    content: global.byteDraft,
                    likes: 0,
                    comments: 0,
                    isLiked: false,
                    postedAt: global.getUtcTime())
                byteData.updateClientData()
                
                global.byteDraft = ""
                global.bytesMade += 1
                
                presentation.wrappedValue.dismiss()
                global.confirmationText = "Posted"
            }
        })
    }
}
