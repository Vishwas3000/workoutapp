import Combine
import CoreData
import Foundation

class WorkoutSessionViewModel {

  // MARK: - Properties
  private let workoutDay: WorkoutDay
  private let context: NSManagedObjectContext
  @Published private(set) var isWorkoutActive = false
  private var workoutSession: WorkoutSession?

  // MARK: - Initialization
  init(workoutDay: WorkoutDay) {
    self.workoutDay = workoutDay
    self.context = PersistenceController.shared.container.viewContext
  }

  // MARK: - Public Methods
  func startWorkout() {
    guard !isWorkoutActive else { return }

    workoutSession = WorkoutSession(context: context)
    workoutSession?.id = UUID()
    workoutSession?.date = Date()
    workoutSession?.workoutDayId = workoutDay.id
    workoutSession?.duration = 0

    isWorkoutActive = true
    try? context.save()
  }

  func endWorkout() {
    guard isWorkoutActive else { return }

    workoutSession?.duration = Int16(Date().timeIntervalSince(workoutSession?.date ?? Date()))
    workoutDay.isCompleted = true
    workoutDay.date = Date()

    isWorkoutActive = false
    try? context.save()
  }

  func addCompletedSet(_ set: CompletedSet, for exercise: Exercise) {
    guard isWorkoutActive else { return }

    set.exercise = exercise
    exercise.completedSets.insert(set)

    try? context.save()
  }

  // MARK: - Analytics
  func calculateTotalVolume() -> Double {
    var totalVolume: Double = 0

    for exercise in workoutDay.exercises {
      for set in exercise.completedSets {
        totalVolume += set.weight * Double(set.reps)
      }
    }

    return totalVolume
  }

  func calculateTotalSets() -> Int {
    return workoutDay.exercises.reduce(0) { $0 + Int($1.completedSets.count) }
  }

  func calculateTotalReps() -> Int {
    return workoutDay.exercises.reduce(0) { $0 + $1.completedSets.reduce(0) { $0 + Int($1.reps) } }
  }
}
