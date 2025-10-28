//
//  Learning_JourneyApp.swift
//  Learning Journey
//
//  Created by Jana Abdulaziz Malibari on 16/10/2025.
//

import SwiftUI

@main
struct Learning_JourneyApp: App {
    
    @State private var isGoalSet: Bool
    
    init() {
        // Use the DataStore's own check for consistency
        _isGoalSet = State(initialValue: GoalDataStore().isGoalSet())
        print("App Init - Is Goal Set: \(isGoalSet)") // Add a print statement for debugging
    }
    
    var body: some Scene {
            WindowGroup {
                if isGoalSet {
                     MainView()
                } else {
                     ContentView(goalDidSet: {
                         isGoalSet = true // This closure will be called by ContentView/NewGoal
                     })
                }
            }
        }
    }
