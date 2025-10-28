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
    
    // Custom color extension for clean code (assuming you have these in an Asset Catalog)
    private var accentColor: Color { scheme == .dark ? Color(red: 0.70, green: 0.25, blue: 0.0) : Color("AccentColor") }
    private var mainTextColor: Color { Color("MainText") }
    private var subTextColor: Color { Color("SubText") }
    private var backgroundColor: Color { Color("Background") }
    var goalDidSet: () -> Void
    
    
    init(goalDidSet: @escaping () -> Void) {
            self.goalDidSet = goalDidSet
        }
    
    var body: some View {

        NavigationView {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                VStack {
                    headerView
                    goalInputView
                    periodSelectionView
                    startLearningButton
                }
                .padding(.all)
                .padding(.leading)
                .padding(.bottom, 65)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }
    
    private var headerView: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .center){
                Circle()
//                    .background(.ultraThinMaterial)
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
                .foregroundColor(mainTextColor)
                .padding(.leading, -110)
                .padding(.bottom, 4)
            Text("This app will help you learn everyday!")
                .font(.system(size: 17))
                .foregroundColor(subTextColor)
                .padding(.leading, -110)
            
                .padding(.bottom)
        }
        .padding(.horizontal)
    }
    
    private var goalInputView: some View {
        VStack(alignment: .leading) {
            Text("I want to learn")
                .font(.system(size: 22))
                .foregroundColor(mainTextColor)
                .padding(.leading, -20)
            
            // BINDING: Binds the TextField text directly to the ViewModel's goal property
            TextField("Swift", text: $viewModel.goal)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .foregroundColor(mainTextColor) // Ensure text is visible
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.2))
                        .padding(.top, 8),
                    alignment: .bottom
                )
                .padding(.bottom)
                .padding(.leading, -20)

            
            Text("I want to learn it in a")
                .font(.system(size: 22))
                .foregroundColor(mainTextColor)
                .padding(.bottom)
                .padding(.leading, -20)

        }
    }
    
    private var periodSelectionView: some View {
        HStack(spacing: 16){
            ForEach(PeriodSelection.allCases, id: \.self) { period in
                let title = period.rawValue // Week, Month, Year
                
                Button(title) {
                    viewModel.selectPeriod(title) // Calls ViewModel function
                }
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color("MainText"))
                .frame(width: 97, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 100)
                        .fill(viewModel.selectedButton == title
                              ? accentColor
                              : Color.black.opacity(0.4)
                            )
//                        .opacity(viewModel.selectedButton == title ? 0.9 : 0)
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
                 .glassEffect(.regular.interactive().tint(.black.opacity(0.1))) // Custom modifier
            }
        }
        .padding(.leading, -50)
    }
    
    private var startLearningButton: some View {
        VStack {
            // NavigationLink setup
            NavigationLink(destination: MainView(), isActive: $navigateToMainPage) {
                EmptyView()
            }
            .hidden()
            
            Button("Start learning") {
                // Check validation before saving and navigating
                if viewModel.isInputValid {
                    viewModel.saveUserGoal() // Save data
                    goalDidSet()
                }
            }
            .font(.system(size: 17, weight: .medium))
            .foregroundColor(Color(viewModel.isInputValid ? "MainText" : "SubText").opacity(viewModel.isInputValid ? 1.0 : 0.6))
            .frame(width: 182, height: 48)
            .background(
                RoundedRectangle(cornerRadius: 100)
                    // BACKGROUND COLOR: Use accentColor if valid, otherwise gray
                    .fill(viewModel.isInputValid ? accentColor : Color.gray.opacity(0.6))
                    .opacity(0.9)
                    .overlay(
                        RoundedRectangle(cornerRadius: 100)
                            .stroke(
                                LinearGradient(
                                    colors: viewModel.isInputValid
                                        ? [.orange.opacity(0.6), .white.opacity(0.1), .orange.opacity(0.7)]
                                        : [.clear], // Clear stroke if disabled
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            // DISABLE: Button is disabled until the ViewModel confirms both inputs are valid
            .disabled(!viewModel.isInputValid)
             .glassEffect(.regular.interactive()) // Custom modifier
            .padding(.top, 250)
            .padding(.leading, -20)
        }
    }
}

#Preview {
    ContentView(goalDidSet: { print("Preview goal set action") })
}
