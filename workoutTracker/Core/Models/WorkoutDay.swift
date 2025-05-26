import CoreData
import Foundation

enum MuscleGroup: String, Codable {
  case chest
  case back
  case shoulders
  case biceps
  case triceps
  case legs
  case core
  case fullBody
  case arms
}

enum WorkoutType: String, Codable {
  case legsSquat = "Legs (Squat Focus)"
  case push = "Push (Upper Body)"
  case pull = "Pull (Upper Body)"
  case legsDeadlift = "Legs (Deadlift Focus)"
  case rest = "Rest"
  case cardio = "Cardio"
  case fullBody = "Full Body"

  var icon: String {
    switch self {
    case .push: return "💪"
    case .pull: return "🧲"
    case .legsSquat, .legsDeadlift: return "🦵"
    case .rest: return "🎯"
    case .cardio: return "🏃"
    case .fullBody: return "💯"
    }
  }

  var color: String {
    switch self {
    case .push: return "systemRed"
    case .pull: return "systemBlue"
    case .legsSquat, .legsDeadlift: return "systemGreen"
    case .rest: return "systemGray"
    case .cardio: return "systemOrange"
    case .fullBody: return "systemPurple"
    }
  }
}

@objc(WorkoutDay)
public class WorkoutDay: NSManagedObject {
  @NSManaged public var id: UUID
  @NSManaged public var type: String
  @NSManaged public var exercises: Set<Exercise>
  @NSManaged public var order: Int16
  @NSManaged public var isCompleted: Bool
  @NSManaged public var date: Date?
  @NSManaged public var name: String
  @NSManaged public var dayNumber: Int16
  @NSManaged public var focusArea: String
  @NSManaged public var estimatedDuration: Int16

  var totalSets: Int {
    exercises.reduce(0) { $0 + Int($1.sets) }
  }

  var muscleGroups: [MuscleGroup] {
    Array(Set(exercises.compactMap { MuscleGroup(rawValue: $0.muscleGroup) }))
  }
}

extension WorkoutDay {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutDay> {
    return NSFetchRequest<WorkoutDay>(entityName: "WorkoutDay")
  }

  @objc(addExercisesObject:)
  @NSManaged public func addToExercises(_ value: Exercise)

  @objc(removeExercisesObject:)
  @NSManaged public func removeFromExercises(_ value: Exercise)

  @objc(addExercises:)
  @NSManaged public func addToExercises(_ values: NSSet)

  @objc(removeExercises:)
  @NSManaged public func removeFromExercises(_ values: NSSet)

