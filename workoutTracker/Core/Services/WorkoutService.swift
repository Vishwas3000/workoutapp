import Combine
import CoreData
import Foundation

protocol WorkoutServiceProtocol {
  func getCurrentWeekWorkouts() -> AnyPublisher<[WorkoutDay], Never>
  func getTodayWorkout() -> AnyPublisher<WorkoutDay?, Never>
  func getWorkoutForDay(_ day: Int) -> WorkoutDay?
  func saveWorkoutSession(_ session: WorkoutSessionData) -> AnyPublisher<Bool, Error>
  func fetchRecentSessions(limit: Int) -> AnyPublisher<[WorkoutSession], Error>
  func getWorkoutStreak() -> AnyPublisher<Int, Never>
  func getWeeklyProgress() -> AnyPublisher<Float, Never>
}

class WorkoutService: WorkoutServiceProtocol {

  static let shared = WorkoutService()
  private let coreDataManager = PersistenceController.shared
  private var cancellables = Set<AnyCancellable>()

  // MARK: - Workout Plan Data
  private(set) var workoutPlan: [WorkoutDay] = []

  init() {
    setupWorkoutPlan()
  }

  private func setupWorkoutPlan() {
    let context = coreDataManager.container.viewContext

    // Day 1: Legs (Squat Focus)
    let day1 = WorkoutDay(context: context)
    day1.id = UUID()
    day1.dayNumber = 1
    day1.name = "Legs (Squat Focus)"
    day1.focusArea = "Lower Body"
    day1.type = WorkoutType.legsSquat.rawValue
    day1.order = 1
    day1.estimatedDuration = 60
    day1.exercises = [
      Exercise.create(
        context: context, name: "Barbell Back Squat", sets: 3,
        reps: "4", weight: "80% 1RM", notes: "Focus on form", muscleGroup: .legs),
      Exercise.create(
        context: context, name: "Romanian Deadlift", sets: 3,
        reps: "10", weight: "Body weight", notes: nil, muscleGroup: .legs),
      Exercise.create(
        context: context, name: "Single-Leg Press", sets: 3,
        reps: "15", weight: "Body weight", notes: nil, muscleGroup: .legs),
      Exercise.create(
        context: context, name: "Eccentric Leg Extension", sets: 3,
        reps: "10-12", weight: "Body weight", notes: nil, muscleGroup: .legs),
      Exercise.create(
        context: context, name: "Seated Leg Curl", sets: 3,
        reps: "10-12", weight: "Body weight", notes: nil, muscleGroup: .legs),
      Exercise.create(
        context: context, name: "Standing Calf Raise", sets: 3,
        reps: "10-12", weight: "Body weight", notes: nil, muscleGroup: .legs),
      Exercise.create(
        context: context, name: "Decline Crunches", sets: 2,
        reps: "10-12", weight: "Body weight", notes: nil, muscleGroup: .core),
      Exercise.create(
        context: context, name: "Long-Lever Plank", sets: 2,
        reps: "30 seconds", weight: "Body weight", notes: nil, muscleGroup: .core),
    ]

    // Day 2: Push
    let day2 = WorkoutDay(context: context)
    day2.id = UUID()
    day2.dayNumber = 2
    day2.name = "Push (Upper Body)"
    day2.focusArea = "Chest, Shoulders, Triceps"
    day2.type = WorkoutType.push.rawValue
    day2.order = 2
    day2.estimatedDuration = 60
    day2.exercises = [
      Exercise.create(
        context: context, name: "Barbell Bench Press", sets: 3,
        reps: "8", weight: "72.5% 1RM", notes: nil, muscleGroup: .chest),
      Exercise.create(
        context: context, name: "Machine Shoulder Press", sets: 3,
        reps: "12", weight: "Body weight", notes: nil, muscleGroup: .shoulders),
      Exercise.create(
        context: context, name: "Dips", sets: 3, reps: "12-15",
        weight: "Body weight", notes: nil, muscleGroup: .triceps),
      Exercise.create(
        context: context, name: "Eccentric Skull Crushers", sets: 3,
        reps: "8-10", weight: "Body weight", notes: nil, muscleGroup: .triceps),
      Exercise.create(
        context: context, name: "Egyptian Lateral Raise", sets: 3,
        reps: "12", weight: "Body weight", notes: nil, muscleGroup: .shoulders),
      Exercise.create(
        context: context, name: "Cable Triceps Kickbacks", sets: 3,
        reps: "20-30", weight: "Body weight", notes: nil, muscleGroup: .triceps),
    ]

    // Day 3: Pull
    let day3 = WorkoutDay(context: context)
    day3.id = UUID()
    day3.dayNumber = 3
    day3.name = "Pull (Upper Body)"
    day3.focusArea = "Back, Biceps"
    day3.type = WorkoutType.pull.rawValue
    day3.order = 3
    day3.estimatedDuration = 60
    day3.exercises = [
      Exercise.create(
        context: context, name: "Weighted Pull-Up", sets: 3,
        reps: "6", weight: "Body weight", notes: nil, muscleGroup: .back),
      Exercise.create(
        context: context, name: "Seated Cable Row", sets: 3,
        reps: "10-12", weight: "Body weight", notes: nil, muscleGroup: .back),
      Exercise.create(
        context: context, name: "Cable Pullover", sets: 3,
        reps: "15-20", weight: "Body weight", notes: nil, muscleGroup: .back),
      Exercise.create(
        context: context, name: "Hammer Cheat Curl", sets: 3,
        reps: "8-10", weight: "Body weight", notes: nil, muscleGroup: .biceps),
      Exercise.create(
        context: context, name: "Incline Dumbbell Curl", sets: 2,
        reps: "12-15", weight: "Body weight", notes: nil, muscleGroup: .biceps),
    ]

    // Day 4: Legs (Deadlift Focus)
    let day4 = WorkoutDay(context: context)
    day4.id = UUID()
    day4.dayNumber = 4
    day4.name = "Legs (Deadlift Focus)"
    day4.focusArea = "Lower Body"
    day4.type = WorkoutType.legsDeadlift.rawValue
    day4.order = 4
    day4.estimatedDuration = 60
    day4.exercises = [
      Exercise.create(
        context: context, name: "Barbell Deadlift", sets: 3,
        reps: "3", weight: "80-85% 1RM", notes: nil, muscleGroup: .legs),
      Exercise.create(
        context: context, name: "Hack Squat", sets: 3,
        reps: "10-12", weight: "Body weight", notes: nil, muscleGroup: .legs),
      Exercise.create(
        context: context, name: "Single-Leg Hip Thrust", sets: 3,
        reps: "15", weight: "Body weight", notes: nil, muscleGroup: .legs),
      Exercise.create(
        context: context, name: "Nordic Hamstring Curl", sets: 2,
        reps: "10-12", weight: "Body weight", notes: nil, muscleGroup: .legs),
      Exercise.create(
        context: context, name: "Prisoner Back Extension", sets: 2,
        reps: "10-12", weight: "Body weight", notes: nil, muscleGroup: .back),
      Exercise.create(
        context: context, name: "Single-Leg Calf Raise", sets: 3,
        reps: "8-10", weight: "Body weight", notes: nil, muscleGroup: .legs),
      Exercise.create(
        context: context, name: "Weighted L-Sit Hold", sets: 3,
        reps: "30 seconds", weight: "Body weight", notes: nil, muscleGroup: .core),
    ]

    // Day 5: Push
    let day5 = WorkoutDay(context: context)
    day5.id = UUID()
    day5.dayNumber = 5
    day5.name = "Push (Upper Body)"
    day5.focusArea = "Shoulders, Chest, Triceps"
    day5.type = WorkoutType.push.rawValue
    day5.order = 5
    day5.estimatedDuration = 60
    day5.exercises = [
      Exercise.create(
        context: context, name: "Overhead Press", sets: 4,
        reps: "4", weight: "80% 1RM", notes: nil, muscleGroup: .shoulders),
      Exercise.create(
        context: context, name: "Close-Grip Bench Press", sets: 3,
        reps: "10", weight: "Body weight", notes: nil, muscleGroup: .chest),
      Exercise.create(
        context: context, name: "Cable Crossover", sets: 3,
        reps: "10-12", weight: "Body weight", notes: nil, muscleGroup: .chest),
      Exercise.create(
        context: context, name: "Overhead Triceps Extension",
        sets: 3, reps: "10-12", weight: "Body weight", notes: nil, muscleGroup: .triceps),
      Exercise.create(
        context: context, name: "Lateral Raise 21s", sets: 3,
        reps: "21", weight: "Body weight",
        notes: "7 reps at bottom range, 7 at top range, 7 full range", muscleGroup: .shoulders),
      Exercise.create(
        context: context, name: "Neck Flexion/Extension", sets: 3,
        reps: "10-12", weight: "Body weight", notes: nil, muscleGroup: .shoulders),
    ]

    // Day 6: Pull
    let day6 = WorkoutDay(context: context)
    day6.id = UUID()
    day6.dayNumber = 6
    day6.name = "Pull (Upper Body)"
    day6.focusArea = "Back, Biceps"
    day6.type = WorkoutType.pull.rawValue
    day6.order = 6
    day6.estimatedDuration = 60
    day6.exercises = [
      Exercise.create(
        context: context, name: "Omni-Grip Lat Pulldown", sets: 3,
        reps: "10-12", weight: "Body weight", notes: nil, muscleGroup: .back),
      Exercise.create(
        context: context, name: "Chest-Supported Row", sets: 3,
        reps: "10-12", weight: "Body weight", notes: nil, muscleGroup: .back),
      Exercise.create(
        context: context, name: "Rope Face Pull", sets: 3,
        reps: "15-20", weight: "Body weight", notes: nil, muscleGroup: .back),
      Exercise.create(
        context: context, name: "Incline Dumbbell Shrug", sets: 3,
        reps: "15-20", weight: "Body weight", notes: nil, muscleGroup: .back),
      Exercise.create(
        context: context, name: "Reverse Pec Deck", sets: 2,
        reps: "15+", weight: "Body weight", notes: "Optional", muscleGroup: .back),
      Exercise.create(
        context: context, name: "Pronated/Supinated Curl", sets: 3,
        reps: "10", weight: "Body weight", notes: "Each grip", muscleGroup: .biceps),
    ]

    workoutPlan = [day1, day2, day3, day4, day5, day6]
  }

