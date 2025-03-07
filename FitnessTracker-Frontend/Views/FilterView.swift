import SwiftUI

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedWorkoutType: String?
    @Binding var startDate: String?
    @Binding var endDate: String?
    
    @State private var tempSelectedType: String?
    @State private var useStartDate = false
    @State private var useEndDate = false
    @State private var tempStartDate = Date().addingTimeInterval(-7*24*60*60) // 1 week ago
    @State private var tempEndDate = Date()
    
    let onApply: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Workout Type")) {
                    Picker("Type", selection: $tempSelectedType) {
                        Text("All Types").tag(nil as String?)
                        ForEach(WorkoutType.allCases) { type in
                            Text(type.rawValue).tag(type.rawValue as String?)
                        }
                    }
                }
                
                Section(header: Text("Date Range")) {
                    Toggle("Start Date", isOn: $useStartDate)
                    
                    if useStartDate {
                        DatePicker("From", selection: $tempStartDate, displayedComponents: .date)
                    }
                    
                    Toggle("End Date", isOn: $useEndDate)
                    
                    if useEndDate {
                        DatePicker("To", selection: $tempEndDate, displayedComponents: .date)
                    }
                }
                
                Section {
                    Button("Reset Filters") {
                        tempSelectedType = nil
                        useStartDate = false
                        useEndDate = false
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filter Workouts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        selectedWorkoutType = tempSelectedType
                        
                        if useStartDate {
                            let formatter = ISO8601DateFormatter()
                            startDate = formatter.string(from: tempStartDate)
                        } else {
                            startDate = nil
                        }
                        
                        if useEndDate {
                            let formatter = ISO8601DateFormatter()
                            endDate = formatter.string(from: tempEndDate)
                        } else {
                            endDate = nil
                        }
                        
                        onApply()
                        dismiss()
                    }
                }
            }
            .onAppear {
                tempSelectedType = selectedWorkoutType
                
                if let start = startDate, let date = parseDate(start) {
                    useStartDate = true
                    tempStartDate = date
                }
                
                if let end = endDate, let date = parseDate(end) {
                    useEndDate = true
                    tempEndDate = date
                }
            }
        }
    }
} 