  static func createDefaultWorkoutPlan(context: NSManagedObjectContext) {
    // Day 1: Legs (Squat Focus)
    let day1 = WorkoutDay(context: context)
    day1.id = UUID()
    day1.type = WorkoutType.legsSquat.rawValue
    day1.order = 1
    day1.name = "Legs (Squat Focus)"
    day1.dayNumber = 1
    day1.focusArea = "Lower Body"
    day1.estimatedDuration = 60
    day1.exercises = [
      Exercise.create(
        context: context, name: "Barbell Back Squat", sets: 3, reps: "4", weight: "80% 1RM",
        notes: "Focus on form", muscleGroup: .legs),
      Exercise.create(
        context: context, name: "Romanian Deadlift", sets: 3, reps: "10", weight: "Body weight",
        notes: nil, muscleGroup: .legs),
      Exercise.create(
        context: context, name: "Single-Leg Press", sets: 3, reps: "15", weight: "Body weight",
        notes: nil, muscleGroup: .legs),
      Exercise.create(
        context: context, name: "Eccentric Leg Extension", sets: 3, reps: "10-12",
        weight: "Body weight", notes: nil, muscleGroup: .legs),
      Exercise.create(
        context: context, name: "Seated Leg Curl", sets: 3, reps: "10-12", weight: "Body weight",
        notes: nil, muscleGroup: .legs),
      Exercise.create(
        context: context, name: "Standing Calf Raise", sets: 3, reps: "10-12",
        weight: "Body weight", notes: nil, muscleGroup: .legs),
      Exercise.create(
        context: context, name: "Decline Crunches", sets: 2, reps: "10-12", weight: "Body weight",
        notes: nil, muscleGroup: .core),
      Exercise.create(
        context: context, name: "Long-Lever Plank", sets: 2, reps: "30 seconds",
        weight: "Body weight", notes: nil, muscleGroup: .core),
    ]

    // Day 2: Push
    let day2 = WorkoutDay(context: context)
    day2.id = UUID()
    day2.type = WorkoutType.push.rawValue
    day2.order = 2
    day2.name = "Push (Upper Body)"
    day2.dayNumber = 2
    day2.focusArea = "Chest, Shoulders, Triceps"
    day2.estimatedDuration = 60
    day2.exercises = [
      Exercise.create(
        context: context, name: "Barbell Bench Press", sets: 3, reps: "8", weight: "72.5% 1RM",
        notes: nil, muscleGroup: .chest),
      Exercise.create(
        context: context, name: "Machine Shoulder Press", sets: 3, reps: "12",
        weight: "Body weight", notes: nil, muscleGroup: .shoulders),
      Exercise.create(
        context: context, name: "Dips", sets: 3, reps: "12-15", weight: "Body weight", notes: nil,
        muscleGroup: .triceps),
      Exercise.create(
        context: context, name: "Eccentric Skull Crushers", sets: 3, reps: "8-10",
        weight: "Body weight", notes: nil, muscleGroup: .triceps),
      Exercise.create(
        context: context, name: "Egyptian Lateral Raise", sets: 3, reps: "12",
        weight: "Body weight", notes: nil, muscleGroup: .shoulders),
      Exercise.create(
        context: context, name: "Cable Triceps Kickbacks", sets: 3, reps: "20-30",
        weight: "Body weight", notes: nil, muscleGroup: .triceps),
    ]

    // Day 3: Pull
    let day3 = WorkoutDay(context: context)
    day3.id = UUID()
    day3.type = WorkoutType.pull.rawValue
    day3.order = 3
    day3.name = "Pull (Upper Body)"
    day3.dayNumber = 3
    day3.focusArea = "Back, Biceps"
    day3.estimatedDuration = 60
    day3.exercises = [
      Exercise.create(
        context: context, name: "Weighted Pull-Up", sets: 3, reps: "6", weight: "Body weight",
        notes: nil, muscleGroup: .back),
      Exercise.create(
        context: context, name: "Seated Cable Row", sets: 3, reps: "10-12", weight: "Body weight",
        notes: nil, muscleGroup: .back),
      Exercise.create(
        context: context, name: "Cable Pullover", sets: 3, reps: "15-20", weight: "Body weight",
        notes: nil, muscleGroup: .back),
      Exercise.create(
        context: context, name: "Hammer Cheat Curl", sets: 3, reps: "8-10", weight: "Body weight",
        notes: nil, muscleGroup: .biceps),
      Exercise.create(
        context: context, name: "Incline Dumbbell Curl", sets: 2, reps: "12-15",
        weight: "Body weight", notes: nil, muscleGroup: .biceps),
    ]

    // Day 4: Legs (Deadlift Focus)
    let day4 = WorkoutDay(context: context)
    day4.id = UUID()
    day4.type = WorkoutType.legsDeadlift.rawValue
    day4.order = 4
    day4.name = "Legs (Deadlift Focus)"
    day4.dayNumber = 4
    day4.focusArea = "Lower Body"
    day4.estimatedDuration = 60
    day4.exercises = [
      Exercise.create(
        context: context, name: "Barbell Deadlift", sets: 3, reps: "3", weight: "80-85% 1RM",
        notes: nil, muscleGroup: .legs),
      Exercise.create(
        context: context, name: "Hack Squat", sets: 3, reps: "10-12", weight: "Body weight",
        notes: nil, muscleGroup: .legs),
      Exercise.create(
        context: context, name: "Single-Leg Hip Thrust", sets: 3, reps: "15", weight: "Body weight",
        notes: nil, muscleGroup: .legs),
      Exercise.create(
        context: context, name: "Nordic Hamstring Curl", sets: 2, reps: "10-12",
        weight: "Body weight", notes: nil, muscleGroup: .legs),
      Exercise.create(
        context: context, name: "Prisoner Back Extension", sets: 2, reps: "10-12",
        weight: "Body weight", notes: nil, muscleGroup: .back),
      Exercise.create(
        context: context, name: "Single-Leg Calf Raise", sets: 3, reps: "8-10",
        weight: "Body weight", notes: nil, muscleGroup: .legs),
      Exercise.create(
        context: context, name: "Weighted L-Sit Hold", sets: 3, reps: "30 seconds",
        weight: "Body weight", notes: nil, muscleGroup: .core),
    ]

    // Day 5: Push
    let day5 = WorkoutDay(context: context)
    day5.id = UUID()
    day5.type = WorkoutType.push.rawValue
    day5.order = 5
    day5.name = "Push (Upper Body)"
    day5.dayNumber = 5
    day5.focusArea = "Shoulders, Chest, Triceps"
    day5.estimatedDuration = 60
    day5.exercises = [
      Exercise.create(
        context: context, name: "Overhead Press", sets: 4, reps: "4", weight: "80% 1RM", notes: nil,
        muscleGroup: .shoulders),
      Exercise.create(
        context: context, name: "Close-Grip Bench Press", sets: 3, reps: "10",
        weight: "Body weight", notes: nil, muscleGroup: .chest),
      Exercise.create(
        context: context, name: "Cable Crossover", sets: 3, reps: "10-12", weight: "Body weight",
        notes: nil, muscleGroup: .chest),
      Exercise.create(
        context: context, name: "Overhead Triceps Extension", sets: 3, reps: "10-12",
        weight: "Body weight", notes: nil, muscleGroup: .triceps),
      Exercise.create(
        context: context, name: "Lateral Raise 21s", sets: 3, reps: "21", weight: "Body weight",
        notes: "7 reps at bottom range, 7 at top range, 7 full range", muscleGroup: .shoulders),
      Exercise.create(
        context: context, name: "Neck Flexion/Extension", sets: 3, reps: "10-12",
        weight: "Body weight", notes: nil, muscleGroup: .shoulders),
    ]

    // Day 6: Pull
    let day6 = WorkoutDay(context: context)
    day6.id = UUID()
    day6.type = WorkoutType.pull.rawValue
    day6.order = 6
    day6.name = "Pull (Upper Body)"
    day6.dayNumber = 6
    day6.focusArea = "Back, Biceps"
    day6.estimatedDuration = 60
    day6.exercises = [
      Exercise.create(
        context: context, name: "Omni-Grip Lat Pulldown", sets: 3, reps: "10-12",
        weight: "Body weight", notes: nil, muscleGroup: .back),
      Exercise.create(
        context: context, name: "Chest-Supported Row", sets: 3, reps: "10-12",
        weight: "Body weight", notes: nil, muscleGroup: .back),
      Exercise.create(
        context: context, name: "Rope Face Pull", sets: 3, reps: "15-20", weight: "Body weight",
        notes: nil, muscleGroup: .back),
      Exercise.create(
        context: context, name: "Incline Dumbbell Shrug", sets: 3, reps: "15-20",
        weight: "Body weight", notes: nil, muscleGroup: .back),
      Exercise.create(
        context: context, name: "Reverse Pec Deck", sets: 2, reps: "15+", weight: "Body weight",
        notes: "Optional", muscleGroup: .back),
      Exercise.create(
        context: context, name: "Pronated/Supinated Curl", sets: 3, reps: "10",
        weight: "Body weight", notes: "Each grip", muscleGroup: .biceps),
    ]

    // Day 7: Rest
    let day7 = WorkoutDay(context: context)
    day7.id = UUID()
    day7.type = WorkoutType.rest.rawValue
    day7.order = 7
    day7.name = "Rest Day"
    day7.dayNumber = 7
    day7.focusArea = "Recovery"
    day7.estimatedDuration = 0
    day7.exercises = []

    try? context.save()
  }
}
