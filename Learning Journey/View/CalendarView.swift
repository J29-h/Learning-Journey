//
//  CalendarView.swift
//  Learning Journey
//
//  Created by Jana Abdulaziz Malibari on 23/10/2025.
//

import SwiftUI

struct CalendarView: View {
    // Use the updated ViewModel
    @StateObject private var viewModel = CalendarViewModel()
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        NavigationView { // Added NavigationView for title display
            ZStack(alignment: .top){
                Color("Background").edgesIgnoringSafeArea(.all) // Background color
                
                // --- Top Gradient Overlay ---
                LinearGradient(
                        gradient: Gradient(colors: [Color("Background"), Color("Background").opacity(0)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 150) // Adjust height as needed
                    .zIndex(2) // Ensure gradient is above scroll content but below title
                    .allowsHitTesting(false) // Allow scrolling through the gradient

                // --- Scrollable Calendar Content ---
                ScrollViewReader { proxy in
                    ScrollView {
                        // Add top padding to push content below the gradient/title
                        Spacer(minLength: 100) // Adjust height to position content below gradient
                        
                        LazyVStack(spacing: 32) {
                            ForEach(Array(viewModel.months.enumerated()), id: \.offset) { index, month in
                                VStack(alignment: .leading, spacing: 16) {
                                    Text(viewModel.monthYearString(for: month))
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(Color("MainText"))
                                        .padding(.leading)
                                    
                                    // Weekday headers
                                    HStack {
                                        ForEach(viewModel.dayOfWeekHeaders(), id: \.self) { day in
                                            Text(day)
                                                .font(.system(size: 14, weight: .medium))
                                                .frame(maxWidth: .infinity)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    
                                    // Days grid
                                    let days = viewModel.daysInMonth(for: month)
                                    let columns = Array(repeating: GridItem(.flexible()), count: 7)
                                    
                                    LazyVGrid(columns: columns, spacing: 12) {
                                        ForEach(days.indices, id: \.self) { dayIndex in
                                            // Get the optional date
                                            let day = days[dayIndex]
                                            
                                            // Render cell content
                                            ZStack {
                                                // Background Circle (using ViewModel logic)
                                                Circle()
                                                    .fill(viewModel.dayBackgroundColor(for: day, scheme: scheme))
                                                    .frame(width: 38, height: 38)
                                                
                                                // Day Number Text (using ViewModel logic)
                                                Text(viewModel.dayString(for: day))
                                                    .font(.system(size: 17, weight: viewModel.isToday(day) ? .bold : .regular)) // Make today bold
                                                    .foregroundColor(viewModel.dayForegroundColor(for: day, scheme: scheme))
                                                    .frame(width: 38, height: 38) // Ensure text frame matches circle
                                            }
                                            // Make empty cells clear and non-interactive
                                            .opacity(day == nil ? 0 : 1)
                                            .allowsHitTesting(day != nil)
                                        }
                                    }
                                    
                                    Divider()
                                        .background(Color.gray.opacity(0.4))
                                        .padding(.top, 10)
                                }
                                .id(index) // ID for ScrollViewReader
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 50) // Add padding at the bottom
                        
                    } // End ScrollView
                    .onAppear {
                        // Scroll to current month after view appears
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Slight delay
                           // Check if index is valid before scrolling
                            if viewModel.currentMonthIndex < viewModel.months.count {
                                withAnimation(.easeInOut) {
                                     proxy.scrollTo(viewModel.currentMonthIndex, anchor: .top)
                                }
                             }
                        }
                    }
                } // End ScrollViewReader
                
                // --- Static Title (Above Gradient) ---
                 Text("All activities")
                     .font(.system(size: 17, weight: .semibold))
                     .foregroundColor(Color("MainText"))
                     .padding(.top, 55) // Adjust top padding to position below safe area
                     .frame(maxWidth: .infinity) // Center the title
                     .zIndex(3) // Ensure title is on top
                
            } // End ZStack
            .navigationBarHidden(true) // Hide the default navigation bar if using custom title
            .navigationBarBackButtonHidden(false)
            .edgesIgnoringSafeArea(.top) // Allow content to go under status bar if needed

        } // End NavigationView
         .navigationViewStyle(.stack) // Use stack style
    }
}
#Preview {
    CalendarView()
}
