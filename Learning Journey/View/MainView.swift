//
//  SwiftUIView.swift
//  Learning Journey
//
//  Created by Jana Abdulaziz Malibari on 20/10/2025.
//

import SwiftUI
import Combine

struct MainView: View {
    
    @StateObject private var viewModel = MainPageViewModel()
    @Environment(\.colorScheme) var scheme
    @Environment(\.colorScheme) var scheme1
    @State private var navigateToGoalPage = false
    @State private var navigateToCalendarPage = false
    @State private var isPressed = false
    @State private var Pressed = false
    @State private var Day = 0
    let calendar = Calendar.current
    
    
    var body: some View {
        ZStack(alignment: .top) {
            Color("Background").edgesIgnoringSafeArea(.all)
            
            // The Begining of the page
            VStack(alignment: .center) {
                HStack(spacing: 20) {
                    //Top-Bar
                    Text("Activity")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color("MainText"))
                        .padding(.leading, -135)
                    
                    Spacer()
                    NavigationStack {
                        HStack{
                            Button(action: {
                                navigateToCalendarPage = true
                            }) {
                                Image(systemName: "calendar")
                                    .foregroundColor(Color("TextColor"))
                            }
                            .frame(width: 44, height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 100)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                .white.opacity(0.3),
                                                .white.opacity(0.0),
                                                .white.opacity(0.0),
                                                .white.opacity(0.0)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .glassEffect(.regular.interactive().tint(.black.opacity(0.4)))
                            .padding(.all, 10)
                            
                            NavigationLink(destination: CalendarView(),
                                           isActive: $navigateToCalendarPage) {
                                EmptyView()
                            }
                            
                            Button(action: {
                                navigateToGoalPage = true
                            }) {
                                Image(systemName: "pencil.and.outline")
                                    .foregroundColor(Color("TextColor"))
                            }
                            .frame(width: 44, height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 100)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                .white.opacity(0.3),
                                                .white.opacity(0.0),
                                                .white.opacity(0.0),
                                                .white.opacity(0.0)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .glassEffect(.regular.interactive().tint(.black.opacity(0.4)))
                            NavigationLink(destination: NewGoal(),
                                           isActive: $navigateToGoalPage) {
                                EmptyView()
                            }
                        }
                        .padding(.leading, 70)
                        .padding(.trailing, 10)
                    }
                    
                }
                .padding(.leading, 150)
                //Calendar
                VStack(spacing: 12) {
                    HStack(spacing: 28) {
                        HStack(spacing: 4) {
                            Text("\(viewModel.currentMonthName) \(viewModel.currentYearString)")
                                .font(.system(size: 17, weight: .semibold))
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    viewModel.togglePicker()}
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .rotationEffect(.degrees(viewModel.showPicker ? 90 : 0))
                                    .animation(.easeInOut, value: viewModel.showPicker)
                            }
                        }
                        .padding(.leading, 11)
                        .zIndex(10)
                        Spacer()
                        // Previous Week
                        Button(action: { viewModel.previousWeek() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color("AccentColor"))
                        }
                        // Next Week
                        Button(action: { viewModel.nextWeek() }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color("AccentColor"))
                        }
                    }
                    .padding(.trailing,16)
                    .padding(.top, 13)
                    
