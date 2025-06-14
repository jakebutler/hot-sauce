import Foundation

struct StepData: Identifiable {
    let id = UUID()
    let date: Date
    let steps: Int
    let distance: Double // in meters
    let calories: Double
    let activeMinutes: Int
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var formattedDistance: String {
        let kilometers = distance / 1000
        return String(format: "%.2f km", kilometers)
    }
    
    var formattedCalories: String {
        return String(format: "%.0f kcal", calories)
    }
} 