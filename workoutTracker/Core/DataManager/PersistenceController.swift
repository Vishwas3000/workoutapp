import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "GymTracker")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    // MARK: - Preview Support
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample data for previews
        let sampleSession = WorkoutSession(context: viewContext)
        sampleSession.id = UUID()
        sampleSession.date = Date()
        sampleSession.workoutDayId = UUID()
        sampleSession.duration = 3600
        sampleSession.notes = "Great workout!"
        
        let sampleWeight = WeightEntry(context: viewContext)
        sampleWeight.id = UUID()
        sampleWeight.date = Date()
        sampleWeight.weight = 180.5
        sampleWeight.unit = "lbs"
        
        do {
            try viewContext.save()
        } catch {
            fatalError("Failed to save preview context: \(error)")
        }
        
        return result
    }()
}
