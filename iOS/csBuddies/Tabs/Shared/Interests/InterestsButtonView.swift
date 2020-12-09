//
//  InterestsButtonEnabledView.swift
//  csBuddies
//
//  Created by Harry Cha on 11/12/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct InterestsButtonEnabledView: View {
    @EnvironmentObject var global: Global
    @Environment(\.colorScheme) var colorScheme
    
    let interest: String
    @Binding var interests: [String]
    let lightBlueColor = Color(red: 30 / 255, green: 144 / 255, blue: 255 / 255)

    @State var activeAlert: Alerts?
    enum Alerts: Identifiable {
        var id: Int { self.hashValue }
        case
            tooManyInterests
    }

    var body: some View {
        Button(action: {
            if !interests.contains(interest) {
                if interests.count >= 10 {
                    activeAlert = .tooManyInterests
                    return
                }
                interests.append(interest)
                interests = interests.sorted { $0.localizedCompare($1) == .orderedAscending } // Sort case insensitive for words like "iOS".
            } else {
                interests = interests.filter { $0 != interest }
            }
        }) {
            Text(verbatim: interest)
                .padding(6)
                .foregroundColor(interests.contains(interest) ? Color.white : lightBlueColor)
                .overlay(RoundedRectangle(cornerRadius: 15)
                            .stroke(lightBlueColor, lineWidth: 1))
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(interests.contains(interest) ? lightBlueColor : colorScheme == .light ? Color.white : Color.black)
                )
        }
        .buttonStyle(BorderlessButtonStyle())
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .tooManyInterests:
                return Alert(title: Text("Too Many Interests"), message: Text("Please choose only up to your top 10 interests."), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct InterestsButtonDisabledView: View {
    @EnvironmentObject var global: Global
    @Environment(\.colorScheme) var colorScheme
    
    let interest: String
    let interests: [String]
    let lightBlueColor = Color(red: 30 / 255, green: 144 / 255, blue: 255 / 255)

    var body: some View {
        Text(verbatim: interest)
            .padding(6)
            .foregroundColor(interests.contains(interest) ? Color.white : lightBlueColor)
            .overlay(RoundedRectangle(cornerRadius: 15)
                        .stroke(lightBlueColor, lineWidth: 1))
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(interests.contains(interest) ? lightBlueColor : colorScheme == .light ? Color.white : Color.black)
            )
    }
}
