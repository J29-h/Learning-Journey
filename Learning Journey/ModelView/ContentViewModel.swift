//
//  ViewModel.swift
//
//
//  Created by Jana Abdulaziz Malibari on 20/10/2025.
//

import Foundation
import SwiftUI
import Combine

class GoalSetupViewModel: ObservableObject {
    
    private let dataStore = GoalDataStore()
    
    // User inputs
    @Published var goalAmount: String = "" // Corresponds to 'goal'
    @Published var selectedPeriod: PeriodSelection? = nil // Corresponds to 'period' selection
    
    // Outputs & State
    @Published var isInputValid: Bool = false
    @Published var navigateToNextPage: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load existing goal data on initialization
        if let savedGoal = dataStore.loadGoal() {
            self.goalAmount = savedGoal.goal
            // Attempt to restore the selectedPeriod from the saved string
            self.selectedPeriod = PeriodSelection(rawValue: savedGoal.period)
        }
        
        // Validation logic remains the same
        Publishers.CombineLatest($goalAmount, $selectedPeriod)
            .map { amount, period in
                return !amount.isEmpty && period != nil
            }
            .assign(to: \.isInputValid, on: self)
            .store(in: &cancellables)
    }
    
    func saveAndContinue() {
        guard isInputValid,
              let period = selectedPeriod,
              // *** STEP 1: Look up the required details using the selection
              let details = periodDetails[period] else {
            return
        }
        
        let goalString = goalAmount // The goal amount
        let periodString = period.rawValue // e.g., "Week"
        let totalDaysInt = details.totalDays // e.g., 7
        
        // *** STEP 2: Call the save function with the requested signature
        dataStore.saveGoal(
            goal: goalString,
            period: periodString,
            days: totalDaysInt // The calculated 'days' value
        )
        
        // Signal navigation
        navigateToNextPage = true
    }
}

class ContentViewModel: ObservableObject {
    
    private let dataStore = GoalDataStore()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Inputs (Bound to the View)
    @Published var goal: String = ""               // Corresponds to the 'goalInputView' TextField
    @Published var selectedButton: String? = nil    // Corresponds to the selected button title (Week, Month, Year)
    
    // MARK: Outputs (Validation & State)
    @Published var isInputValid: Bool = false
    
    init() {
        // Load existing goal data on initialization
        if let savedGoal = dataStore.loadGoal() {
            self.goal = savedGoal.goal
            self.selectedButton = savedGoal.period
        }
        
        // Combine publisher: Checks if both inputs are present for validation
        Publishers.CombineLatest($goal, $selectedButton)
            .map { goal, period in
                // Goal must not be empty AND a period must be selected
                return !goal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && period != nil
            }
        // Assign the result to the published 'isInputValid' property
            .assign(to: \.isInputValid, on: self)
            .store(in: &cancellables)
    }
    
    // Action called by the period buttons
    func selectPeriod(_ title: String) {
        self.selectedButton = title
    }
    
    // Action called by the "Start learning" button
    func saveUserGoal() {
        // Final validation
        guard isInputValid,
              let periodString = selectedButton,
              let periodEnum = PeriodSelection(rawValue: periodString),
              // Use the lookup table to get the details
              let details = periodDetails[periodEnum] else {
            return
        }
        
        // Save the data to UserDefaults
        dataStore.saveGoal(
            goal: goal,
            period: periodString,
            days: details.totalDays
        )
        
        // Optional: Print saved data for debugging
        print("Goal Saved: \(goal), Period: \(periodString), Days: \(details.totalDays), Freeze Days: \(details.freezeDays)")
    }
}

final class StreakTracker: ObservableObject {
    @Published private(set) var streakData: StreakData = .empty()
    
    
    private(set) var totalFreezes: Int = 2
    
    private let calendar = Calendar.current
    private let userDefaultsKey = "streakData"
    
    var currentDate: Date { Date() }
    
    init() {
        loadData()
        loadTotalFreezesFromGoal()
        checkDateLogic()
    }
    
