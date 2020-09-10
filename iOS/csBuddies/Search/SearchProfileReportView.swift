//
//  SearchProfileReportView.swift
//  csBuddies
//
//  Created by Harry Cha on 8/16/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct SearchProfileReportView: View {
    @EnvironmentObject var global: Global
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentation
    
    let buddyUsername: String
    private struct AlertId: Identifiable {
        enum Id {
            case
            tooLongOtherReason,
            success
        }
        var id: Id
    }
    
    @State private var isReady = false
    @State private var isSelectedList = [Bool]()
    @State private var reasonOptions = ["Inappropriate Message", "Inappropriate Photo", "Spam", "Other"]
    @State private var reasonIndex = -1
    @State private var otherReason = ""
    @State private var isReporting = false
    @State private var alertId: AlertId?
    
    var body: some View {
        Form {
            if isReady {
                Text("Reported users won't know that you reported them.")

                Section(header: Text("Reasons")) {
                    ForEach(reasonOptions.indices) { index in
                        self.radioButton(index: index)
                    }
                    
                    MultilineTextField(minHeight: 100, "Please explain your other reason here.", text: Binding<String>(get: { self.otherReason }, set: {
                        self.otherReason = $0 } ))
                        .disabled(!isSelectedList[reasonOptions.count - 1])
                }

                Button(action: {
                    self.isReporting = true
                    
                    if self.otherReason.count > 1000 {
                        self.alertId = AlertId(id: .tooLongOtherReason)
                    } else {
                        self.reportUser()
                    }
                }) {
                    Text("Report User")
                        .accentColor(Color.red)
                        .alert(item: $alertId) { alert in
                            DispatchQueue.main.async {
                                self.isReporting = false
                            }
                            
                            switch alert.id {
                            case .tooLongOtherReason:
                                return Alert(title: Text("Too Long Other Reason"), message: Text("Your other reason must be no longer than 1,000 characters."), dismissButton: .default(Text("OK")))
                            case .success:
                                return Alert(title: Text("Report Successful"), message: Text("You have successfully reported this user."), dismissButton: .default(Text("OK"), action: {
                                    self.presentation.wrappedValue.dismiss()
                                }))
                            }
                    }
                }
                .disabled(reasonIndex == -1 ||
                    (isSelectedList[reasonOptions.count - 1] && otherReason == "") ||
                    isReporting)
            }
        }
        .navigationBarTitle("Report User", displayMode: .inline)
        .modifier(AdaptsToKeyboard())
        .onAppear {
            self.isSelectedList = [Bool](repeating: false, count: self.reasonOptions.count)
            self.isReady = true
        }
    }
    
    func radioButton(index: Int) -> some View {
        return Button(action: {
            self.isSelectedList = [Bool](repeating: false, count: self.reasonOptions.count)
            self.isSelectedList[index] = true
            self.reasonIndex = index
        }) {
            HStack {
                Text(self.reasonOptions[index])
                    .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                Spacer()
                if index < self.isSelectedList.count && self.isSelectedList[index] {
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
        }
    }
    
    func reportUser() {
        let postString =
            "username=\(self.global.username.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "password=\(self.global.password.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "buddyUsername=\(self.buddyUsername.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)&" +
            "reason=\(self.reasonIndex)&" +
            "otherReason=\(self.otherReason.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)!)"
        self.global.runPhp(script: "reportUser", postString: postString) { json in
            self.alertId = AlertId(id: .success)
        }
    }
}
