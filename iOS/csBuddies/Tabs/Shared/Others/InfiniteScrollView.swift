//
//  InfiniteScrollView.swift
//  csBuddies
//
//  Created by Harry Cha on 2/5/21.
//  Copyright © 2021 Harry Cha. All rights reserved.
//

import SwiftUI

struct InfiniteScrollView: View {
    let emptyText: String
    let isLoading: Bool
    let isEmpty: Bool
    let canLoadMore: Bool
    let loadMore: () -> Void
    
    init(emptyText: String = "", isLoading: Bool, isEmpty: Bool, canLoadMore: Bool, loadMore: @escaping () -> Void) {
        self.emptyText = emptyText
        self.isLoading = isLoading
        self.isEmpty = isEmpty
        self.canLoadMore = canLoadMore
        self.loadMore = loadMore
    }
    
    var body: some View {
        HStack {
            Spacer()
            if isLoading {
                LottieView(name: "load", size: 300, padding: -50, mustLoop: true)
            } else if isEmpty {
                if emptyText == "" {
                    LottieView(name: "noData", size: 300, padding: -50)
                } else {
                    Text(emptyText)
                }
            } else {
                Text("End")
                    .onAppear {
                        if canLoadMore {
                            loadMore()
                        }
                    }
            }
            Spacer()
        }
    }
}
