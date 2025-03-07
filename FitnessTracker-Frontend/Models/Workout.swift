import Foundation

struct Workout: Identifiable, Codable {
    let id: String
    let user: String
    let type: String
    let duration: Int
    let caloriesBurned: Int
    let date: String
    let createdAt: String
    let updatedAt: String
    let notes: String?
    let v: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user
        case type
        case duration
        case caloriesBurned
        case date
        case createdAt
        case updatedAt
        case v = "__v"
        case notes
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