    func logLearned(for date: Date) -> Bool {
        // Check if already learned or frozen for this specific date
        guard getStatus(for: date) == .normal || getStatus(for: date) == .freezed else { return false }
        
        let wasFrozen = getStatus(for: date) == .freezed
        if wasFrozen {
            // Remove from freeze history and decrement count
            streakData.freezedHistory.removeAll { calendar.isDate($0, inSameDayAs: date) }
            streakData.freezesUsed = max(0, streakData.freezesUsed - 1)
        }
        
        // Add to learned history if not already there for this day
        if !isDayLearned(date) {
            streakData.learnedHistory.append(date)
        }
        
        
        // Update streak logic *only if* this action is for TODAY's date
        if calendar.isDateInToday(date) {
            let shouldIncrementStreak: Bool
            if let lastDate = streakData.lastActionDate {
                if streakData.lastActionType == .freezed {
                    shouldIncrementStreak = true // Always continue after freeze
                } else {
                    let timeIntervalSinceLast = currentDate.timeIntervalSince(lastDate)
                    shouldIncrementStreak = timeIntervalSinceLast <= (32 * 60 * 60) // 32 hours rule
                }
                
                if shouldIncrementStreak {
                    // Increment only if last action wasn't learned today, or was freeze/nil
                    if streakData.lastActionType != .learned || !calendar.isDateInToday(lastDate) {
                        streakData.streak += 1
                    }
                }
                // Reset is handled by checkStreakLogic
            } else {
                streakData.streak = 1 // First ever log
            }
            
            streakData.lastActionType = .learned
            streakData.lastActionDate = currentDate // Use actual time for last action check
        }
        
        saveData()
        return true
    }
    func logFreeze(for date: Date) -> Bool {
        guard getStatus(for: date) == .normal else { return false } // Can't freeze if already learned/frozen
        guard freezesRemaining > 0 else { return false }
        
        streakData.freezesUsed += 1
        // Add to freezed history if not already there (shouldn't be due to guard)
        if !isDayFreezed(date) {
            streakData.freezedHistory.append(date)
        }
        
        // Update last action type/date *only if* this action is for TODAY's date
        if calendar.isDateInToday(date) {
            streakData.lastActionType = .freezed
            streakData.lastActionDate = currentDate // Use actual time
        }
        
        saveData()
        return true
    }
    
    var freezesRemaining: Int { max(0, totalFreezes - streakData.freezesUsed) }
    var currentStreak: Int { streakData.streak } // Keep for MainLogic compatibility if needed
    var currentFreezesUsed: Int { streakData.freezesUsed } // Keep for MainLogic compatibility
    
    func getStatus(for date: Date) -> StreakData.DayStatus {
        if isDayLearned(date) { return .learned }
        if isDayFreezed(date) { return .freezed }
        return .normal
    }
    
    private func checkHourLogic() {
        guard let lastDate = streakData.lastActionDate else { return }
        guard streakData.lastActionType == .learned else { return } // Only check against last learned
        let timeIntervalSinceLast = currentDate.timeIntervalSince(lastDate)
        let thirtyTwoHoursInSeconds: TimeInterval = 32 * 60 * 60
        if timeIntervalSinceLast > thirtyTwoHoursInSeconds {
            streakData.streak = 0
            // Avoid saving on init check
        }
    }
    
    private func checkDateLogic() {
        guard let lastDate = streakData.lastActionDate else { return }
        if !calendar.isDateInYesterday(lastDate) && !calendar.isDateInToday(lastDate) {
            if streakData.lastActionType != .freezed {
                streakData.streak = 0
            }
        }
    }
    
    private func checkStreakLogic() {
        checkHourLogic() // Use the 32-hour rule
        
    }
    
    var isActionTakenToday: Bool {
        guard let lastDate = streakData.lastActionDate else { return false }
        return calendar.isDateInToday(lastDate)
    }
    var hasLoggedToday: Bool {
        isActionTakenToday && streakData.lastActionType == .learned
    }
    var hasFrozenToday: Bool {
        isActionTakenToday && streakData.lastActionType == .freezed
    }
    func isDayLearned(_ date: Date) -> Bool {
        streakData.learnedHistory.contains { historyDate in
            calendar.isDate(date, inSameDayAs: historyDate)
        }
    }
    func isDayFreezed(_ date: Date) -> Bool {
        streakData.freezedHistory.contains { historyDate in
            calendar.isDate(date, inSameDayAs: historyDate)
        }
    }
    
