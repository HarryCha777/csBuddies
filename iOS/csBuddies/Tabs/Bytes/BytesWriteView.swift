//
//  BytesWriteView.swift
//  csBuddies
//
//  Created by Harry Cha on 10/15/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import Combine

struct BytesWriteView: View {
    @EnvironmentObject var global: Global
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentation
    
    @Binding var mustGetBytes: Bool
    
    @State private var isPosting = false

    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            tooLongByte,
            tooManyBytesToday
    }
    
    var body: some View {
        ZStack {
            List {
                VStack {
                    BetterTextEditor(placeholder: "Type your byte here...", text: $global.byteDraft)
                    Spacer()
                    HStack {
                        Spacer()
                        Text("\(global.byteDraft.count)/256")
                            .padding()
                            .foregroundColor(global.byteDraft.count > 256 ? Color.red : colorScheme == .light ? Color.black : Color.white)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .disabled(isPosting)
            .opacity(isPosting ? 0.3 : 1)

            if isPosting {
                LottieView(name: "load", size: 300, mustLoop: true)
            }
        }
        .navigationBarTitle("Post a Byte", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                global.backButton(presentation: presentation, title: "Cancel")
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    isPosting = true
                    
                    if global.byteDraft.count > 256 {
                        activeAlert = .tooLongByte
                    } else {
                        madeTooManyBytesToday() { madeTooManyBytesToday in
                            if madeTooManyBytesToday {
                                activeAlert = .tooManyBytesToday
                            } else {
                                makeByte()
                            }
                        }
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
                return Alert(title: Text("Reached Daily Byte Limit"), message: Text("You already posted 50 bytes today. Please come back tomorrow."), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func madeTooManyBytesToday(completion: @escaping (Bool) -> Void) {
        if global.isPremium {
            completion(false)
            return
        }
        
        if Calendar.current.isDate(global.getUtcTime(), inSameDayAs: global.lastPostTime) {
            if global.bytesToday < 50 {
                global.bytesToday += 1
                let postString =
                    "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                    "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                    "bytesToday=\(global.bytesToday + 1)"
                global.runPhp(script: "updateBytesToday", postString: postString) { json in }
                completion(false)
            } else {
                completion(true)
            }
        } else {
            global.lastPostTime = global.getUtcTime()
            global.bytesToday = 1
            let postString =
                "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "bytesToday=1"
            global.runPhp(script: "updateBytesToday", postString: postString) { json in }
            completion(false)
        }
    }

    func makeByte() {
        let postString =
            "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "content=\(global.byteDraft.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
        global.runPhp(script: "addByte", postString: postString) { json in
            global.byteDraft = ""
            global.bytesMade += 1
            global.bytesFilterSortIndex = 0
            mustGetBytes = true
            
            presentation.wrappedValue.dismiss()
            global.confirmationText = "Posted"
        }
    }
}
