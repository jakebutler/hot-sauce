import CoreData
import Foundation

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "StepDataModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    func saveStepData(_ data: [StepData]) {
        // Delete existing data
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = StepDataEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            print("Error deleting existing data: \(error)")
        }
        
        // Save new data
        for stepData in data {
            let entity = StepDataEntity(context: context)
            entity.date = stepData.date
            entity.steps = Int32(stepData.steps)
            entity.distance = stepData.distance
            entity.calories = stepData.calories
            entity.activeMinutes = Int32(stepData.activeMinutes)
        }
        
        saveContext()
    }
    
    func fetchStepData() -> [StepData] {
        let fetchRequest: NSFetchRequest<StepDataEntity> = StepDataEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \StepDataEntity.date, ascending: false)]
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.map { entity in
                StepData(
                    date: entity.date ?? Date(),
                    steps: Int(entity.steps),
                    distance: entity.distance,
                    calories: entity.calories,
                    activeMinutes: Int(entity.activeMinutes)
                )
            }
        } catch {
            print("Error fetching step data: \(error)")
            return []
        }
    }
} 