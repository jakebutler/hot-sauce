import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    private var healthStore: HKHealthStore?
    @Published var isAuthorized = false
    @Published var error: Error?
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }
    
    func requestAuthorization() async {
        guard let healthStore = healthStore else {
            error = NSError(domain: "HealthKit", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"])
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!
        ]
        
        do {
            try await healthStore.requestAuthorization(toShare: nil, read: typesToRead)
            await MainActor.run {
                self.isAuthorized = true
            }
        } catch {
            await MainActor.run {
                self.error = error
            }
        }
    }
    
    func fetchTodaySteps() async throws -> Double {
        guard let healthStore = healthStore,
              let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw NSError(domain: "HealthKit", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to access step count data"])
        }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let result = result,
                      let sum = result.sumQuantity() else {
                    continuation.resume(throwing: NSError(domain: "HealthKit", code: 3, userInfo: [NSLocalizedDescriptionKey: "No step data available"]))
                    return
                }
                
                let steps = sum.doubleValue(for: HKUnit.count())
                continuation.resume(returning: steps)
            }
            
            healthStore.execute(query)
        }
    }
    
    func fetchLast30DaysData() async throws -> [StepData] {
        guard let healthStore = healthStore else {
            throw NSError(domain: "HealthKit", code: 2, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available"])
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -29, to: now)!
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
        
        var stepData: [StepData] = []
        
        for dayOffset in 0..<30 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate)!
            let nextDate = calendar.date(byAdding: .day, value: 1, to: date)!
            let predicate = HKQuery.predicateForSamples(withStart: date, end: nextDate, options: .strictStartDate)
            
            async let steps = fetchQuantity(for: stepType, predicate: predicate, unit: HKUnit.count())
            async let distance = fetchQuantity(for: distanceType, predicate: predicate, unit: HKUnit.meter())
            async let calories = fetchQuantity(for: caloriesType, predicate: predicate, unit: HKUnit.kilocalorie())
            async let exercise = fetchQuantity(for: exerciseType, predicate: predicate, unit: HKUnit.minute())
            
            do {
                let (stepCount, distanceMeters, caloriesBurned, exerciseMinutes) = try await (steps, distance, calories, exercise)
                
                let data = StepData(
                    date: date,
                    steps: Int(stepCount),
                    distance: distanceMeters,
                    calories: caloriesBurned,
                    activeMinutes: Int(exerciseMinutes)
                )
                stepData.append(data)
            } catch {
                print("Error fetching data for \(date): \(error.localizedDescription)")
            }
        }
        
        return stepData.sorted { $0.date > $1.date }
    }
    
    private func fetchQuantity(for type: HKQuantityType, predicate: NSPredicate, unit: HKUnit) async throws -> Double {
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let result = result,
                      let sum = result.sumQuantity() else {
                    continuation.resume(returning: 0)
                    return
                }
                
                let value = sum.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            
            healthStore?.execute(query)
        }
    }
} 