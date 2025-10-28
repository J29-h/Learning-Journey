//
//  CalendarView.swift
//  Learning Journey
//
//  Created by Jana Abdulaziz Malibari on 23/10/2025.
//

import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @Environment(\.colorScheme) var scheme

    var body: some View {
        ZStack(alignment: .top) {
            Color("Background").edgesIgnoringSafeArea(.all)
            
            LinearGradient(
                gradient: Gradient(colors: [Color("Background"), Color("Background").opacity(0)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 150)
            .zIndex(2)
            .allowsHitTesting(false)

            ScrollViewReader { proxy in
                ScrollView {
                    Spacer(minLength: 100)
                    
                    LazyVStack(spacing: 32) {
                        ForEach(Array(viewModel.months.enumerated()), id: \.offset) { index, month in
                            VStack(alignment: .leading, spacing: 16) {
                                Text(viewModel.monthYearString(for: month))
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(Color("MainText"))
                                    .padding(.leading)
                                
                                HStack {
                                    ForEach(viewModel.dayOfWeekHeaders(), id: \.self) { day in
                                        Text(day)
                                            .font(.system(size: 14, weight: .medium))
                                            .frame(maxWidth: .infinity)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                let days = viewModel.daysInMonth(for: month)
                                let columns = Array(repeating: GridItem(.flexible()), count: 7)
                                
                                LazyVGrid(columns: columns, spacing: 12) {
                                    ForEach(days.indices, id: \.self) { dayIndex in
                                        let day = days[dayIndex]
                                        
                                        ZStack {
                                            Circle()
                                                .fill(viewModel.dayBackgroundColor(for: day, scheme: scheme))
                                                .frame(width: 38, height: 38)
                                            
                                            Text(viewModel.dayString(for: day))
                                                .font(.system(size: 17, weight: viewModel.isToday(day) ? .bold : .regular))
                                                .foregroundColor(viewModel.dayForegroundColor(for: day, scheme: scheme))
                                                .frame(width: 38, height: 38)
                                        }
                                        .opacity(day == nil ? 0 : 1)
                                        .allowsHitTesting(day != nil)
                                    }
                                }
                                
                                Divider()
                                    .background(Color.gray.opacity(0.4))
                                    .padding(.top, 10)
                            }
                            .id(index)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 50)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if viewModel.currentMonthIndex < viewModel.months.count {
                            withAnimation(.easeInOut) {
                                proxy.scrollTo(viewModel.currentMonthIndex, anchor: .top)
                            }
                        }
                    }
                }
            }
            
            // Custom title (kept)
            Text("All activities")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color("MainText"))
                .padding(.top, -30)
                .frame(maxWidth: .infinity)
                .zIndex(3)
        }
        .navigationBarTitleDisplayMode(.inline) // So back button shows with custom title
    }
}

#Preview {
    NavigationView {
        CalendarView()
    }
}
