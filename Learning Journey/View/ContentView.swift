//
//  ContentView.swift
//  Learning Journey
//
//  Created by Jana Abdulaziz Malibari on 16/10/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @Environment(\.colorScheme) var scheme
    @State private var navigateToMainPage = false
    
    var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                headerView
                goalInputView
                periodSelectionView
                startLearningButton
            }
            .padding(.leading)
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading) {
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
            .padding(.leading,20)
            .padding(.bottom, 30)
            
            Text("Hello Learner")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(Color("MainText"))
                .padding(.leading, -110)
            Text("This app will help you learn everyday!")
                .font(.system(size: 17))
                .foregroundColor(Color("SubText"))
                .padding(.leading, -110)
            
                .padding(.bottom)
        }
    }
    
    private var goalInputView: some View {
        VStack(alignment: .leading) {
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
        }
    }
    
    private var periodSelectionView: some View {
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
        .padding(.leading, -50)
    }
    
    private var startLearningButton: some View {
        VStack {
            NavigationLink(destination: MainView(), isActive: $navigateToMainPage) {
                EmptyView()
            }
            .hidden()
            
            Button("Start learning") {
                viewModel.saveUserGoal()
                navigateToMainPage = true
            }
            .font(.system(size: 17, weight: .medium))
            .foregroundColor(Color("MainText"))
            .frame(width: 182, height: 48)
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
                                    colors: [.orange.opacity(0.6), .white.opacity(0.1), .orange.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .glassEffect(.regular.interactive())
            .padding(.top, 250)
            .padding(.leading, -20)
        }
    }
}
#Preview {
    ContentView()
}
