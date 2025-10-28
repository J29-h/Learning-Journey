//
//  SwiftUIView.swift
//  Learning Journey
//
//  Created by Jana Abdulaziz Malibari on 20/10/2025.
//

import SwiftUI
import Combine

struct MainView: View {

    @StateObject private var viewModel = MainLogic()
    @Environment(\.colorScheme) var scheme

    // Navigation state
    @State private var navigateToGoalPage = false
    @State private var navigateToCalendarPage = false

    // Color assets (ensure these exist in your Assets catalog)
    private var accentColor: Color { Color("AccentColor") }
    private var mainTextColor: Color { Color("MainText") }
    private var subTextColor: Color { Color("SubText") }
    private var backgroundColor: Color { Color("Background") }
    private var recColor: Color { Color("Rec") }
    private var freezeColor: Color { Color("Freeze") } // Used for day bg
    private var iconColor: Color { Color("Icon") } // Used for learned day bg

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                backgroundColor.edgesIgnoringSafeArea(.all)

                VStack(alignment: .center) { // Main content VStack
                    // --- Top Bar ---
                    HStack {
                        Text("Activity")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(mainTextColor)

                        Spacer()

                        // Calendar Button
                        Button { navigateToCalendarPage = true } label: {
                            Image(systemName: "calendar")
                                .foregroundColor(mainTextColor) // Use main text color
                        }
                        .modifier(TopBarButtonModifier()) // Apply consistent style

                        // Edit Goal Button
                        Button { navigateToGoalPage = true } label: {
                            Image(systemName: "pencil.and.outline")
                                .foregroundColor(mainTextColor) // Use main text color
                        }
                        .modifier(TopBarButtonModifier()) // Apply consistent style

                        // Hidden Navigation Links
                        .background(
                            NavigationLink(destination: CalendarView(), isActive: $navigateToCalendarPage) { EmptyView() }
                                .hidden()
                        )
                        .background(
                            NavigationLink(destination: NewGoal(), isActive: $navigateToGoalPage) { EmptyView() }
                                .hidden()
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 5) // Adjust padding if needed below safe area

                    // --- Calendar View Box ---
                    VStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Text("\(viewModel.currentMonthName) \(viewModel.currentYearString)")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(mainTextColor) // Use main text color

                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.togglePicker()
                                }
                            } label: {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(mainTextColor) // Use main text color
                                    .rotationEffect(.degrees(viewModel.showPicker ? 90 : 0))
                            }
                            
