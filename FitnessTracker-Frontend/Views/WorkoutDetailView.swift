import SwiftUI

struct WorkoutDetailView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var workout: Workout
    @State private var isEditing = false
    @State private var showingDeleteConfirmation = false
    
    // Editable fields
    @State private var selectedType: String
    @State private var duration: Int
    @State private var caloriesBurned: Int
    @State private var date: Date
    @State private var notes: String
    
    init(viewModel: WorkoutViewModel, workout: Workout) {
        self.viewModel = viewModel
        _workout = State(initialValue: workout)
        _selectedType = State(initialValue: workout.type)
        _duration = State(initialValue: workout.duration)
        _caloriesBurned = State(initialValue: workout.caloriesBurned)
        
        // Parse the date string to Date for editing
        let parsedDate = parseDate(workout.date) ?? Date()
        _date = State(initialValue: parsedDate)
        
        _notes = State(initialValue: workout.notes ?? "")
    }
    
    var body: some View {
        Form {
            if isEditing {
                Section(header: Text("Workout Details")) {
                    Picker("Type", selection: $selectedType) {
                        ForEach(WorkoutType.allCases) { type in
                            Text(type.rawValue).tag(type.rawValue)
                        }
                    }
                    
                    Stepper("Duration: \(duration) minutes", value: $duration, in: 1...300)
                    
                    Stepper("Calories: \(caloriesBurned)", value: $caloriesBurned, in: 1...2000)
                    
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            } else {
                Section(header: Text("Workout Details")) {
                    DetailRow(label: "Type", value: workout.type)
                    DetailRow(label: "Duration", value: "\(workout.duration) minutes")
                    DetailRow(label: "Calories Burned", value: "\(workout.caloriesBurned)")
                    DetailRow(label: "Date", value: formatDateForDisplay(workout.date))
                }
                
                if let notes = workout.notes, !notes.isEmpty {
                    Section(header: Text("Notes")) {
                        Text(notes)
                            .padding(.vertical, 8)
                    }
                }
            }
        }
        .navigationTitle(isEditing ? "Edit Workout" : "Workout Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
                    Button("Save") {
                        saveChanges()
                    }
                } else {
                    Button("Edit") {
                        isEditing = true
                    }
                }
            }
            
            if !isEditing {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .alert("Delete Workout", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteWorkout(id: workout.id)
                
                // Navigate back to the previous screen
                presentationMode.wrappedValue.dismiss() // Navigate back after deletion

            }
        } message: {
            Text("Are you sure you want to delete this workout? This action cannot be undone.")
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
        )
    }
    
    private func saveChanges() {
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: date)
        
        let updatedWorkout = Workout(
            id: workout.id,
            user: workout.user,
            type: selectedType,
            duration: duration,
            caloriesBurned: caloriesBurned,
            date: dateString,
            createdAt: workout.createdAt,
            updatedAt: formatter.string(from: Date()),
            notes: notes.isEmpty ? nil : notes,
            v: workout.v
        )
        
        viewModel.updateWorkout(workout: updatedWorkout)
        workout = updatedWorkout
        isEditing = false
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
} 
