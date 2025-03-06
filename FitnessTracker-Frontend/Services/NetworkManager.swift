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
    
    func createWorkout(workout: Workout, completion: @escaping (Result<Workout, Error>) -> Void) {
        let endpoint = "\(baseURL)/workouts"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
    
    func getWorkouts(type: String? = nil, startDate: Date? = nil, endDate: Date? = nil, completion: @escaping (Result<[Workout], Error>) -> Void) {
        var endpoint = "\(baseURL)/workouts"
        
        var queryItems = [URLQueryItem]()
        
        if let type = type {
            queryItems.append(URLQueryItem(name: "type", value: type))
        }
        
        let dateFormatter = ISO8601DateFormatter()
        
        if let startDate = startDate {
            queryItems.append(URLQueryItem(name: "startDate", value: dateFormatter.string(from: startDate)))
        }
        
        if let endDate = endDate {
            queryItems.append(URLQueryItem(name: "endDate", value: dateFormatter.string(from: endDate)))
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
                let workouts = try decoder.decode([Workout].self, from: data)
                completion(.success(workouts))
            } catch {
                completion(.failure(error))
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
    
    func getTotalCalories(startDate: Date, endDate: Date, completion: @escaping (Result<CaloriesSummary, Error>) -> Void) {
        let endpoint = "\(baseURL)/workouts/calories"
        
        let dateFormatter = ISO8601DateFormatter()
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)
        
        var urlComponents = URLComponents(string: endpoint)
        urlComponents?.queryItems = [
            URLQueryItem(name: "startDate", value: startDateString),
            URLQueryItem(name: "endDate", value: endDateString)
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
                let summary = try decoder.decode(CaloriesSummary.self, from: data)
                completion(.success(summary))
            } catch {
                completion(.failure(error))
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