                            // --- RESTORED: Previous Week and Next Week Buttons ---
                            Spacer()
                            // Previous Week
                            Button(action: { viewModel.previousWeek() }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(accentColor)
                            }
                            // Next Week
                            Button(action: { viewModel.nextWeek() }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(accentColor)
                            }
                            // --- END RESTORED LOGIC ---
                        }
                        .frame(maxWidth: .infinity, alignment: .leading) // Align month/year left
                        .padding(.horizontal)
                        .zIndex(10) // Keep picker toggle above scroll
                        .padding(.top, 13) // Restored top padding for alignment

                        // Week Days Scroll
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 5) {
                                ForEach(viewModel.currentWeek, id: \.self) { date in
                                    Button { viewModel.select(date: date) } label: {
                                        VStack(spacing: 4) {
                                            Text(viewModel.weekdayString(from: date).uppercased())
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundColor(subTextColor.opacity(0.6)) // Use sub text color

                                            Text("\(viewModel.dayNumber(from: date))")
                                                .font(.system(size: 20, weight: .medium))
                                                // Use VM for foreground color
                                                .foregroundColor(viewModel.dayForegroundColor(for: date, scheme: scheme))
                                                .frame(width: 44, height: 44)
                                                .background(
                                                    Circle()
                                                        // Use VM for background fill
                                                        .fill(viewModel.dayFillColor(for: date, scheme: scheme))
                                                )
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                        .padding(.bottom, 10) // Add padding below week scroll

                        // Divider
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.white.opacity(0.2))
                            .padding(.horizontal) // Apply padding to divider


                        // Streak Counters
                        Text("Learning Activity")
                            .font(Font.system(size: 16, weight: .semibold))
                            .foregroundColor(mainTextColor) // Use main text color
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading)
                            .padding(.bottom, 1)


                        HStack(spacing: 13) {
                            // Learned Days Streak Box
                            StreakBox(
                                value: "\(viewModel.daysLearned)",
                                label: viewModel.daysLearnedLabel, // Use VM label
                                iconName: "flame.fill",
                                iconColor: accentColor,
                                backgroundColor: recColor
                            )

                            // Freezed Days Box
                            StreakBox(
                                value: "\(viewModel.daysFreezed)",
                                label: viewModel.daysFreezedLabel, // Use VM label
                                iconName: "cube.fill",
                                iconColor: Color(red: 60/255, green: 211/255, blue: 254/255), // Specific blue
                                backgroundColor: Color(red: 27/255, green: 63/255, blue: 74/255) // Specific dark teal
                            )
                        }
                        .padding(.horizontal) // Add padding to the HStack

                    } // End Calendar Box VStack
                    .padding(.vertical) // Add vertical padding to the box
                    .background(.ultraThinMaterial.opacity(0.6)) // Use material background
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(LinearGradient.ultraThinMaterialBorder, lineWidth: 1) // Consistent border
                    )
                    .cornerRadius(13)
                    .padding(.horizontal) // Padding around the calendar box
                    .padding(.top, 5) // Space below top bar


                    Spacer(minLength: 30) // Add space before buttons


                    // --- Action Buttons ---

                    // Log Button
                    Button { viewModel.logLearned() } label: {
                        Text(viewModel.logButtonText)
                            .font(.system(size: 36, weight: .bold))
                            .multilineTextAlignment(.center) // Ensure text centers if it wraps
                            .foregroundColor(viewModel.logButtonForegroundColor(scheme: scheme))
                            .frame(width: 274, height: 274)
                            .background(
                                Circle()
                                    .fill(viewModel.logButtonFillColor(scheme: scheme))
                                    .overlay(Circle().stroke(LinearGradient.mainButtonBorder(isPressed: viewModel.hasLoggedToday || viewModel.hasFrozenToday), lineWidth: 1.5)) // Adjusted border slightly
                                    .shadow(color: .black.opacity(0.3), radius: 10, y: 5) // Add shadow
                            )
                    }
                    .disabled(!viewModel.canLogAction) // Use VM property
                    .opacity(!viewModel.canLogAction ? 0.6 : 1.0) // Dim if disabled


                    // Freeze Button
                    Button { viewModel.logFreeze() } label: {
                        Text(viewModel.freezeButtonText)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(mainTextColor) // Use main text color
                            .frame(maxWidth: 274) // Match width for alignment
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 50)
                                    .fill(viewModel.freezeButtonFillColor(scheme: scheme))
                                    .overlay(RoundedRectangle(cornerRadius: 50).stroke(LinearGradient.ultraThinMaterialBorder, lineWidth: 1))
                            )
                            .background(.ultraThinMaterial.opacity(0.5)) // Add material effect
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                            .shadow(color: .black.opacity(0.2), radius: 5, y: 3) // Add subtle shadow
                    }
                    .disabled(viewModel.isFreezeButtonDisabled) // Use VM property
                    .opacity(viewModel.isFreezeButtonDisabled ? 0.6 : 1.0) // Dim if disabled
                    .padding(.top, 20) // Space between buttons


                    // Freeze Counter Text
                    Text(viewModel.freezesRemainingText)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(subTextColor.opacity(0.7)) // Use sub text color
                        .padding(.top, 12)

                    Spacer() // Pushes content towards center/top

                } // End Main content VStack

                // --- Overlays ---

                // Calendar Picker (Month/Year)
                if viewModel.showPicker {
                    MonthYearPicker(
                        selectedMonthIndex: $viewModel.selectedMonthIndex,
                        selectedYear: $viewModel.selectedYear,
                        availableMonths: viewModel.availableMonths,
                        availableYears: viewModel.availableYears
                    )
                     .offset(y: 130) // Adjust offset as needed
                     .transition(.scale(scale: 0.8, anchor: .top).combined(with: .opacity))
                     .zIndex(20) // Ensure picker is on top
                }

                // "Well Done!" Overlay (Keep this functional)
                if viewModel.showOverlay {
                     WellDoneOverlay(viewModel: viewModel)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(100) // Ensure overlay is on top of everything
                }

            } // End ZStack
            .navigationBarHidden(true) // Hide the default navigation bar

        } // End NavigationStack
        .navigationViewStyle(.stack) // Use stack style for consistency
    }
}


// MARK: - Helper Views/Modifiers

// Modifier for consistent top bar button styling
struct TopBarButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 44, height: 44)
            .background(.ultraThinMaterial.opacity(0.7)) // Use material background
            .overlay(Circle().stroke(LinearGradient.ultraThinMaterialBorder, lineWidth: 1)) // Consistent border
            .clipShape(Circle())
    }
}

// Simple struct for the Month/Year Picker
struct MonthYearPicker: View {
    @Binding var selectedMonthIndex: Int
    @Binding var selectedYear: Int
    let availableMonths: [String]
    let availableYears: [Int]

