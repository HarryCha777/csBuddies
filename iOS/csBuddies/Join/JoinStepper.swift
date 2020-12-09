//
//  JoinStepperView.swift
//  csBuddies
//
//  Created by Harry Cha on 11/12/20.
//  Copyright © 2020 Harry Cha. All rights reserved.
//

import SwiftUI
import StepperView

struct JoinStepperView: View {
    let step: Int
    let steps = [ Text("Interests"),
                  Text("Profile"),
                  Text("Intro")]
    var indicationTypes = [StepperIndicationType<AnyView>]()

    init(step: Int) {
        self.step = step
        indicationTypes = [StepperIndicationType
                                .custom(AnyView(InterestsCircleView(step: step))),
                               .custom(AnyView(ProfileCircleView(step: step))),
                               .custom(AnyView(IntroCircleView(step: step)))]
    }
    
    var body: some View {
        HStack {
            Spacer()
            StepperView()
                .addSteps(steps)
                .indicators(indicationTypes)
                .stepIndicatorMode(StepperMode.horizontal)
                .spacing(UIScreen.main.bounds.size.width / CGFloat(steps.count + 1))
                .lineOptions(StepperLineOptions.custom(3, Colors.blue(.teal).rawValue))
                .padding(.top, 30) // Prevent the top half from being cut off inside a Form.
            Spacer()
        }
    }
}

struct InterestsCircleView: View {
    let step: Int
    
    var body: some View {
        Circle()
            .frame(width: 30, height: 30)
            .foregroundColor(step == 1 ? Color.blue : Color.green)
            .overlay(
                VStack {
                    if step == 1 {
                        Text("1")
                            .foregroundColor(Color.white)
                    } else {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color.white)
                    }
                }
            )
    }
}

struct ProfileCircleView: View {
    let step: Int
    let lightGrayColor = Color(red: 211 / 255, green: 211 / 255, blue: 211 / 255)

    var body: some View {
        Circle()
            .frame(width: 30, height: 30)
            .foregroundColor(step == 1 ? lightGrayColor : step == 2 ? Color.blue : Color.green)
            .overlay(
                VStack {
                    if step == 1 {
                        Text("2")
                            .foregroundColor(Color.black)
                    } else if step == 1 || step == 2 {
                        Text("2")
                            .foregroundColor(Color.white)
                    } else {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color.white)
                    }
                }
            )
    }
}

struct IntroCircleView: View {
    let step: Int
    let lightGrayColor = Color(red: 211 / 255, green: 211 / 255, blue: 211 / 255)
    
    var body: some View {
        Circle()
            .frame(width: 30, height: 30)
            .foregroundColor(step < 3 ? lightGrayColor : Color.blue)
            .overlay(
                Text("3")
                    .foregroundColor(step < 3 ? Color.black : Color.white)
            )
    }
}
