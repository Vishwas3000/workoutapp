import CoreData
import Foundation

@objc(Exercise)
public class Exercise: NSManagedObject {
  @NSManaged public var id: UUID
  @NSManaged public var name: String
  @NSManaged public var sets: Int16
  @NSManaged public var reps: String
  @NSManaged public var weight: String
  @NSManaged public var notes: String?
  @NSManaged public var completedSets: Set<CompletedSet>
  @NSManaged public var workoutDay: WorkoutDay?
  @NSManaged public var muscleGroup: String

  static func create(
    context: NSManagedObjectContext, name: String, sets: Int, reps: String, weight: String,
    notes: String?, muscleGroup: MuscleGroup
  ) -> Exercise {
    let exercise = Exercise(context: context)
    exercise.id = UUID()
    exercise.name = name
    exercise.sets = Int16(sets)
    exercise.reps = reps
    exercise.weight = weight
    exercise.notes = notes
    exercise.muscleGroup = muscleGroup.rawValue
    return exercise
  }
}

extension Exercise {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Exercise> {
    return NSFetchRequest<Exercise>(entityName: "Exercise")
  }

  @objc(addCompletedSetsObject:)
  @NSManaged public func addToCompletedSets(_ value: CompletedSet)

  @objc(removeCompletedSetsObject:)
  @NSManaged public func removeFromCompletedSets(_ value: CompletedSet)

  @objc(addCompletedSets:)
  @NSManaged public func addToCompletedSets(_ values: NSSet)

  @objc(removeCompletedSets:)
  @NSManaged public func removeFromCompletedSets(_ values: NSSet)
}

@objc(CompletedSet)
public class CompletedSet: NSManagedObject {
  @NSManaged public var id: UUID
  @NSManaged public var reps: Int16
  @NSManaged public var weight: Double
  @NSManaged public var date: Date
  @NSManaged public var exercise: Exercise?
  @NSManaged public var setNumber: Int16

  static func create(context: NSManagedObjectContext, reps: Int, weight: Double) -> CompletedSet {
    let set = CompletedSet(context: context)
    set.id = UUID()
    set.reps = Int16(reps)
    set.weight = weight
    set.date = Date()
    return set
  }
}

extension CompletedSet {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<CompletedSet> {
    return NSFetchRequest<CompletedSet>(entityName: "CompletedSet")
  }
}