                    // Week Days Scroll
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 5) {
                            ForEach(viewModel.currentWeek, id: \.self) { date in
                                Button(action: { viewModel.select(date: date) }) {
                                    VStack(spacing: 4) {
                                        Text(viewModel.weekdayString(from: date).uppercased())
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(Color("SubText").opacity(0.4))
                                        
                                        Text("\(viewModel.dayNumber(from: date))")
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(viewModel.isSelected(date) ? .white : .primary)
                                            .frame(width: 44, height: 44)
                                            .background(
                                                Circle()
                                                    .fill(viewModel.isSelected(date) ? Color.accentColor : Color.clear))
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                    .animation(.easeInOut, value: viewModel.currentWeek)
                    .padding(.bottom,-10)
                    //Divider
                    Rectangle()
                        .frame(width: 333 ,height: 1)
                        .foregroundColor(.white.opacity(0.2))
                        .padding(.all)
                        .padding(.top, -10)
                        .padding(.bottom, -10)
                    
                    //Streak Counter
                    Text("Learning Activity")
                        .font(Font.system(size: 16, weight: .semibold))
                        .padding(.leading, -165)
                        .padding(.top,-10)
                        .padding(.bottom,-10)
                    
                    HStack(alignment: .center, spacing: 13){
                        // Learned Days Streak
                        ZStack(alignment: .leading){
                            RoundedRectangle(cornerRadius: 34)
                                .frame(width: 160, height: 69)
                                .foregroundColor(Color("Rec"))
                            HStack(spacing: 0){
                                Image(systemName: "flame.fill")
                                    .foregroundColor(Color("AccentColor"))
                                    .frame(width: 41, height: 41)
                                VStack(alignment: .leading){
                                    Text("0")
                                        .font(.system(size: 24, weight: .semibold))
                                    Text("Days Learned")// add the loginc here
                                        .font(.system(size: 12, weight: .regular))
                                }
                            }
                            .padding(.leading,14)
                        }
                        // Freezed Days Streak
                        ZStack(alignment: .leading){
                            RoundedRectangle(cornerRadius: 34)
                                .frame(width: 160, height: 69)
                                .foregroundColor(Color(red: 27/255, green: 63/255, blue: 74/255))
                            HStack(spacing: 0){
                                Image(systemName: "cube.fill")
                                    .foregroundColor(Color(red: 60/255, green: 211/255, blue: 254/255))
                                    .frame(width: 41, height: 41)
                                VStack(alignment: .leading){
                                    Text("0")
                                        .font(.system(size: 24, weight: .semibold))
                                    Text("Days Freezed")// add the loginc here
                                        .font(.system(size: 12, weight: .regular))
                                }
                            }
                            .padding(.leading,14)
                        }
                    }
                    .padding(.all)
                }
                //Frame Layout
                .frame(width: 365, height: 254, alignment: .center)
                .overlay(
                    RoundedRectangle(cornerRadius: 13)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.2),
                                    .white.opacity(0.0),
                                    .white.opacity(0.0),
                                    .white.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .glassEffect(.regular.tint(.black.opacity(0.6)), in: .rect(cornerRadius: 13))
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .padding(.top, 24)
                .padding(.bottom,32)
                
                // Log Btn
                Button( action: {
                    viewModel.press()
                    isPressed = true
                }) {
                    Text("Log as \nLearned")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(isPressed ? Color("AccentColor") : Color("MainText"))
                        .frame(width: 274, height: 274)
                        .background(
                            Circle()
                                .fill(
                                    scheme == .dark
                                    ? (viewModel.isPressed ? Color("Icon") : Color(red: 0.70, green: 0.25, blue: 0.0))  // dark mode
                                    : (viewModel.isPressed ? Color("Icon") : Color("AccentColor"))  // light mode
                                )
                                .stroke(
                                    LinearGradient(
                                        colors: viewModel.Pressed
                                        ? [.white.opacity(0.3), .brown.opacity(0.3), .clear.opacity(0.9), .red.opacity(0.2)]
                                        : [.white.opacity(0.6) ,.red.opacity(0.3), .orange.opacity(0.9)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing),
                                    lineWidth: 1
                                )
                                .overlay(
                                    Group {
                                        if scheme == .dark && viewModel.isPressed {
                                            Circle()
                                                .fill(Color.black.opacity(0.9))
                                                .stroke(
                                                    LinearGradient(
                                                        colors: viewModel.isPressed
                                                        ? [.white.opacity(0.3), .brown.opacity(0.3), .clear.opacity(0.9), .red.opacity(0.2)]
                                                        : [.white.opacity(0.6) ,.red.opacity(0.3), .orange.opacity(0.9)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing),
                                                    lineWidth: 1
                                                )
                                        }
                                        if scheme1 == .dark && viewModel.Pressed {
                                            Circle()
                                                .fill(Color(red: 0/255, green: 83/255, blue: 89/255))
                                                .fill(Color.black.opacity(0.9))
                                                .overlay(
                                                    Circle()
                                                        .stroke(
                                                            LinearGradient(
                                                                colors: [.white.opacity(0.5), .mint.opacity(0.3), .mint.opacity(0.0), .mint.opacity(0.0), .mint.opacity(0.0), .mint.opacity(0.7)],
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing),
                                                            lineWidth: 1
                                                        )
                                                )
                                        }
                                    }
                                )
                            
                        )
                        .glassEffect(.regular.interactive())
                }
                
                // Freeze Btn
                Button( action: {
                    viewModel.FreezePress()
                    Pressed = true
                }) {
                    Text("Log as Freezed")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color("MainText"))
                        .frame(width: 274, height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 50)
                                .fill(
                                    scheme1 == .dark
                                    ? (viewModel.Pressed ? Color("Freezed") : Color("Freeze"))  // dark mode
                                    : (viewModel.Pressed ? Color("Freezed") : Color("Freeze"))  // light mode
                                )
                                .overlay(
                                    Group {
                                        if scheme1 == .dark {
                                            RoundedRectangle(cornerRadius: 50)
                                                .fill(Color.black.opacity(0.4))
                                        }
                                        if scheme1 == .dark && viewModel.Pressed {
                                            RoundedRectangle(cornerRadius: 50)
                                                .fill(Color.mint.opacity(0.4))
                                                .fill(Color.black.opacity(0.8))
                                        }
                                    }
                                )
                                .frame(width: 274, height: 48)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 50)
                                        .stroke(
                                            LinearGradient(
                                                colors: viewModel.isPressed
                                                ? [.white.opacity(0.3),.white.opacity(0.2)]
                                                : [.white.opacity(0.2) ,.white.opacity(0.0) ,.white.opacity(0.0),.white.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .glassEffect(.regular.interactive())
                }
                .padding(.top, 32)
                
                Text("0 out of 2 Freezes used")
                    .font(.system(size: 14, weight: .regular))
                    .opacity(0.3)
                    .padding(.top, 12)
            }
            //Calendar Picker
            if viewModel.showPicker {
                ZStack {
                    // Background overlay (black glass effect)
                    RoundedRectangle(cornerRadius: 13)
                        .foregroundColor(.black)
                        .frame(width: 355, height: 204)
                    HStack(spacing: 0) {
                        Picker("Month", selection: $viewModel.selectedMonthIndex) {
                            ForEach(0..<viewModel.availableMonths.count, id: \.self) { index in
                                Text(viewModel.availableMonths[index])
                                    .tag(index)
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 150)
                        .clipped()
                        
                        Picker("Year", selection: $viewModel.selectedYear) {
                            ForEach(viewModel.availableYears, id: \.self) { year in
                                Text(year, format: .number.grouping(.never))
                                    .tag(year)
                                    .font(Font.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                        .clipped()
                    }
                    .frame(height: 455)
                    .transition(.scale(scale: 0.8, anchor: .top).combined(with: .opacity))
                }
            }
            // Well-Done Page
            if viewModel.showOverlay {
                ZStack {
                    VStack(spacing: 16) {
                        Image(systemName: "hands.and.sparkles.fill")
                            .symbolEffect(.bounce.up.byLayer, options: .repeat(.continuous))
                            .frame(width: 50, height: 41)
                            .font(Font.system(size: 40))
                            .foregroundColor(Color("AccentColor"))
                        Text("Well Done!")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Text("Goal completed! start learning again or set new learning goal")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(.gray).opacity(0.4))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 100)
                        Button("Set new learning goal") {
                            withAnimation {
                                viewModel.showOverlay = false
                            }
                        }
                        .font(.system(size: 17, weight: .medium))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(100)
                        Button("Set same learning goal and duration") {
                            withAnimation {
                                viewModel.showOverlay = false
                            }
                        }
                        .font(.system(size: 17, weight: .regular))
                        .padding(.horizontal, 30)
                        .padding(.vertical, 17)
                        .foregroundColor(Color("AccentColor"))
                    }
                    .padding(32)
                    .background(Color("Background"))
                    .ignoresSafeArea()
                }
                .frame(height: 550)
                .position(x:200 ,y:580 )
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
#Preview {
    MainView()
}
