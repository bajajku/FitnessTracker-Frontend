import SwiftUI

struct WorkoutListView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var selectedWorkoutType: String?
    @State private var showingFilters = false
    @State private var startDate: String?
    @State private var endDate: String?
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.workouts.isEmpty {
                ProgressView("Loading workouts...")
            } else if viewModel.workouts.isEmpty {
                VStack {
                    Image(systemName: "figure.run")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                        .padding()
                    
                    Text("No workouts found")
                        .font(.headline)
                    
                    if selectedWorkoutType != nil || startDate != nil || endDate != nil {
                        Text("Try changing your filters")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 1)
                        
                        Button("Clear Filters") {
                            selectedWorkoutType = nil
                            startDate = nil
                            endDate = nil
                            viewModel.fetchWorkouts()
                        }
                        .padding(.top)
                    } else {
                        Text("Add your first workout to get started")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 1)
                    }
                }
                .padding()
            } else {
                List {
                    ForEach(viewModel.workouts) { workout in
                        NavigationLink(destination: WorkoutDetailView(viewModel: viewModel, workout: workout)) {
                            WorkoutRowView(workout: workout)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteWorkout(id: viewModel.workouts[index].id)
                        }
                    }
                }
                .refreshable {
                    viewModel.fetchWorkouts(
                        type: selectedWorkoutType,
                        startDate: startDate,
                        endDate: endDate
                    )
                }
            }
        }
        .overlay(
            Group {
                if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text("Error")
                            .font(.headline)
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.red)
                        
                        Button("Dismiss") {
                            viewModel.errorMessage = nil
                        }
                        .padding(.top)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
            }
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showingFilters = true
                }) {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text("Filter")
                    }
                }
            }
        }
        .sheet(isPresented: $showingFilters) {
            FilterView(
                selectedWorkoutType: $selectedWorkoutType,
                startDate: $startDate,
                endDate: $endDate,
                onApply: {
                    viewModel.fetchWorkouts(
                        type: selectedWorkoutType,
                        startDate: startDate,
                        endDate: endDate
                    )
                }
            )
        }
    }
}

struct WorkoutRowView: View {
    let workout: Workout
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(workout.type)
                    .font(.headline)
                
                Text("\(workout.duration) minutes")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if let notes = workout.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(workout.caloriesBurned) cal")
                    .font(.headline)
                    .foregroundColor(.orange)
                
//                Text(workout.date.formatted(date: .abbreviated, time: .shortened))
//                    .font(.caption)
//                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
} 
