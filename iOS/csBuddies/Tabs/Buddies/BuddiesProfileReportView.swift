//
//  BuddiesProfileReportView.swift
//  csBuddies
//
//  Created by Harry Cha on 8/16/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct BuddiesProfileReportView: View {
    @EnvironmentObject var global: Global
    @Environment(\.presentationMode) var presentation
    
    let buddyId: String

    @State private var isSelectedList = [Bool](repeating: false, count: 6) // 6 is reasonOptions.count.
    @State private var reasonOptions = ["Inappropriate Photo", "Inappropriate Intro", "Inappropriate Byte", "Inappropriate Message", "Spam", "Other"]
    @State private var reasonIndex = -1
    @State private var otherReason = ""
    @State private var comments = ""
    @State private var isReporting = false
    
    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            tooLongOtherReason,
            tooLongComments,
            extantReport
    }
    
    var body: some View {
        ZStack {
            List {
                Text("They will never know that you reported them.")
            
                Section(header: Text("Reasons")) {
                    ForEach(reasonOptions.indices) { index in
                        radioButton(index: index)
                    }
            
                    TextField("Your other reason here.", text: $otherReason)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(!isSelectedList[reasonOptions.count - 1])
                }
            
                Section(header: Text("Comments")) {
                    BetterTextEditor(placeholder: "Please let us know of any additional information to help process this faster.", text: $comments)
                }
            
                Button(action: {
                    isReporting = true
            
                    if otherReason.count > 100 {
                        activeAlert = .tooLongOtherReason
                    } else if comments.count > 1000 {
                        activeAlert = .tooLongComments
                    } else {
                        reportBuddy(mustReplacePrevious: false)
                    }
                }) {
                    Text("Report User")
                        .accentColor(Color.red)
                }
                .disabled(reasonIndex == -1 ||
                            (isSelectedList[reasonOptions.count - 1] && otherReason == ""))
            }
            .listStyle(InsetGroupedListStyle())
            .disabled(isReporting)
            .opacity(isReporting ? 0.3 : 1)
            
            if isReporting {
                LottieView(name: "load", size: 300, mustLoop: true)
            }
        }
        .navigationBarTitle("Report Buddy", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
               global.backButton(presentation: presentation, title: "Cancel")
            }
        }
        .alert(item: $activeAlert) { alert in
            DispatchQueue.main.async {
                isReporting = false
            }

            switch alert {
            case .tooLongOtherReason:
                return Alert(title: Text("Too Long Other Reason"), message: Text("Your other reason must be no longer than 100 characters."), dismissButton: .default(Text("OK")))
            case .tooLongComments:
                return Alert(title: Text("Too Long Comments"), message: Text("Your comments must be no longer than 1,000 characters."), dismissButton: .default(Text("OK")))
            case .extantReport:
                return Alert(title: Text("Already Reported"), message: Text("You already reported this user. Would you like to replace the previous report with this one?"), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("OK"), action: {
                    isReporting = true
                    reportBuddy(mustReplacePrevious: true)
                }))
            }
        }
    }
    
    func radioButton(index: Int) -> some View {
        Button(action: {
            isSelectedList = [Bool](repeating: false, count: reasonOptions.count)
            isSelectedList[index] = true
            reasonIndex = index
        }) {
            HStack {
                Text(reasonOptions[index])
                Spacer()
                if index < isSelectedList.count && isSelectedList[index] {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 20, height: 20)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                    }
                } else {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                }
            }
            .background(Color.black.opacity(0.001)) // Expand button's tappable area to empty spaces.
        }
        .buttonStyle(PlainButtonStyle())
    }

    func reportBuddy(mustReplacePrevious: Bool) {
        let postString =
            "myId=\(global.myId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "password=\(global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "buddyId=\(buddyId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "reason=\(reasonIndex)&" +
            "otherReason=\(otherReason.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "comments=\(comments.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "mustReplacePrevious=\(mustReplacePrevious)"
        global.runPhp(script: "reportBuddy", postString: postString) { json in
            if json["isExtantReport"] != nil {
                activeAlert = .extantReport
                return
            }
            
            presentation.wrappedValue.dismiss()
            global.confirmationText = "Reported"
        }
    }
}