  // MARK: - Public Methods

  func getCurrentWeekWorkouts() -> AnyPublisher<[WorkoutDay], Never> {
    Just(workoutPlan)
      .eraseToAnyPublisher()
  }

  func getTodayWorkout() -> AnyPublisher<WorkoutDay?, Never> {
    let dayOfWeek = Calendar.current.component(.weekday, from: Date())
    let adjustedDay = (dayOfWeek + 5) % 7
    let todayIndex = adjustedDay == 0 ? 6 : adjustedDay - 1

    let workout = todayIndex < workoutPlan.count ? workoutPlan[todayIndex] : nil

    return Just(workout)
      .eraseToAnyPublisher()
  }

  func getWorkoutForDay(_ day: Int) -> WorkoutDay? {
    workoutPlan.first { $0.dayNumber == day }
  }

  func saveWorkoutSession(_ session: WorkoutSessionData) -> AnyPublisher<Bool, Error> {
    Future<Bool, Error> { promise in
      let context = self.coreDataManager.container.viewContext
      let workoutSession = WorkoutSession(context: context)

      workoutSession.id = UUID()
      workoutSession.date = Date()
      workoutSession.workoutDayId = session.workoutDayId
      workoutSession.duration = Int32(session.duration)
      workoutSession.notes = session.notes

      // Save exercise logs
      for exerciseLog in session.exerciseLogs {
        let log = ExerciseLog(context: context)
        log.id = UUID()
        log.exerciseId = exerciseLog.exerciseId
        log.sets = try? JSONEncoder().encode(exerciseLog.sets)
        log.session = workoutSession
      }

      do {
        try context.save()
        promise(.success(true))
      } catch {
        promise(.failure(error))
      }
    }
    .eraseToAnyPublisher()
  }

