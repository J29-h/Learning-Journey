//
//  NewGoal.swift
//  Learning Journey
//
//  Created by Jana Abdulaziz Malibari on 24/10/2025.
//

import SwiftUI

struct NewGoal: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var navigateToMainPage = false
    //    @State private var hidden = false
    @Environment(\.colorScheme) var scheme
    var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                NavigationLink(destination: NewGoal(), isActive: $navigateToMainPage) {
                    EmptyView()
                }
                .hidden()
                
                Button(action: {
                    viewModel.saveUserGoal()
                }) {
                    Image(systemName: "checkmark")
                        .foregroundColor(Color("MainText"))
                        .font(Font.system(size: 23, weight: .medium))
                }
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color("MainText"))
                .frame(width: 48, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 100)
                        .fill(scheme == .dark
                              ? Color(red: 0.70, green: 0.25, blue: 0.0)
                              : Color("AccentColor"))
                        .opacity(0.9)
                        .overlay(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(
                                    LinearGradient(
                                        colors: [.orange.opacity(0.6), .white.opacity(0.1),.orange.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .glassEffect(.regular.interactive())
                .padding(.leading, 325)
                
                Text("Learning Goal")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color("MainText"))
                    .padding(.bottom, 50)
                    .padding(.leading, 125)
                    .padding(.top, -40)
                Text("I want to learn")
                    .font(.system(size: 22))
                    .foregroundColor(Color("MainText"))
                
                TextField("Swift", text: $viewModel.goal)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.2))
                            .padding(.top, 8),
                        alignment: .bottom
                    )
                    .padding(.bottom)
                
                Text("I want to learn it in a")
                    .font(.system(size: 22))
                    .foregroundColor(Color("MainText"))
                    .padding(.bottom)
                HStack(spacing: 16){
                    ForEach(["Week", "Month", "Year"], id: \.self) { title in
                        Button(title) {
                            viewModel.selectPeriod(title)
                        }
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color("MainText"))
                        .frame(width: 97, height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 100)
                                .fill(viewModel.selectedButton == title
                                      ? (scheme == .dark
                                         ? Color(red: 0.70, green: 0.25, blue: 0.0)
                                         : Color("AccentColor"))
                                      : Color.black.opacity(0.4)
                                     )
                                .opacity(viewModel.selectedButton == title ? 0.9 : 0)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(
                                    LinearGradient(
                                        colors: viewModel.selectedButton == title
                                        ? [.orange.opacity(0.5), .white.opacity(0.1), .orange.opacity(0.5)]
                                        : [.white.opacity(0.2), .white.opacity(0.0), .white.opacity(0.0), .white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .glassEffect(.regular.interactive().tint(.black.opacity(0.1)))
                    }
                }
                .padding(.leading, 0)
            }
            .padding(.top, -360)
        }
        .edgesIgnoringSafeArea(.top)
        .padding(.leading)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarBackground(.clear, for: .navigationBar)
        .navigationBarBackButtonHidden(false)
    }
    
}

#Preview {
    NewGoal()
}
