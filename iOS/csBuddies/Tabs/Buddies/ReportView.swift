//
//  ReportView.swift
//  csBuddies
//
//  Created by Harry Cha on 8/16/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct ReportView: View {
    @EnvironmentObject var global: Global
    @Environment(\.presentationMode) var presentation
    
    let buddyId: String
    
    @State private var isSelectedList = [Bool](repeating: false, count: 7) // 7 is reasonOptions.count.
    @State private var reasonOptions = ["Inappropriate Photo", "Inappropriate Intro", "Inappropriate Byte", "Inappropriate Comment", "Inappropriate Message", "Inappropriate Activity", "Other"]
    @State private var reason = -1
    @State private var comments = ""
    @State private var isReporting = false
    
    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            tooLongComments,
            cannotReportAdmin,
            extantReport
    }
    
    var body: some View {
        List {
            Text("They will never know that you reported them.")
            
            Section(header: Text("Reasons")) {
                ForEach(reasonOptions.indices) { index in
                    RadioButton(index: index, reason: $reason, reasonOptions: reasonOptions, isSelectedList: $isSelectedList)
                }
            }
            
            Section(header: Text("Comments")) {
                BetterTextEditor(placeholder: "Please let us know of any additional information to help process this faster.", text: $comments)
            }
            
            Button(action: {
                isReporting = true
                
                if comments.count > 1000 {
                    activeAlert = .tooLongComments
                } else {
                    reportBuddy(mustReplace: false)
                }
            }) {
                Text("Report User")
                    .accentColor(.red)
            }
            .disabled(reason == -1)
        }
        .listStyle(InsetGroupedListStyle())
        .disabledOnLoad(isLoading: isReporting)
        .navigationBarTitle("Report Buddy", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                BackButton(title: "Cancel", presentation: presentation)
            }
        }
        .alert(item: $activeAlert) { alert in
            DispatchQueue.main.async {
                isReporting = false
            }
            
            switch alert {
            case .tooLongComments:
                return Alert(title: Text("Too Long Comments"), message: Text("Your comments must be no longer than 1,000 characters."), dismissButton: .default(Text("OK")))
            case .cannotReportAdmin:
                return Alert(title: Text("The User is an Admin"), message: Text("You cannot report an admin. For any questions or feedback, please contact us instead."), dismissButton: .default(Text("OK")))
            case .extantReport:
                return Alert(title: Text("Already Reported"), message: Text("You already reported this user. Would you like to replace the previous report with this one?"), primaryButton: .destructive(Text("Cancel")), secondaryButton: .default(Text("OK"), action: {
                    isReporting = true
                    reportBuddy(mustReplace: true)
                }))
            }
        }
    }
    
    func reportBuddy(mustReplace: Bool) {
        global.firebaseUser!.getIDToken(completion: { (token, error) in
            let postString =
                "token=\(token!.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "buddyId=\(buddyId.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "reason=\(reason)&" +
                "comments=\(comments.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
                "mustReplace=\(mustReplace)"
            global.runHttp(script: "reportBuddy", postString: postString) { json in
                if json["isAdmin"] != nil &&
                    json["isAdmin"] as! Bool {
                    activeAlert = .cannotReportAdmin
                    return
                }
                
                if json["isExtantReport"] != nil &&
                    json["isExtantReport"] as! Bool {
                    activeAlert = .extantReport
                    return
                }
                
                presentation.wrappedValue.dismiss()
                global.confirmationText = "Reported"
            }
        })
    }
}
