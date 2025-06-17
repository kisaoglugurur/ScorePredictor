//
//  ContentView.swift
//  ScorePredictor
//
//  Created by Gurur on 17.06.2025.
//

import CoreML
import SwiftUI

struct ContentView: View {
    // State variables to hold user input
    @State private var studyHours: Double = 10.0
    @State private var attendanceRate: Double = 75
    @State private var previousScore: String = "80"
    @State private var participationIndex: Int = 1 // Index for "Medium"
    @State private var sleepHours = 7.0
    
    // For the Picker
    let participationLevels: [String] = ["Low", "Medium", "High"]
    
    // To hold the prediction result
    @State private var predictedScore: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Student Information") {
                    // Slider for study hours
                    VStack {
                        Text("Study Hours: \(studyHours, specifier: "%.1f")")
                        Slider(value: $studyHours, in: 0...30, step: 0.5)
                    }
                    
                    // Slider for attendance rate
                    VStack {
                        Text("Attendance Rate: \(attendanceRate, specifier: "%.0f")%")
                        Slider(value: $attendanceRate, in: 0...100, step: 1)
                    }
                    
                    // TextField for previous score
                    TextField("Previous Exam Score", text: $previousScore)
                        .keyboardType(.decimalPad)
                    
                    // Picker for Participation Level
                    Picker("Participation Level", selection: $participationIndex) {
                        ForEach(participationLevels.indices, id: \.self) { index in
                            Text(self.participationLevels[index])
                        }
                    }

                    // Slider for Sleep Hours
                    VStack {
                        Text("Sleep Hours: \(sleepHours, specifier: "%.1f")")
                        Slider(value: $sleepHours, in: 4...10, step: 0.5)
                    }
                }
                
                Section {
                    Button(action: predict) {
                        Text("Predict Final Score")
                    }
                }
                
                if !predictedScore.isEmpty {
                    Section("Result") {
                        Text("Predicted Final Score: \(predictedScore)")
                    }
                }
            }
            .navigationTitle("Score Predictor")
        }
    }
    
    func predict() {
        // 1. Validate and get input
        guard let previousScoreDouble = Double(previousScore) else {
            predictedScore = "Invalid Score"
            return
        }
        let participation = participationLevels[participationIndex]
        
        // 2. Create the model instance
        do {
            let config = MLModelConfiguration()
            let model = try StudentScorePredictor(configuration: config)
            
            let prediction = try model.prediction( // Make the prediction
                    study_hours: studyHours,
                    attendance_rate: attendanceRate,
                    previous_scores: previousScoreDouble,
                    participation_level: participation,
                    sleep_hours: sleepHours
                )
            
            // 4. Update the UI
            let finalScore = prediction.final_score
            predictedScore = String(format: "%2.f", finalScore)
        } catch {
            predictedScore = "Error"
        }
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ContentView()
}