    private func saveData() {
        objectWillChange.send()
        if let encodedData = try? JSONEncoder().encode(streakData) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        }
    }
    
    private func loadData() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedData = try? JSONDecoder().decode(StreakData.self, from: savedData) {
            // Ensure loaded arrays are not nil, provide empty if decoding somehow fails partially
            self.streakData = decodedData
            if self.streakData.learnedHistory == nil { self.streakData.learnedHistory = [] }
            if self.streakData.freezedHistory == nil { self.streakData.freezedHistory = [] }
        } else {
            self.streakData = .empty()
        }
    }
    
    private func loadTotalFreezesFromGoal() {
        // Use the updated GoalDataStore definition below
        let goalDataStore = GoalDataStore()
        // Use the updated LearningGoal struct name below
        if let savedGoal = goalDataStore.loadGoal(),
           // Use PeriodSelection below
           let periodEnum = PeriodSelection(rawValue: savedGoal.period),
           // Use periodDetails below
           let details = periodDetails[periodEnum] {
            self.totalFreezes = details.freezeDays
            print("Loaded total freezes: \(self.totalFreezes) for period \(savedGoal.period)")
        } else {
            self.totalFreezes = 2
            print("Could not load goal period, defaulting total freezes to \(self.totalFreezes)")
        }
        objectWillChange.send()
    }
    
    /// Resets all streak data.
    func resetAllData() {
        self.streakData = .empty()
        loadTotalFreezesFromGoal()
        saveData()
        print("Reset all data and reloaded total freezes: \(totalFreezes)")
    }
    
}

extension Date {
    /// Converts a Date into a "yyyy-MM-dd" string key for use in dictionaries.
    func toKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd" // Consistent date format
        return formatter.string(from: self)
    }
}

enum DateStatus {
    case normal
    case selected
    case learned
    case freezed
}

final class MainLogic: ObservableObject {
    
    @Published var selectedDate: Date = Date()
    @Published var currentWeek: [Date] = []
    @Published var showPicker = false
    @Published var selectedMonthIndex: Int = 0
    @Published var selectedYear: Int = 0
    
    
    private let calendar: Calendar = {
        var cal = Calendar.current
        cal.locale = Locale.current
        cal.timeZone = TimeZone.current
        return cal
    }()
    
    private(set) var streakTracker = StreakTracker()
    
    @Published var daysLearned: Int = 0
    @Published var daysFreezed: Int = 0
    @Published var totalFreezesAllowed: Int = 0
    @Published var isActionTakenToday: Bool = false
    @Published var hasLoggedToday: Bool = false
    @Published var hasFrozenToday: Bool = false
    
    private var goalTargetDays: Int = 0
    @Published var navigateToSetup = false
    
//    private var calendar = Calendar.current
    private let monthFormatter = DateFormatter()
    private let yearFormatter = DateFormatter()
    private let weekdayFormatter = DateFormatter()
    private let dayFormatter = DateFormatter()
    
    let availableMonths = Calendar.current.monthSymbols
    let availableYears = Array(2000...(Calendar.current.component(.year, from: Date()) + 5))
    @Published var showOverlay = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // --- Initialization ---
    init() {
                let now = Date()
        
        monthFormatter.dateFormat = "LLLL"
        yearFormatter.dateFormat = "yyyy"
        weekdayFormatter.dateFormat = "EEE"  // or "EEEE" for full names
        weekdayFormatter.locale = Locale.current
        monthFormatter.locale = Locale.current
        yearFormatter.locale = Locale.current
                
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

    // --- Observe system day changes ---
    private func observeMidnightChange() {
        // Checks every minute if day changed
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                let today = self.calendar.startOfDay(for: Date())
                if !self.calendar.isDate(self.selectedDate, inSameDayAs: today) {
                    self.selectedDate = today
                    self.updateCurrentWeek(basedOn: today)
                    self.syncPickerToSelectedDate()
                }
            }
            .store(in: &cancellables)
    }
    
    // --- Combine Pipeline ---
    private func setupBindings() {
        streakTracker.objectWillChange
            .sink { [weak self] _ in self?.updateStateFromTracker() }
            .store(in: &cancellables)
    }
    // --- Load Goal Target ---
    private func loadGoalTarget() {
        let goalDataStore = GoalDataStore()
        if let savedGoal = goalDataStore.loadGoal() {
            goalTargetDays = savedGoal.days
        } else {
            goalTargetDays = 2
        }
    }
    
    func updateStateFromTracker() {
        daysLearned = streakTracker.streakData.streak
        daysFreezed = streakTracker.streakData.freezesUsed
        totalFreezesAllowed = streakTracker.totalFreezes
        
        let todayStatus = streakTracker.getStatus(for: Date())
        isActionTakenToday = (todayStatus == .learned || todayStatus == .freezed)
        hasLoggedToday = (todayStatus == .learned)
        hasFrozenToday = (todayStatus == .freezed)
    }
    
