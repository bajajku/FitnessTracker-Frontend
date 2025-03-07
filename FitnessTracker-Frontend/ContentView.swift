import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    @State private var showingAddWorkout = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                WorkoutListView(viewModel: viewModel)
                    .navigationTitle("Workouts")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showingAddWorkout = true
                            }) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    .sheet(isPresented: $showingAddWorkout) {
                        AddWorkoutView(viewModel: viewModel)
                    }
            }
            .tabItem {
                Label("Workouts", systemImage: "figure.run")
            }
            .tag(0)
            
            NavigationStack {
                StatisticsView(viewModel: viewModel)
                    .navigationTitle("Statistics")
            }
            .tabItem {
                Label("Statistics", systemImage: "chart.bar")
            }
            .tag(1)
            
            NavigationStack {
                SettingsView()
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(2)
        }
        .onAppear {
            viewModel.fetchWorkouts()
        }
    }
}

// Simple placeholder for SettingsView
struct SettingsView: View {
    var body: some View {
        List {
            Text("Settings coming soon...")
        }
    }
}

#Preview {
    ContentView()
}
