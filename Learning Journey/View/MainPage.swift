//
//  SwiftUIView.swift
//  Learning Journey
//
//  Created by Jana Abdulaziz Malibari on 20/10/2025.
//

import SwiftUI
import UIKit

struct MainPage: View {
    
    @StateObject private var viewModel = MainPageViewModel()
    @Environment(\.colorScheme) var scheme
    @State private var isPressed = false
    @State private var Day = 0
    let calendar = Calendar.current
    
    
    var body: some View {
        ZStack(alignment: .top) {
            Color("Background").edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center) {
                HStack {
                    Text("Activity")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color("MainText"))
                    //                        .padding(.leading, 15)
                    
                    Spacer()
                    
                    Button(action: {
                        
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
                    
                    Button(action: {
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
                }
                .padding(.leading, 10)
                .padding(.trailing, 10)
                
                ZStack(alignment: .center){
                    RoundedRectangle(cornerRadius: 13)
                        .frame(width: 365, height: 254)
                        .foregroundColor(.black.opacity(0.1))
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
                    VStack(alignment: .leading, spacing: 12){
                        HStack(spacing: 5) {
                            ForEach(viewModel.currentWeek, id: \.self) { date in
                                Button(action: {
                                    viewModel.select(date: date)
                                }) {
                                    VStack {
                                        Text(viewModel.weekdayString(from: date))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text("\(viewModel.dayNumber(from: date))")
                                            .font(.headline)
                                            .foregroundColor(viewModel.isSelected(date) ? .white : .primary)
                                            .frame(width: 44, height: 44)
                                            .background(
                                                Circle()
                                                    .fill(viewModel.isSelected(date) ? Color.accentColor : Color.clear)
                                            )
                                    }
                                }
                            }
                        }
                        
                        Text("Learning Activity")
                            .font(Font.system(size: 16, weight: .semibold))
                        HStack(alignment: .center, spacing: 13){
                            ZStack(alignment: .center){
                                RoundedRectangle(cornerRadius: 34)
                                    .frame(width: 160, height: 69)
                                    .foregroundColor(Color("Icon"))
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
                                
                            }
                            ZStack(alignment: .center){
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
                            }
                        }
                    }
                }
                .padding(.top, 24)
                .padding(.bottom,32)
                
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
                                .overlay(
                                    Group {
                                        if scheme == .dark && viewModel.isPressed {
                                            Circle()
                                                .fill(Color.black.opacity(0.9))
                                        }
                                    }
                                )
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: viewModel.isPressed
                                                ? [.white.opacity(0.3), .brown.opacity(0.3), .clear.opacity(0.9), .red.opacity(0.2)]
                                                : [.white.opacity(0.6) ,.red.opacity(0.3), .orange.opacity(0.9)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .glassEffect(.regular.interactive())
                }
            }
            .animation(.easeInOut, value: viewModel.showCalendar)
        }
    }
}
#Preview {
    MainPage()
}

// Calendar popup
//                if viewModel.showCalendar {
//                    DatePicker(
//                        "",
//                        selection: $viewModel.selectedDate,
//                        displayedComponents: [.date]
//                    )
//                    .datePickerStyle(.graphical)
//                    .padding()
//                    .background(Color(.systemBackground))
//                    .cornerRadius(12)
//                    .shadow(radius: 5)
//                    .transition(.move(edge: .top))
//                }