    var body: some View {
        HStack(spacing: 0) {
            Picker("Month", selection: $selectedMonthIndex) {
                ForEach(0..<availableMonths.count, id: \.self) { index in
                    Text(availableMonths[index]).tag(index)
                        .foregroundColor(.white) // Ensure text is visible
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 150)
            .clipped()

            Picker("Year", selection: $selectedYear) {
                ForEach(availableYears, id: \.self) { year in
                    Text(String(year)).tag(year)
                        .foregroundColor(.white) // Ensure text is visible
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 100)
            .clipped()
        }
        .padding()
        .background(.black.opacity(0.8)) // Dark background for picker
        .background(.ultraThinMaterial)   // Material effect underneath
        .cornerRadius(13)
        .shadow(radius: 10)
    }
}

// Simple struct for the Streak Boxes
struct StreakBox: View {
    let value: String
    let label: String
    let iconName: String
    let iconColor: Color
    let backgroundColor: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .foregroundColor(iconColor)
                .font(.system(size: 24)) // Adjust icon size
                .frame(width: 41, height: 41) // Maintain frame

            VStack(alignment: .leading, spacing: 2) { // Adjust spacing
                Text(value)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color("MainText")) // Use main text color
                Text(label)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color("SubText")) // Use sub text color
            }
            Spacer() // Push content to the left
        }
        .padding(.horizontal, 14) // Add horizontal padding
        .frame(height: 69) // Maintain height
        .frame(maxWidth: .infinity) // Allow box to expand
        .background(backgroundColor)
        .cornerRadius(34) // Use corner radius for rounded ends
    }
}

// Simple struct for the "Well Done!" Overlay
struct WellDoneOverlay: View {
    @ObservedObject var viewModel: MainLogic

    var body: some View {
        ZStack {
            // Semi-transparent background scrim
            Color.black.opacity(0.7).ignoresSafeArea()
                .onTapGesture {
                    // Optional: Dismiss on background tap
                    // withAnimation { viewModel.showOverlay = false }
                }

            VStack(spacing: 20) { // Increased spacing
                Image(systemName: "hands.and.sparkles.fill")
                    .symbolEffect(.bounce.up.byLayer, options: .repeat(.continuous))
                    .font(.system(size: 50)) // Larger icon
                    .foregroundColor(Color("AccentColor"))

                Text("Well Done!")
                    .font(.system(size: 28, weight: .bold)) // Larger title
                    .foregroundColor(.white)

                Text("Goal completed! Start learning again or set a new learning goal.")
                    .font(.system(size: 17, weight: .regular)) // Adjusted text
                    .foregroundColor(Color.gray) // Use gray for subtitle
                    .multilineTextAlignment(.center)
                    .padding(.horizontal) // Add horizontal padding

                Spacer().frame(height: 30) // Add more space

                // Button 1: Continue Same Goal (Soft Reset)
                Button("Continue Same Goal") {
                    // --- CHANGED: Calls ViewModel function ---
//                    viewModel.continueSameGoal()
                }
                .buttonStyle(OverlayButtonStyle(backgroundColor: Color("AccentColor"))) // Use custom style

                // Button 2: Set New Goal (Hard Reset & Navigation)
                Button("Set New Learning Goal") {
                    // --- CHANGED: Calls ViewModel function ---
//                    viewModel.resetGoalAndOpenSetup()
                }
                .buttonStyle(OverlayButtonStyle(backgroundColor: .clear, foregroundColor: Color("AccentColor"), strokeColor: Color("AccentColor"))) // Use custom style


            }
            .padding(EdgeInsets(top: 40, leading: 32, bottom: 40, trailing: 32)) // More vertical padding
            .background(Color("Background")) // Use app background color
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.4), radius: 20)
            .padding(30) // Padding around the card
        }
    }
}

// Custom ButtonStyle for Overlay buttons
struct OverlayButtonStyle: ButtonStyle {
    var backgroundColor: Color = .blue
    var foregroundColor: Color = .white
    var strokeColor: Color? = nil

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .medium))
            .padding(.horizontal, 24)
            .padding(.vertical, 14) // Increase vertical padding
            .frame(maxWidth: .infinity) // Make buttons full width
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .overlay(
                // Add stroke if strokeColor is provided
                 strokeColor != nil ?
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(strokeColor!, lineWidth: 1.5)
                    : nil // Use RoundedRectangle for stroke
            )
            .cornerRadius(100)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0) // Add press effect
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Helper Gradients (Example)
// Define common gradients to avoid repetition
extension LinearGradient {
    static var ultraThinMaterialBorder: LinearGradient {
        LinearGradient(colors: [.white.opacity(0.2), .white.opacity(0.0), .white.opacity(0.0), .white.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static func mainButtonBorder(isPressed: Bool) -> LinearGradient {
        LinearGradient(
            colors: isPressed
            ? [.white.opacity(0.3), Color("AccentColor").opacity(0.3), .clear.opacity(0.9), Color("AccentColor").opacity(0.2)] // Use AccentColor in pressed state
            : [.white.opacity(0.6), Color("AccentColor").opacity(0.3), Color("AccentColor").opacity(0.9)], // Use AccentColor in default state
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
#Preview {
    MainView()
}
