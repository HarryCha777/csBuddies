//
//  BuddiesFilterAgeView.swift
//  csBuddies
//
//  Created by Harry Cha on 11/15/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct BuddiesFilterAgeView: View {
    @EnvironmentObject var global: Global

    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    VStack {
                        Spacer()
                        Text("Min Age")
                        Picker(selection: $global.newBuddiesFilterMinAge, label: Text("")) {
                            ForEach(13 ..< 130 + 1, id: \.self) { age in
                                Text("\(age)")
                            }
                        }
                        .onChange(of: global.newBuddiesFilterMinAge) { changedNewBuddiesFilterMinAge in
                            if changedNewBuddiesFilterMinAge > global.newBuddiesFilterMaxAge {
                                global.newBuddiesFilterMaxAge = changedNewBuddiesFilterMinAge
                            }
                        }
                        .frame(maxWidth: geometry.size.width / 2)
                        .clipped()
                        Spacer()
                    }

                    VStack {
                        Spacer()
                        Text("Max Age")
                        Picker(selection: $global.newBuddiesFilterMaxAge, label: Text("")) {
                            ForEach(13 ..< 130 + 1, id: \.self) { age in
                                Text("\(age)")
                            }
                        }
                        .onChange(of: global.newBuddiesFilterMaxAge) { changedNewBuddiesFilterMaxAge in
                            if global.newBuddiesFilterMinAge > changedNewBuddiesFilterMaxAge {
                                global.newBuddiesFilterMinAge = changedNewBuddiesFilterMaxAge
                            }
                        }
                        .frame(maxWidth: geometry.size.width / 2)
                        .clipped()
                        Spacer()
                    }
                }
            }
        }
        .navigationBarTitle("Filter Age", displayMode: .inline)
    }
}