    var currentMonthName: String { monthFormatter.string(from: selectedDate) }
    var currentYearString: String { yearFormatter.string(from: selectedDate) }
    
    func updateCurrentWeek(basedOn date: Date) { currentWeek = generateWeek(for: date) }
    
    func generateWeek(for date: Date) -> [Date] {
        let today = calendar.startOfDay(for: date)
        if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) {
            let startOfWeek = weekInterval.start
            return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
        }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
    }
    
    func weekdayString(from date: Date) -> String { weekdayFormatter.string(from: date) }
    func dayNumber(from date: Date) -> Int { calendar.component(.day, from: date) }
    func select(date: Date) { selectedDate = date }
    
    func togglePicker() { showPicker.toggle() }
    
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
    

            
    func isSelected(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
    
    func dayNumber(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    func syncPickerToSelectedDate() {
        selectedYear = calendar.component(.year, from: selectedDate)
        selectedMonthIndex = calendar.component(.month, from: selectedDate) - 1
    }
    
    
    // --- Buttons ---
    func logLearned() {
        if streakTracker.logLearned(for: Date()) { print("Logged learned for TODAY") }
        else { print("Could not log learned for TODAY") } }
    
    func logFreeze() {
        if streakTracker.logFreeze(for: Date()) { print("Logged freeze for TODAY") }
        else { print("Could not log freeze for TODAY") }
    }
    
    // --- Button State Logic ---
    var logButtonText: String {
        let todayStatus = streakTracker.getStatus(for: Date())
        if todayStatus == .freezed { return "Day\nFreezed" }
        else if todayStatus == .learned { return "Learned\nToday" }
        else { return "Log as \nLearned" }
    }
    var freezeButtonText: String { streakTracker.getStatus(for: Date()) == .freezed ? "Freezed" : "Log as Freezed" }
    
    func logButtonForegroundColor(scheme: ColorScheme) -> Color {
        let todayStatus = streakTracker.getStatus(for: Date())
        if todayStatus == .freezed { return Color("Freeze") }
        else if todayStatus == .learned { return Color("AccentColor") }
        else { return Color("MainText") }
    }
    func logButtonFillColor(scheme: ColorScheme) -> Color {
        let todayStatus = streakTracker.getStatus(for: Date())
        if todayStatus == .freezed {
            return scheme == .dark ? Color.black : Color(red: 27/255, green: 63/255, blue: 74/255)
        } else if todayStatus == .learned {
            return Color("Icon")
        } else {
            return scheme == .dark ? Color(red: 0.70, green: 0.25, blue: 0.0) : Color("AccentColor")
        }
    }
    func freezeButtonFillColor(scheme: ColorScheme) -> Color {
        streakTracker.getStatus(for: Date()) == .freezed ? Color("Freezed") : Color("Freeze")
    }
    var canFreeze: Bool { streakTracker.freezesRemaining > 0 && streakTracker.getStatus(for: Date()) == .normal }
    var isFreezeButtonDisabled: Bool { !canFreeze }
    var canLogAction: Bool { streakTracker.getStatus(for: Date()) == .normal }
    
    // --- Text Labels ---
    var daysLearnedLabel: String { daysLearned == 1 ? "Day Learned" : "Days Learned" }
    var daysFreezedLabel: String { daysFreezed == 1 ? "Day Freezed" : "Days Freezed" }
    
    var freezesRemainingText: String {
        let remaining = streakTracker.freezesRemaining
        let total = totalFreezesAllowed
        return "\(max(0, remaining)) Freezes remains"
    }
    
    // --- Well Done Overlay Actions ---
    
    @MainActor
    func resetGoalAndOpenSetup() {
        // 1. Reset all persistent streak data (streak, freezes used, history)
        // streakTracker.resetAllData()
        
        // 2. Clear the goal data from UserDefaults entirely
        // GoalDataStore().clearGoalData()
        
        // 3. Signal app to navigate to ContentView
        navigateToSetup = true
        showOverlay = false
    }
    
    func continueSameGoal() {
        // 1. Reset only streak count and freezes used (Goal and limit remain)
        // streakTracker.resetStreakOnly()
        
        // 2. Hide overlay
        showOverlay = false
    }
    
    
    // --- Calendar Day Styling ---
    func getDayStatus(for date: Date) -> StreakData.DayStatus { streakTracker.getStatus(for: date) }
    func dayFillColor(for date: Date, scheme: ColorScheme = .light) -> Color {
        let status = getDayStatus(for: date)
        if isSelected(date) { return Color("AccentColor") }
        switch status {
        case .learned: return Color("Icon")
        case .freezed: return Color("Freeze")
        case .normal: return Color.clear
        }
    }
    func dayForegroundColor(for date: Date, scheme: ColorScheme = .light) -> Color {
        let status = getDayStatus(for: date)
        if isSelected(date) { return .white }
        switch status {
        case .learned, .freezed: return .white
        case .normal: return Color("MainText")
        }
    }
}


final class CalendarViewModel: ObservableObject {
    
    // --- Calendar Generation ---
    @Published var months: [Date] = []
    @Published var currentMonthIndex: Int = 0
    
    private let calendar = Calendar.current
    
    // --- Streak Data Integration ---
    // Inject or initialize the StreakTracker
    // For simplicity, we initialize it directly here. Use Dependency Injection in a real app.
    private let streakTracker = StreakTracker() // <<< ADDED STREAK TRACKER INSTANCE
    
    init() {
        generateMonths()
        scrollToCurrentMonth()
    }
    
    private func generateMonths() {
        let currentDate = Date()
        // Use a more reasonable range, e.g., 1 year back and 1 year forward
        guard
            let startDate = calendar.date(byAdding: .year, value: -1, to: currentDate), // Changed range
            let endDate = calendar.date(byAdding: .year, value: 1, to: currentDate) // Changed range
        else { return }
        
        var date = startDate
        var allMonths: [Date] = []
        // Ensure we get the first day of each month for consistency
        guard let firstDayOfStartDate = calendar.date(from: calendar.dateComponents([.year, .month], from: startDate)) else { return }
        date = firstDayOfStartDate
        
        while date <= endDate {
            allMonths.append(date)
            // Safely get the next month
            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: date) else { break }
            date = nextMonth
        }
        self.months = allMonths
    }
    
    private func scrollToCurrentMonth() {
        if let index = months.firstIndex(where: { calendar.isDate($0, equalTo: Date(), toGranularity: .month) }) {
            currentMonthIndex = index
        }
    }
    
    // --- UPDATED daysInMonth to handle grid alignment ---
    func daysInMonth(for monthDate: Date) -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: monthDate) else {
            // Handle case where interval can't be calculated (shouldn't happen for valid dates)
            print("Error: Could not calculate month interval for \(monthDate)")
            return []
        }
        // Directly use the non-optional start date
        let firstDayOfMonth = monthInterval.start
        // FIXED: Removed 'let' as .component returns Int, not Int?
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        
        var displayDays: [Date?] = []
        
        let leadingEmptyDays = (firstWeekday - calendar.firstWeekday + 7) % 7
        for _ in 0..<leadingEmptyDays {
            displayDays.append(nil)
        }
        
        var currentDate = firstDayOfMonth
        while currentDate < monthInterval.end {
            displayDays.append(currentDate)
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDay
        }
        
        return displayDays
    }
    
    func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    // --- UPDATED dayString to handle optional Date ---
    /// Returns the day number as a string (e.g., "28"). Returns empty for nil dates.
    func dayString(for date: Date?) -> String {
        guard let date = date else { return "" } // Return empty string for nil
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    // --- UPDATED isToday to handle optional Date ---
    /// Checks if a given date is today.
    func isToday(_ date: Date?) -> Bool {
        guard let date = date else { return false } // Nil date is not today
        return calendar.isDateInToday(date)
    }
    
    func dayOfWeekHeaders() -> [String] {
        // Use veryShortWeekdaySymbols for consistency with MainView
        return calendar.veryShortWeekdaySymbols
        // return ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"] // Or your preference
    }
    
    // --- ADDED Streak Styling Functions ---
    
    /// Determines the background fill color for a calendar day cell.
    func dayBackgroundColor(for date: Date?, scheme: ColorScheme) -> Color {
        guard let date = date else { return .clear } // Empty cell
        
        let status = streakTracker.getStatus(for: date)
        
        switch status {
        case .learned:
            return Color("Icon") // Use asset name
        case .freezed:
            return Color(red: 27/255, green: 63/255, blue: 74/255)
        case .normal:
            // Optional: Highlight today differently if it's a normal day
            // return isToday(date) ? Color.gray.opacity(0.3) : .clear
            return .clear // Default clear background for normal days
        }
    }
    
    /// Determines the text color for a calendar day cell.
    func dayForegroundColor(for date: Date?, scheme: ColorScheme) -> Color {
        guard let date = date else { return .clear } // Empty cell
        
        let status = streakTracker.getStatus(for: date)
        
        if isToday(date) && status == .normal {
            // Make today stand out if not logged/frozen
            return Color("AccentColor") // Use asset name
        } else if status == .learned || status == .freezed {
            // Logged or frozen days use white text for contrast
            return .white
        } else {
            // Default text color for normal days
            return Color("MainText") // Use asset name
        }
    }
}

