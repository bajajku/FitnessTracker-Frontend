import Foundation

struct Workout: Identifiable, Codable {
    var id: String
    var user: String
    var type: String
    var duration: Int
    var caloriesBurned: Int
    var date: Date
    var notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user, type, duration, caloriesBurned, date, notes
    }
}

// Workout types for selection
enum WorkoutType: String, CaseIterable, Identifiable {
    case running = "Running"
    case cycling = "Cycling"
    case swimming = "Swimming"
    case weightlifting = "Weightlifting"
    case yoga = "Yoga"
    case hiit = "HIIT"
    case other = "Other"
    
    var id: String { self.rawValue }
} 