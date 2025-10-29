//
//  Model.swift
//  
//
//  Created by Jana Abdulaziz Malibari on 20/10/2025.
//

import Foundation
import Combine

struct LearningGoal {
    var goal: String
    var period: String
    var days: Int
}

enum PeriodSelection: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

// Data structure to hold the specific days logic
struct PeriodDetail {
    let totalDays: Int
    let freezeDays: Int
}

let periodDetails: [PeriodSelection: PeriodDetail] = [
    .week:  PeriodDetail(totalDays: 1,   freezeDays: 2),
    .month: PeriodDetail(totalDays: 30,  freezeDays: 8),
    .year:  PeriodDetail(totalDays: 365, freezeDays: 96)
]

class GoalDataStore {
    private let defaults = UserDefaults.standard
    private let goalKey = "SavedGoalTopic"
    private let periodKey = "SavedPeriodString"
    private let daysKey = "SavedTotalDays"
    
    
    // Saves the data using the requested signature: goal: String, period: String, days: Int
    func saveGoal(goal: String, period: String, days: Int) {
        defaults.set(goal, forKey: goalKey)
        defaults.set(period, forKey: periodKey)
        defaults.set(days, forKey: daysKey)
    }
    
    func loadGoal() -> LearningGoal? {
        guard let goal = defaults.string(forKey: goalKey),
              let period = defaults.string(forKey: periodKey) else {
            return nil
        }
        let days = defaults.integer(forKey: daysKey)
        if !goal.isEmpty && !period.isEmpty && days > 0 { // Match user's check
            return LearningGoal(goal: goal, period: period, days: days)
        }
        return nil
    }
    
    func isGoalSet() -> Bool {
        // Use updated keys
        return defaults.object(forKey: goalKey) != nil &&
        defaults.object(forKey: periodKey) != nil &&
        defaults.object(forKey: daysKey) != nil
    }
    
    func clearGoalData() {
            defaults.removeObject(forKey: goalKey)
            defaults.removeObject(forKey: periodKey)
            defaults.removeObject(forKey: daysKey)
            // Ensure you also clear the streak data to be thorough
            UserDefaults.standard.removeObject(forKey: "streakData")
        }
}

struct StreakData: Codable {
    var streak: Int
    var freezesUsed: Int
    var lastActionDate: Date?
    var lastActionType: DayStatus
    
    var learnedHistory: [Date]
    var freezedHistory: [Date]
    
    enum DayStatus: String, Codable {
        case normal
        case learned
        case freezed
    }
    
    static func empty() -> StreakData {
        StreakData(
            streak: 0,
            freezesUsed: 0,
            lastActionDate: nil,
            lastActionType: .normal,
            learnedHistory: [],
            freezedHistory: []
        )
    }
}




