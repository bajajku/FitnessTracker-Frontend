import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case requestFailed(Error)
}

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "http://localhost:5001/api"
    
    private init() {}
    
    // MARK: - Workout API Calls
    
    func createWorkout(user: String, type: String, duration: Int, caloriesBurned: Int, notes: String? = nil, completion: @escaping (Result<Workout, Error>) -> Void) {
        let endpoint = "\(baseURL)/workouts"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create a simple request body with only the required fields
        let requestBody: [String: Any] = [
            "user": user,
            "type": type,
            "duration": duration,
            "caloriesBurned": caloriesBurned,
            "notes": notes ?? NSNull()
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(NetworkError.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, 
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let workout = try decoder.decode(Workout.self, from: data)
                completion(.success(workout))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func getWorkouts(type: String? = nil, startDate: String? = nil, endDate: String? = nil, completion: @escaping (Result<[Workout], Error>) -> Void) {
        var endpoint = "\(baseURL)/workouts"
        
        var queryItems = [URLQueryItem]()
        
        if let type = type {
            queryItems.append(URLQueryItem(name: "type", value: type))
        }
        
        if let startDate = startDate {
            queryItems.append(URLQueryItem(name: "startDate", value: startDate))
        }
        
        if let endDate = endDate {
            queryItems.append(URLQueryItem(name: "endDate", value: endDate))
        }
        
        if !queryItems.isEmpty {
            var urlComponents = URLComponents(string: endpoint)
            urlComponents?.queryItems = queryItems
            endpoint = urlComponents?.url?.absoluteString ?? endpoint
        }
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(NetworkError.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            // Handle different status codes appropriately
            switch httpResponse.statusCode {
            case 200...299:
                guard let data = data else {
                    completion(.success([]))  // Empty data is valid - return empty array
                    return
                }
                
                // Handle empty array response
                if data.count == 0 || (data.count == 2 && String(data: data, encoding: .utf8) == "[]") {
                    completion(.success([]))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let workouts = try decoder.decode([Workout].self, from: data)
                    completion(.success(workouts))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.success([]))  // If we can't decode, assume empty
                }
                
            case 404:
                // Not found is valid for empty results
                completion(.success([]))
                
            default:
                completion(.failure(NetworkError.invalidResponse))
            }
        }.resume()
    }
    
    func getWorkoutById(id: String, completion: @escaping (Result<Workout, Error>) -> Void) {
        let endpoint = "\(baseURL)/workouts/\(id)"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(NetworkError.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, 
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let workout = try decoder.decode(Workout.self, from: data)
                completion(.success(workout))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func updateWorkout(id: String, workout: Workout, completion: @escaping (Result<Workout, Error>) -> Void) {
        let endpoint = "\(baseURL)/workouts/\(id)"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(workout)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(NetworkError.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, 
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let workout = try decoder.decode(Workout.self, from: data)
                completion(.success(workout))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func deleteWorkout(id: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let endpoint = "\(baseURL)/workouts/\(id)"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(NetworkError.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, 
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            completion(.success(true))
        }.resume()
    }
    
    func getTotalCalories(startDate: String, endDate: String, completion: @escaping (Result<CaloriesSummary, Error>) -> Void) {
        let endpoint = "\(baseURL)/workouts/calories"
        
        var urlComponents = URLComponents(string: endpoint)
        urlComponents?.queryItems = [
            URLQueryItem(name: "startDate", value: startDate),
            URLQueryItem(name: "endDate", value: endDate)
        ]
        
        guard let url = urlComponents?.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(NetworkError.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                guard let data = data else {
                    // Return default summary with zeros if no data
                    let emptySummary = CaloriesSummary(totalCalories: 0, workoutCount: 0, startDate: startDate, endDate: endDate)
                    completion(.success(emptySummary))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let summary = try decoder.decode(CaloriesSummary.self, from: data)
                    completion(.success(summary))
                } catch {
                    // Return default summary if decoding fails
                    let emptySummary = CaloriesSummary(totalCalories: 0, workoutCount: 0, startDate: startDate, endDate: endDate)
                    completion(.success(emptySummary))
                }
                
            case 404:
                // Not found is valid for empty results
                let emptySummary = CaloriesSummary(totalCalories: 0, workoutCount: 0, startDate: startDate, endDate: endDate)
                completion(.success(emptySummary))
                
            default:
                completion(.failure(NetworkError.invalidResponse))
            }
        }.resume()
    }
}

struct CaloriesSummary: Codable {
    let totalCalories: Int
    let workoutCount: Int
    let startDate: String
    let endDate: String
} 
