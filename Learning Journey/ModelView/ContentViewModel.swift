//
//  ViewModel.swift
//
//
//  Created by Jana Abdulaziz Malibari on 20/10/2025.
//

import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
    @Published var goal: String = ""
    @Published var selectedButton: String? = "Week" // default
    @Published var periodDays: [String: Int] = [
        "Week": 7,
        "Month": 30,
        "Year": 365
    ]
    
    // Computed property for easy access
    var selectedDays: Int {
        guard let selected = selectedButton else { return 0 }
        return periodDays[selected] ?? 0
    }
    
    func saveUserGoal() {
        guard !goal.isEmpty, let selected = selectedButton else {
            print("⚠️ Please fill in the goal and select a period.")
            return
        }
        
        let userGoal = LearningGoal(goal: goal, period: selected, days: selectedDays)
        
        // Save to UserDefaults
        let dict: [String: Any] = [
            "goal": userGoal.goal,
            "period": userGoal.period,
            "days": userGoal.days
        ]
        UserDefaults.standard.set(dict, forKey: "userLearningGoal")
        print("✅ Goal saved: \(dict)")
    }
    
    func selectPeriod(_ period: String) {
        selectedButton = period
    }
}

class MainPageViewModel: ObservableObject {
    @Published var showCalendar: Bool = false
    @Published var selectedDate: Date = Date()
    @Published var isPressed = false
    
    private let calendar = Calendar.current
    
    @Published var currentWeek: [Date] = []
    
    init() {
        updateCurrentWeek()
    }
    
    func updateCurrentWeek(from referenceDate: Date = Date()) {
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: referenceDate)?.start else { return }
        currentWeek = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    func select(date: Date) {
        selectedDate = date
    }
    
    func isSelected(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
    func weekdayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // Mon, Tue, etc.
        return formatter.string(from: date)
    }
    
    func dayNumber(from date: Date) -> Int {
        calendar.component(.day, from: date)
    }
    
    func press() {
        if !isPressed {
            isPressed = true
        }
    }
}
