//
//  TemplateView.swift
//  csBuddies
//
//  Created by Harry Cha on 12/4/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI

struct SimpleView: View {
    let lottieView: LottieView?
    let title: String?
    let subtitle: String?
    let bottomView: AnyView?
    
    init(lottieView: LottieView? = nil, title: String? = nil, subtitle: String? = nil, bottomView: AnyView? = nil) {
        self.lottieView = lottieView
        self.title = title
        self.subtitle = subtitle
        self.bottomView = bottomView
    }

    var body: some View {
        HStack {
            Spacer()
        VStack {
            if lottieView != nil {
                lottieView
            }
            if title != nil && title != "" {
                Text(title!)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                    .frame(height: 30)
            }
            if subtitle != nil && subtitle != "" {
                Text(subtitle!)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                    .frame(height: 30)
            }
            if bottomView != nil {
                bottomView
                Spacer()
                    .frame(height: 30)
            }
        }
        .padding()
            Spacer()
        }
    }
}
