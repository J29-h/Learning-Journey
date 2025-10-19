//
//  ContentView.swift
//  Learning Journey
//
//  Created by Jana Abdulaziz Malibari on 16/10/2025.
//

import SwiftUI

struct ContentView: View {
    
    
    
    @Environment(\.colorScheme) var scheme
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedButton: String? = "Week" // default selected
        
    let periodDays: [String: Int] = [
           "Week": 7,
           "Month": 30,
           "Year": 365
       ]
    
    @State private var goal: String = ""
    
    var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)
            VStack (){
                ZStack{
                    Circle()
                        .background(.ultraThinMaterial)
                        .cornerRadius(100)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.6) ,.red.opacity(0.3), .orange.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                                .fill(Color.black.opacity(scheme == .dark ? 0.9 : 0))
                        )
                    
                        .glassEffect(.regular.interactive().tint(Color("Icon")))
                        .frame(width: 109, height: 109)
                    Image(systemName: "flame.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 40)
                        .foregroundColor(Color("AccentColor"))
                }
                .padding(.leading,-30)
                Text("Hello Learner")
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .foregroundColor(Color("MainText"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("This app will help you learn everyday!")
                    .font(.system(size: 17, weight: .regular, design: .default))
                    .foregroundColor(Color("SubText"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom)
                Text("I want to learn")
                    .font(.system(size: 22, weight: .regular, design: .default))
                    .foregroundColor(Color("MainText"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                TextField("Swift", text: $goal)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding(.bottom)
                Text("I want to learn it in a")
                    .font(.system(size: 22, weight: .regular, design: .default))
                    .foregroundColor(Color("MainText"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom)
                
                HStack(spacing: 16){
                    ForEach(["Week", "Month", "Year"], id: \.self) { title in
                        Button(title) {
                            selectedButton = title
                        }
                        .font(.system(size: 17, weight: .medium, design: .default))
                        .foregroundColor(Color("MainText"))
                        .frame(width: 97, height: 48)
                        .background(RoundedRectangle(cornerRadius: 100)
                            .fill(selectedButton == title
                                  ? (scheme == .dark
                                     ? Color(red: 0.70, green: 0.25, blue: 0.0) // selected in dark
                                     : Color("AccentColor")) // selected in light
                                  : Color.black.opacity(0.4) // not selected
                                 )
                                .opacity(selectedButton == title ? 0.9 : 0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 100)
                                        .stroke(
                                            LinearGradient(
                                                colors: selectedButton == title
                                                                            ? [.white.opacity(0.6), .white.opacity(0.1), .orange.opacity(0.7)]
                                                                            : [.white.opacity(0.2)],
                                                                        startPoint: .topLeading,
                                                                        endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                    )
                                    )
                        .glassEffect(.regular.interactive().tint(.black.opacity(0.4)))
      
                    }
                }
                .padding(.leading, -50)
                
                Button("Start learning") {
                    saveUserGoal()
                }
                .font(.system(size: 17, weight: .medium, design: .default))
                                   .foregroundColor(Color("MainText"))
                                   .frame(width: 182, height: 48)
                                   .background(RoundedRectangle(cornerRadius: 100)
                                       .fill(
                                           colorScheme == .dark
                                           ? Color(red: 0.70, green: 0.25, blue: 0.0) // matches your dark mode button
                                           : Color("AccentColor") // bright orange for light mode
                                       )
                                           .opacity(0.9)
                                           .overlay(
                                               RoundedRectangle(cornerRadius: 100)
                                                   .stroke(
                                                       LinearGradient(
                                                           colors: [
                                                               .white.opacity(0.6),
                                                               .orange.opacity(0.7)
                                                                   ],
                                                           startPoint: .topLeading,
                                                           endPoint: .bottomTrailing
                                                               ),
                                                           lineWidth: 1
                                                       )
                                                   )
                                           )
                                   .glassEffect(.regular.interactive().tint(Color("AccentColor")))
                .padding(.top, 250)

            }
            .padding(.leading)

            
        }
    }
        func saveUserGoal() {
            guard !goal.isEmpty, let selected = selectedButton else {
                print("⚠️ Please fill in the goal and select a period.")
                return
            }
            
            let days = periodDays[selected] ?? 0
            let userGoal = [
                "goal": goal,
                "period": selected,
                "days": days
            ] as [String : Any]
            
            UserDefaults.standard.set(userGoal, forKey: "userLearningGoal")
            
            print("✅ Goal saved: \(userGoal)")
        }
    }
#Preview {
    ContentView()
}
