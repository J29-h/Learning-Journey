//
//  ViewModel.swift
//  
//
//  Created by Jana Abdulaziz Malibari on 20/10/2025.
//

import SwiftUI
import Combine

class ViewModel: ObservableObject {
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

#Preview {
    ViewModel()
}
