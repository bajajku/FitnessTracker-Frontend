import SwiftUI
import Charts

struct StatisticsView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var timeRange: TimeRange = .week
    @State private var startDate: String = formatDate(Date().addingTimeInterval(-7*24*60*60)) // 1 week ago
    @State private var endDate: String = formatDate(Date())
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Time range picker
                Picker("Time Range", selection: $timeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: timeRange) { _ in
                    updateDateRange()
                    fetchData()
                }
                
                // Calories summary card
                CaloriesSummaryCard(viewModel: viewModel)
                    .padding(.horizontal)
                
                // Workouts by type chart
                WorkoutTypeChart(workouts: viewModel.workouts)
                    .frame(height: 250)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                // Calories burned chart
                CaloriesBurnedChart(workouts: viewModel.workouts)
                    .frame(height: 250)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                // Workout duration chart
                WorkoutDurationChart(workouts: viewModel.workouts)
                    .frame(height: 250)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .onAppear {
            updateDateRange()
            fetchData()
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading statistics...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
        )
    }
    
    private func updateDateRange() {
        switch timeRange {
        case .week:
            startDate = formatDate(Date().addingTimeInterval(-7*24*60*60))
            endDate = formatDate(Date())
        case .month:
            startDate = formatDate(Date().addingTimeInterval(-30*24*60*60))
            endDate = formatDate(Date())
        case .threeMonths:
            startDate = formatDate(Date().addingTimeInterval(-90*24*60*60))
            endDate = formatDate(Date())
        case .year:
            startDate = formatDate(Date().addingTimeInterval(-365*24*60*60))
            endDate = formatDate(Date())
        }
    }
    
    private func fetchData() {
        viewModel.fetchWorkouts(startDate: startDate, endDate: endDate)
        viewModel.fetchCaloriesSummary(startDate: startDate, endDate: endDate)
    }
}

// MARK: - Supporting Views

struct CaloriesSummaryCard: View {
    @ObservedObject var viewModel: WorkoutViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            if let summary = viewModel.caloriesSummary {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Total Calories Burned")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("\(summary.totalCalories)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        Text("Workouts")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("\(summary.workoutCount)")
                            .font(.system(size: 36, weight: .bold))
                    }
                }
            } else {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Total Calories Burned")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("0")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        Text("Workouts")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("0")
                            .font(.system(size: 36, weight: .bold))
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct WorkoutTypeChart: View {
    let workouts: [Workout]
    
    var workoutsByType: [WorkoutTypeCount] {
        let grouped = Dictionary(grouping: workouts, by: { $0.type })
        return grouped.map { WorkoutTypeCount(type: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Workouts by Type")
                .font(.headline)
            
            if workouts.isEmpty {
                Text("No data available")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Chart {
                    ForEach(workoutsByType) { item in
                        BarMark(
                            x: .value("Type", item.type),
                            y: .value("Count", item.count)
                        )
                        .foregroundStyle(by: .value("Type", item.type))
                    }
                }
            }
        }
    }
}

struct CaloriesBurnedChart: View {
    let workouts: [Workout]
    
    func stringFromDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    var caloriesByDay: [CaloriesByDay] {
        let grouped = Dictionary(grouping: workouts) { workout in
            workout.date
        }
        
        return grouped.map { date, workouts in
            let totalCalories = workouts.reduce(0) { $0 + $1.caloriesBurned }
            return CaloriesByDay(date: String(date), calories: totalCalories)
        }.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Calories Burned")
                .font(.headline)
            
            if workouts.isEmpty {
                Text("No data available")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Chart {
                    ForEach(caloriesByDay) { item in
                        LineMark(
                            x: .value("Date", item.date),
                            y: .value("Calories", item.calories)
                        )
                        .foregroundStyle(.orange)
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Date", item.date),
                            y: .value("Calories", item.calories)
                        )
                        .foregroundStyle(.orange.opacity(0.2))
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.day().month())
                    }
                }
            }
        }
    }
}

struct WorkoutDurationChart: View {
    let workouts: [Workout]
    
    var durationByType: [DurationByType] {
        let grouped = Dictionary(grouping: workouts, by: { $0.type })
        return grouped.map { type, workouts in
            let totalDuration = workouts.reduce(0) { $0 + $1.duration }
            return DurationByType(type: type, duration: totalDuration)
        }.sorted { $0.duration > $1.duration }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Total Duration by Type (minutes)")
                .font(.headline)
            
            if workouts.isEmpty {
                Text("No data available")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Chart {
                    ForEach(durationByType) { item in
                        BarMark(
                            x: .value("Duration", item.duration),
                            y: .value("Type", item.type)
                        )
                        .foregroundStyle(by: .value("Type", item.type))
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Models

enum TimeRange: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case threeMonths = "3 Months"
    case year = "Year"
}

struct WorkoutTypeCount: Identifiable {
    let type: String
    let count: Int
    
    var id: String { type }
}

struct CaloriesByDay: Identifiable {
    let date: String
    let calories: Int
    
    var id: String { date }
}

struct DurationByType: Identifiable {
    let type: String
    let duration: Int
    
    var id: String { type }
}

// MARK: - Date Extensions

extension Date {
    var startOfWeek: Date {
        Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
    
    var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
    }
}

// Helper function to format dates
func formatDate(_ date: Date) -> String {
    let formatter = ISO8601DateFormatter()
    return formatter.string(from: date)
}

// Helper function to parse dates for display
func parseDate(_ dateString: String) -> Date? {
    let formatter = ISO8601DateFormatter()
    return formatter.date(from: dateString)
}

// Helper function to format dates for display
func formatDateForDisplay(_ dateString: String) -> String {
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // Ensures milliseconds are parsed
    isoFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC time zone
    
    guard let date = isoFormatter.date(from: dateString) else {
        print("Failed to parse date: \(dateString)") // Debugging log
        return dateString // Return original if parsing fails
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMM d, yyyy • h:mm a" // Example: "Friday, Mar 7, 2025 • 7:44 AM"
    formatter.timeZone = TimeZone.current // Convert to local time zone
    
    return formatter.string(from: date)
}
// Update WorkoutRowView
//struct WorkoutRowView: View {
//    let workout: Workout
//    
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                Text(workout.type)
//                    .font(.headline)
//                
//                Text("\(workout.duration) minutes")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                
//                if let notes = workout.notes, !notes.isEmpty {
//                    Text(notes)
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                        .lineLimit(1)
//                }
//            }
//            
//            Spacer()
//            
//            VStack(alignment: .trailing) {
//                Text("\(workout.caloriesBurned) cal")
//                    .font(.headline)
//                    .foregroundColor(.orange)
//                
//                Text(formatDateForDisplay(workout.date))
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            }
//        }
//        .padding(.vertical, 4)
//    }
//} 
