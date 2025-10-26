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
    @Published var selectedButton: String? = "" // default
    @Published var streakGoal: Int = 0   // <-- add this
    @Published var currentStreak: Int = 0
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
        UserDefaults.standard.set(goal, forKey: "userGoal")
        UserDefaults.standard.set(streakGoal, forKey: "streakGoal")
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
    @Published var selectedDate: Date = Date()
    @Published var showPicker: Bool = false
    @Published var isPressed: Bool = false
    @Published var Pressed: Bool = false
    
    @Published var selectedMonthIndex: Int
    @Published var selectedYear: Int
    
    @Published var currentWeek: [Date] = []
    
    @Published var showOverlay: Bool = false
    @Published var currentStreak = 0

    
    private let calendar = Calendar.current
    private var cancellables = Set<AnyCancellable>()
    
    
    let availableMonths: [String] = {
            let formatter = DateFormatter()
            return formatter.monthSymbols.map { $0.capitalized }
        }()
    
    func logDayLearned() {
            currentStreak += 1
        }
    
    var availableYears: [Int] {
           let currentYear = calendar.component(.year, from: Date())
           // Adjusted range for pickers (20 years before/after).
           return Array((currentYear - 20)...(currentYear + 20))
       }
    
    var currentMonthName: String {
           let formatter = DateFormatter()
           formatter.dateFormat = "LLLL"
           return formatter.string(from: selectedDate).capitalized
       }
    
    var currentYearString: String {
            return String(calendar.component(.year, from: selectedDate))
        }
    
    init() {
            let now = Date()
            
            let initialMonthIndex = calendar.component(.month, from: now) - 1
            let initialYear = calendar.component(.year, from: now)
            
            _selectedMonthIndex = Published(initialValue: initialMonthIndex)
            _selectedYear = Published(initialValue: initialYear)
            
            updateCurrentWeek()
            
            Publishers.CombineLatest($selectedMonthIndex, $selectedYear)
                .dropFirst()
                .sink { [weak self] monthIndex, year in
                    self?.updateDateFromPickers(monthIndex: monthIndex, year: year)
                }
                .store(in: &cancellables)
        }
    
    func togglePicker() {
            if !showPicker {
                selectedMonthIndex = calendar.component(.month, from: selectedDate) - 1
                selectedYear = calendar.component(.year, from: selectedDate)
            }
            showPicker.toggle()
        }
    
    private func updateDateFromPickers(monthIndex: Int, year: Int) {
            let currentDay = calendar.component(.day, from: selectedDate)
            var components = DateComponents(year: year, month: monthIndex + 1)
            
            guard let newMonthDate = calendar.date(from: components),
                  let range = calendar.range(of: .day, in: .month, for: newMonthDate) else {
                return
            }
            
            components.day = min(currentDay, range.count)
            
            if let newDate = calendar.date(from: components) {
                selectedDate = newDate
                updateCurrentWeek()
            }
        }
    
    func updateCurrentWeek() {
            guard let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: selectedDate) else { return }
            
            currentWeek = (0..<7).compactMap {
                calendar.date(byAdding: .day, value: $0, to: weekInterval.start)
            }
            
            selectedMonthIndex = calendar.component(.month, from: selectedDate) - 1
            selectedYear = calendar.component(.year, from: selectedDate)
        }
        
        func nextWeek() {
            guard let next = calendar.date(byAdding: .day, value: 7, to: selectedDate) else { return }
            selectedDate = next
            updateCurrentWeek()
        }
        
        func previousWeek() {
            guard let prev = calendar.date(byAdding: .day, value: -7, to: selectedDate) else { return }
            selectedDate = prev
            updateCurrentWeek()
        }
    
    func select(date: Date) {
            selectedDate = date
        }
        
        func isSelected(_ date: Date) -> Bool {
            Calendar.current.isDate(date, inSameDayAs: selectedDate)
        }
        
        func weekdayString(from date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            return formatter.string(from: date).uppercased()
        }
        
        func dayNumber(from date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "d"
            return formatter.string(from: date)
        }
    
    func press() {
        if !isPressed {
            isPressed = true
        }
    }
    func FreezePress() {
        if !Pressed {
            Pressed = true
        }
    }
}

class CalendarViewModel: ObservableObject {
    @Published var months: [Date] = []
    @Published var currentMonthIndex: Int = 0
    
    private let calendar = Calendar.current
    
    init() {
        generateMonths()
        scrollToCurrentMonth()
    }
    
    private func generateMonths() {
        let currentDate = Date()
        guard
            let startDate = calendar.date(byAdding: .year, value: -100, to: currentDate),
            let endDate = calendar.date(byAdding: .year, value: 100, to: currentDate)
        else { return }
        
        var date = startDate
        var allMonths: [Date] = []
        while date <= endDate {
            allMonths.append(date)
            date = calendar.date(byAdding: .month, value: 1, to: date)!
        }
        self.months = allMonths
    }
    
    private func scrollToCurrentMonth() {
        if let index = months.firstIndex(where: { calendar.isDate($0, equalTo: Date(), toGranularity: .month) }) {
            currentMonthIndex = index
        }
    }
    
    func daysInMonth(for date: Date) -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }
        return range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: firstDay) }
    }
    
    func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    func dayString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    func dayOfWeekHeaders() -> [String] {
        ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    }
}
