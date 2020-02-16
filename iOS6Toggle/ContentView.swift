//
//  ContentView.swift
//  iOS6Toggle
//
//  Created by Elvin Hu on 2/4/20.
//  Copyright © 2020 Elvin Hu. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    /// Wheter the toggle is on or not.
    @State var isOn: Bool = false
    /// The toggle should hide the blue background when it isn't on, but show the blue background otherwise.
    /// When the knob is being dragged from off to on, the blue background should show up right away and move with it.
    @State var shouldShowBlueBackground: Bool = false
    /// Displacement of the knob.
    @State var viewDisplacement = CGSize.zero
    
    var body: some View {
        ZStack {
             // Toggle white background - stays still
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 247/255, green: 247/255, blue: 247/255))
                .frame(width: 92, height: 32)
            
            // OFF Text
            Text("OFF")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(red: 111/255, green: 111/255, blue: 111/255))
                .shadow(color: Color(red: 1, green: 1, blue: 1, opacity: 1), radius: 0, x: 0, y: -1)
                // The "OFF" text appears at the center of the toggle on default without any offset (as SwiftUI prefer to center contents),
                // to make sure it appears on the center of the toggle background area (the white area),
                // it has has a 10 pixels of horizontal offset while the toggle is off,
                // and it will move to the right, out of the visible area when the toggle is on.
                .offset(x: isOn ? 70 : 10)
                //viewDisplacement controls the horizontal offset of the UI elements as the user performs the drag gesture
                .offset(x: viewDisplacement.width)
            
            // Toggle blue background - moves with the gesture
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 4/255, green: 125/255, blue: 229/255))
                .frame(width: 92, height: 32)
                .offset(x: isOn ? 0 : -60)
                .offset(x: viewDisplacement.width)
                .opacity(shouldShowBlueBackground ? 1 : 0)
            
            // ON Text
            Text("ON")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.white)
                .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.3), radius: 0, x: 0, y: -1)
                // similar behavior as the "OFF" text
                .offset(x: isOn ? -10 : -70)
                .offset(x: viewDisplacement.width)
            
            // Toggle highlight - stays still
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 0.10),
                                     Color(.sRGB, red: 1, green: 1, blue: 1, opacity: 0.70)]),
                            startPoint: .top,
                            endPoint: .bottom
                    )
                )
                .frame(width: 80, height: 24)
                .offset(y: 12)
            
            // Toggle shadow - stays still
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black, lineWidth: 0.5)
                .blur(radius: 0.5)
                .frame(width: 92, height: 32)
                .mask(
                    RoundedRectangle(cornerRadius: 16)
                        .frame(width: 92, height: 32)
                )
                // Top inner shadow
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray, lineWidth: 2)
                        .blur(radius: 2)
                        .frame(width: 92, height: 32)
                        .offset(y: 1.5)
                        // Create a natural fall-off for the top shadow
                        .mask(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(
                                            colors: [Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 1),
                                                     Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0)]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                    )
                                )
                                .frame(width: 92, height: 32)

                        )
                        // Set blend mode to multiply so the inner shadow reflects what color is underneath it
                        .blendMode(.multiply)
                )
                .opacity(0.9)
            
            // Toggle knob - moves with the gesture
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)){
                    self.isOn.toggle()
                }
                if self.isOn {
                    self.shouldShowBlueBackground = true
                } else {
                    withAnimation(Animation.easeInOut(duration: 0.25).delay(0.125)) {
                        self.shouldShowBlueBackground = false
                    }
                }
            }){
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(
                                colors: [Color(red: 214/255, green: 213/255, blue: 211/255),
                                         Color(red: 252/255, green: 252/255, blue: 251/255)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        // Two layers of shadow
                        .shadow(radius: 2)
                        .shadow(radius: 0.5)
                        .overlay(
                            // Blur then mask a circular stroke view for the inner shadow/stroke effect
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .blur(radius: 0.5)
                                // Hide the
                                .mask(Circle())
                        )
                        
                .offset(x: viewDisplacement.width)
                .offset(x: isOn ? 30: -30)
                .frame(width: 30, height: 30)
            }
        }
            .mask(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 247/255, green: 247/255, blue: 247/255))
                    .frame(width: 92, height: 32)
            )
            // Use .highPriorityGesture to make sure the drag gesture is captured before the default tap gesture of the button
            .highPriorityGesture(
                DragGesture().onChanged { value in
                    self.shouldShowBlueBackground = true
                    // If the toggle is off (gray) before the user perform the gesture
                    if !self.isOn {
                        // If the toggle is being dragged to the left (negative value in horizontal offset), nothing should move
                        if value.translation.width < 0 {
                            self.viewDisplacement = .zero
                        }
                        // Once the knob is dragged from the left end to the right end, the UI elements should stop moving
                        else if value.translation.width > 60 {
                            self.viewDisplacement.width = 60
                        }
                        // If the knob is between the left end and the right end, assign the current translation of the gesture to viewDisplacement,
                        // so the UI elements would move along with the gesture.
                        else {
                            self.viewDisplacement = value.translation
                        }
                    }
                    // If the toggle is on (blue) before the user perform the gesture
                    else {
                        // If the toggle is being dragged to the right (positive value in horizontal offset), nothing should move
                        if value.translation.width > 0 {
                            self.viewDisplacement = .zero
                        }
                        // Once the knob is dragged from the right end to the left end, the UI elements should stop moving
                        else if value.translation.width < -60 {
                            self.viewDisplacement.width = -60
                        }
                        // If the knob is between the left end and the right end, assign the current translation of the gesture to viewDisplacement
                        // so the UI elements would move along with the gesture.
                        else {
                            self.viewDisplacement = value.translation
                        }
                    }
                }
                .onEnded { value in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        // If the knob is dragged for a distance longer than half of the width of the toggle, change the state of the toggle
                        if !self.isOn && value.translation.width > 30 || self.isOn && value.translation.width < -30 {
                            self.isOn.toggle()
                        }
                        // Reset the position of the toggle to its new default position after the change of state
                        self.viewDisplacement = .zero
                    }
                    // Hide the blue background if the toggle is off at the end of the gesture, so that there wouldn't be a blue stroke/halo around the knob visible
                    if !self.isOn {
                        withAnimation(Animation.easeInOut(duration: 0.25).delay(0.125)) {
                            self.shouldShowBlueBackground = false
                        }
                    }
                }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
