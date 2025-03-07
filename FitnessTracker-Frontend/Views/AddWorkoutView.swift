import SwiftUI

struct AddWorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var user = "User" // In a real app, this would come from authentication
    @State private var selectedType = WorkoutType.running
    @State private var duration = 30
    @State private var caloriesBurned = 200
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Workout Details")) {
                    Picker("Type", selection: $selectedType) {
                        ForEach(WorkoutType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    Stepper("Duration: \(duration) minutes", value: $duration, in: 1...300)
                    
                    Stepper("Calories: \(caloriesBurned)", value: $caloriesBurned, in: 1...2000)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Add Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addWorkout(
                            user: user,
                            type: selectedType.rawValue, // Convert to lowercase to match API format
                            duration: duration,
                            caloriesBurned: caloriesBurned,
                            notes: notes.isEmpty ? nil : notes
                        )
                        dismiss()
                    }
                }
            }
            .overlay(
                Group {
                    if viewModel.isLoading {
                        ProgressView("Saving...")
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            )
        }
    }
} 
