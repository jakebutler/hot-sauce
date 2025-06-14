import Foundation
import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var todaySteps: Int = 0
    @Published var last30DaysData: [StepData] = []
    @Published var lastUpdated: String = "Never"
    @Published var isLoading = false
    @Published var error: Error?
    
    private let healthKitManager = HealthKitManager()
    private let coreDataManager = CoreDataManager.shared
    
    init() {
        // Load cached data immediately
        loadCachedData()
    }
    
    private func loadCachedData() {
        last30DaysData = coreDataManager.fetchStepData()
        if let todayData = last30DaysData.first {
            todaySteps = todayData.steps
        }
    }
    
    func refreshData() async {
        isLoading = true
        error = nil
        
        do {
            // Fetch today's steps
            let steps = try await healthKitManager.fetchTodaySteps()
            todaySteps = Int(steps)
            
            // Fetch last 30 days data
            let newData = try await healthKitManager.fetchLast30DaysData()
            last30DaysData = newData
            
            // Save to CoreData
            coreDataManager.saveStepData(newData)
            
            // Update last updated timestamp
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            lastUpdated = formatter.string(from: Date())
        } catch {
            self.error = error
            print("Error refreshing data: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // Temporary function to generate sample data
    private func generateSampleData() -> [StepData] {
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<30).map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            return StepData(
                date: date,
                steps: Int.random(in: 5000...15000),
                distance: Double.random(in: 3000...10000),
                calories: Double.random(in: 200...500),
                activeMinutes: Int.random(in: 30...120)
            )
        }
    }
} 