  func fetchRecentSessions(limit: Int) -> AnyPublisher<[WorkoutSession], Error> {
    Future<[WorkoutSession], Error> { promise in
      let context = self.coreDataManager.container.viewContext
      let request = NSFetchRequest<WorkoutSession>(entityName: "WorkoutSession")
      request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
      request.fetchLimit = limit

      do {
        let sessions = try context.fetch(request)
        promise(.success(sessions))
      } catch {
        promise(.failure(error))
      }
    }
    .eraseToAnyPublisher()
  }

  func getWorkoutStreak() -> AnyPublisher<Int, Never> {
    fetchRecentSessions(limit: 100)
      .map { sessions in
        var streak = 0
        var lastDate: Date? = nil
        let calendar = Calendar.current

        for session in sessions {
          if let last = lastDate {
            let daysBetween = calendar.dateComponents([.day], from: session.date, to: last).day ?? 0
            if daysBetween > 1 {
              break
            }
          }
          streak += 1
          lastDate = session.date
        }

        return streak
      }
      .replaceError(with: 0)
      .eraseToAnyPublisher()
  }

  func getWeeklyProgress() -> AnyPublisher<Float, Never> {
    fetchRecentSessions(limit: 10)
      .map { sessions in
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()

        let thisWeekSessions = sessions.filter { session in
          session.date >= startOfWeek
        }

        return Float(thisWeekSessions.count) / 6.0
      }
      .replaceError(with: 0.0)
      .eraseToAnyPublisher()
  }
}

// MARK: - Supporting Models
struct WorkoutSessionData {
  let workoutDayId: UUID
  let duration: Int
  let notes: String?
  let exerciseLogs: [ExerciseLogData]
}

struct ExerciseLogData {
  let exerciseId: UUID
  let sets: [ExerciseSet]
}

// MARK: - Extensions
extension NSManagedObject {
  func then(_ block: (Self) -> Void) -> Self {
    block(self)
    return self
  }
}
