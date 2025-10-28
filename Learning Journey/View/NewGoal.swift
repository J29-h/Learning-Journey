//
//  NewGoal.swift
//  Learning Journey
//
//  Created by Jana Abdulaziz Malibari on 24/10/2025.
//

import SwiftUI

struct NewGoal: View {
    // Use the new ViewModel
    @StateObject private var viewModel = NewGoalViewModel()
    @Environment(\.colorScheme) var scheme
    @Environment(\.presentationMode) var presentationMode // For dismissing the view

    // --- REMOVED: State for Navigation ---
    // @State private var navigateToMainPage = false

    // Computed property for accent color based on scheme
    private var accentColor: Color { scheme == .dark ? Color(red: 0.70, green: 0.25, blue: 0.0) : Color("AccentColor") }
    private var mainTextColor: Color { Color("MainText") }
    private var subTextColor: Color { Color("SubText") }

    var body: some View {
        // Wrap in NavigationView for title and toolbar items
        NavigationView {
            ZStack {
                Color("Background").ignoresSafeArea()

                VStack(alignment: .leading, spacing: 20) {

                    // --- Goal Input ---
                    Text("I want to learn")
                        .font(.system(size: 22))
                        .foregroundColor(mainTextColor)

                    TextField("Enter your goal", text: $viewModel.goal)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .foregroundColor(mainTextColor)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.2))
                                .padding(.top, 30),
                            alignment: .bottom
                        )
                        .padding(.bottom, 30)

                    // --- Period Selection ---
                    Text("I want to learn it in a")
                        .font(.system(size: 22))
                        .foregroundColor(mainTextColor)

                    HStack(spacing: 16){
                        ForEach(PeriodSelection.allCases, id: \.self) { period in
                            let title = period.rawValue
                            Button(title) {
                                viewModel.selectPeriod(title)
                            }
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(mainTextColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 100)
                                    .fill(viewModel.selectedButton == title
                                          ? accentColor.opacity(0.9)
                                          : Color.clear)
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
                            .background(.ultraThinMaterial.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 100))
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Spacer()

                    // --- REMOVED: Hidden NavigationLink ---
                    // NavigationLink(...) { EmptyView() }.hidden()

                }
                .padding()
            }
            .navigationTitle("Learning Goal")
            .navigationBarTitleDisplayMode(.inline)
             // Keep back button visible if presented modally or pushed
            .navigationBarBackButtonHidden(false)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.requestUpdateConfirmation()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(accentColor)
                                .frame(width: 30, height: 30)
                            Image(systemName: "checkmark")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(Color("MainText"))
                        }
                    }
                    .disabled(!viewModel.isInputValid || !viewModel.hasChanges)
                    .opacity((!viewModel.isInputValid || !viewModel.hasChanges) ? 0.5 : 1.0)
                }
            }
            .alert("Update Learning goal", isPresented: $viewModel.showingConfirmationAlert) {
                Button("Dismiss", role: .cancel) { }
                Button("Update", role: .destructive) {
                    viewModel.confirmUpdateGoal()
                    // --- UPDATED: Dismiss the view ---
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("If you update now, your streak will start over.")
            }
        }
        .navigationViewStyle(.stack) // Use stack style
    }
}

#Preview {
    NewGoal()
}
