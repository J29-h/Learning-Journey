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
        ZStack(alignment: .top){
            Text("All activities")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color("MainText"))
                .zIndex(3)
                .padding(.top, 70)
            ScrollViewReader { proxy in
                ScrollView {
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
                                    ForEach(days, id: \.self) { day in
                                        if viewModel.isToday(day) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.orange)
                                                    .frame(width: 38, height: 38)
                                                Text(viewModel.dayString(for: day))
                                                    .font(.system(size: 24, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                        } else {
                                            Text(viewModel.dayString(for: day))
                                                .font(.system(size: 20))
                                                .frame(width: 38, height: 38)
                                                .foregroundColor(Color("MainText"))
                                        }
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
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.easeInOut) {
                                proxy.scrollTo(viewModel.currentMonthIndex, anchor: .top)
                            }
                        }
                    }
                }
            }
            LinearGradient(
                    gradient: Gradient(colors: [Color("Background"), Color("Background").opacity(0)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 190)
                .zIndex(2)
        }
        .edgesIgnoringSafeArea(.top)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(false)
    }
}
#Preview {
    CalendarView()
}