final class NewGoalViewModel: ObservableObject {
    
    // --- Dependencies ---
    private let goalDataStore = GoalDataStore()
    // Need access to StreakTracker to reset it
    // Assuming StreakTracker is accessible globally or injected.
    // For simplicity, creating a new instance here, but ideally share it.
    private let streakTracker = StreakTracker()
    
    // --- State for the View ---
    @Published var goal: String = ""
    @Published var selectedButton: String? = nil // Tracks the selected period button title (e.g., "Week")
    
    // Validation
    @Published var isInputValid: Bool = false
    @Published var hasChanges: Bool = false // Tracks if user actually changed something
    
    // Alert State
    @Published var showingConfirmationAlert = false
    
    // Navigation State (Optional - better to dismiss)
    @Published var didUpdateGoal = false // Signal to dismiss the view
    
    private var initialGoal: String = ""
    private var initialPeriod: String? = nil
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadExistingGoal()
        setupValidationAndChangeTracking()
    }
    
    /// Loads the currently saved goal, if any.
    private func loadExistingGoal() {
        if let existingGoalData = goalDataStore.loadGoal() {
            goal = existingGoalData.goal
            selectedButton = existingGoalData.period
            
            // Store initial values to detect changes
            initialGoal = existingGoalData.goal
            initialPeriod = existingGoalData.period
        }
    }
    
    /// Sets up Combine pipelines for validation and change detection.
    private func setupValidationAndChangeTracking() {
        // Validation logic (Goal not empty, Period selected)
        let validationPublisher = Publishers.CombineLatest($goal, $selectedButton)
            .map { goalText, selectedPeriodTitle in
                return !goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedPeriodTitle != nil
            }
            .share() // Share the result to avoid recomputing
        
        validationPublisher
            .assign(to: \.isInputValid, on: self)
            .store(in: &cancellables)
        
        // Change tracking logic (Compare current input to initial values)
        let changePublisher = Publishers.CombineLatest($goal, $selectedButton)
            .map { [weak self] currentGoal, currentPeriod in
                guard let self = self else { return false }
                let goalChanged = currentGoal != self.initialGoal
                let periodChanged = currentPeriod != self.initialPeriod
                return goalChanged || periodChanged
            }
            .share() // Share the result
        
        changePublisher
            .assign(to: \.hasChanges, on: self)
            .store(in: &cancellables)
        
        // Combine validation and change status (just to keep pipeline alive)
        Publishers.CombineLatest(validationPublisher, changePublisher)
            .map { isValid, hasChanged in
                // We don't need the result directly, but map is needed before sink
                return isValid && hasChanged
            }
        // Use .sink to consume the value and get an AnyCancellable, then store it.
            .sink { _ in
                // Do nothing with the combined value, just keep the subscription active
            }
            .store(in: &cancellables) // Store the cancellable returned by sink
    }
    
    /// Called by the View when a period button is tapped.
    func selectPeriod(_ title: String) {
        selectedButton = title
    }
    
    /// Called by the View's save button. Triggers the confirmation alert.
    func requestUpdateConfirmation() {
        guard isInputValid, hasChanges else { return } // Only show if valid and changed
        showingConfirmationAlert = true
    }
    
    /// Called when the user confirms the update in the alert.
    func confirmUpdateGoal() {
        guard let selectedPeriodTitle = selectedButton,
              let periodEnum = PeriodSelection(rawValue: selectedPeriodTitle),
              let details = periodDetails[periodEnum] else {
            print("Error: Cannot update goal. Period details missing.")
            return
        }
        
        let goalToSave = goal.trimmingCharacters(in: .whitespacesAndNewlines)
        let daysToSave = details.totalDays
        
        // 1. Save the new goal data
        goalDataStore.saveGoal(goal: goalToSave, period: selectedPeriodTitle, days: daysToSave)
        print("Goal Updated: \(goalToSave), Period: \(selectedPeriodTitle), Days: \(daysToSave)")
        
        // 2. Reset the streak data
        streakTracker.resetAllData()
        print("Streak data reset.")
        
        // 3. Signal that the update is done (for navigation/dismissal)
        didUpdateGoal = true
    }
}



