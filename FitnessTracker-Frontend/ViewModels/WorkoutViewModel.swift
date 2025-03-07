import Foundation
import Combine

class WorkoutViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var caloriesSummary: CaloriesSummary?
    
    private let networkManager = NetworkManager.shared
    
    // MARK: - Workout CRUD Operations
    
    func fetchWorkouts(type: String? = nil, startDate: String? = nil, endDate: String? = nil) {
        isLoading = true
        errorMessage = nil
        
        networkManager.getWorkouts(type: type, startDate: startDate, endDate: endDate) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let workouts):
                    self?.workouts = workouts
                    // No error when data is empty - this is a valid state
                case .failure(let error):
                    // Only show error for actual network/server errors
                    if let networkError = error as? NetworkError, 
                       case .invalidData = networkError {
                        // Don't show error for empty data
                        self?.workouts = []
                    } else {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    func addWorkout(user: String, type: String, duration: Int, caloriesBurned: Int, notes: String? = nil) {
        isLoading = true
        errorMessage = nil
        
        networkManager.createWorkout(
            user: user,
            type: type,
            duration: duration,
            caloriesBurned: caloriesBurned,
            notes: notes
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let workout):
                    self?.workouts.insert(workout, at: 0)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func updateWorkout(workout: Workout) {
        isLoading = true
        errorMessage = nil
        
        networkManager.updateWorkout(id: workout.id, workout: workout) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let updatedWorkout):
                    if let index = self?.workouts.firstIndex(where: { $0.id == updatedWorkout.id }) {
                        self?.workouts[index] = updatedWorkout
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func deleteWorkout(id: String) {
        isLoading = true
        errorMessage = nil
        
        networkManager.deleteWorkout(id: id) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.workouts.removeAll { $0.id == id }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func fetchCaloriesSummary(startDate: String, endDate: String) {
        isLoading = true
        errorMessage = nil
        
        networkManager.getTotalCalories(startDate: startDate, endDate: endDate) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let summary):
                    self?.caloriesSummary = summary
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
} 
