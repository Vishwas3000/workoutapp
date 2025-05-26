
import Foundation
import Combine
import CoreData

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
    let workoutPlan: [WorkoutDay] = [
        WorkoutDay(
            dayNumber: 1,
            name: "Legs (Squat Focus)",
            focusArea: "Lower Body",
            exercises: [
                Exercise(name: "Barbell Back Squat", sets: 3, reps: "4", intensity: "80% 1RM", muscleGroup: .legs, videoTimestamp: 0),
                Exercise(name: "Romanian Deadlift", sets: 3, reps: "10", muscleGroup: .legs, videoTimestamp: 120),
                Exercise(name: "Single-Leg Press", sets: 3, reps: "15", muscleGroup: .legs, videoTimestamp: 240),
                Exercise(name: "Eccentric Leg Extension", sets: 3, reps: "10-12", muscleGroup: .legs, videoTimestamp: 360),
                Exercise(name: "Seated Leg Curl", sets: 3, reps: "10-12", muscleGroup: .legs, videoTimestamp: 480),
                Exercise(name: "Standing Calf Raise", sets: 3, reps: "10-12", muscleGroup: .legs, videoTimestamp: 600),
                Exercise(name: "Decline Crunches", sets: 2, reps: "10-12", muscleGroup: .core, videoTimestamp: 720),
                Exercise(name: "Long-Lever Plank", sets: 2, reps: "30 seconds", muscleGroup: .core, videoTimestamp: 840)
            ],
            type: .legs
        ),
        WorkoutDay(
            dayNumber: 2,
            name: "Push (Upper Body)",
            focusArea: "Chest, Shoulders, Triceps",
            exercises: [
                Exercise(name: "Barbell Bench Press", sets: 3, reps: "8", intensity: "72.5% 1RM", muscleGroup: .chest, videoTimestamp: 960),
                Exercise(name: "Machine Shoulder Press", sets: 3, reps: "12", muscleGroup: .shoulders, videoTimestamp: 1080),
                Exercise(name: "Dips", sets: 3, reps: "12-15", muscleGroup: .chest, videoTimestamp: 1200),
                Exercise(name: "Eccentric Skull Crushers", sets: 3, reps: "8-10", muscleGroup: .arms, videoTimestamp: 1320),
                Exercise(name: "Egyptian Lateral Raise", sets: 3, reps: "12", muscleGroup: .shoulders, videoTimestamp: 1440),
                Exercise(name: "Cable Triceps Kickbacks", sets: 3, reps: "20-30", muscleGroup: .arms, videoTimestamp: 1560)
            ],
            type: .push
        ),
        WorkoutDay(
            dayNumber: 3,
            name: "Pull (Upper Body)",
            focusArea: "Back, Biceps",
            exercises: [
                Exercise(name: "Weighted Pull-Up", sets: 3, reps: "6", muscleGroup: .back, videoTimestamp: 1680),
                Exercise(name: "Seated Cable Row", sets: 3, reps: "10-12", muscleGroup: .back, videoTimestamp: 1800),
                Exercise(name: "Cable Pullover", sets: 3, reps: "15-20", muscleGroup: .back, videoTimestamp: 1920),
                Exercise(name: "Hammer Cheat Curl", sets: 3, reps: "8-10", muscleGroup: .arms, videoTimestamp: 2040),
                Exercise(name: "Incline Dumbbell Curl", sets: 2, reps: "12-15", muscleGroup: .arms, videoTimestamp: 2160)
            ],
            type: .pull
        ),
        WorkoutDay(
            dayNumber: 4,
            name: "Legs (Deadlift Focus)",
            focusArea: "Lower Body",
            exercises: [
                Exercise(name: "Barbell Deadlift", sets: 3, reps: "3", intensity: "80-85% 1RM", muscleGroup: .legs, videoTimestamp: 2280),
                Exercise(name: "Hack Squat", sets: 3, reps: "10-12", muscleGroup: .legs, videoTimestamp: 2400),
                Exercise(name: "Single-Leg Hip Thrust", sets: 3, reps: "15", muscleGroup: .legs, videoTimestamp: 2520),
                Exercise(name: "Nordic Hamstring Curl", sets: 2, reps: "10-12", muscleGroup: .legs, videoTimestamp: 2640),
                Exercise(name: "Prisoner Back Extension", sets: 2, reps: "10-12", muscleGroup: .back, videoTimestamp: 2760),
                Exercise(name: "Single-Leg Calf Raise", sets: 3, reps: "8-10", muscleGroup: .legs, videoTimestamp: 2880),
                Exercise(name: "Weighted L-Sit Hold", sets: 3, reps: "30 seconds", muscleGroup: .core, videoTimestamp: 3000)
            ],
            type: .legs
        ),
        WorkoutDay(
            dayNumber: 5,
            name: "Push (Upper Body)",
            focusArea: "Shoulders, Chest, Triceps",
            exercises: [
                Exercise(name: "Overhead Press", sets: 4, reps: "4", intensity: "80% 1RM", muscleGroup: .shoulders, videoTimestamp: 3120),
                Exercise(name: "Close-Grip Bench Press", sets: 3, reps: "10", muscleGroup: .chest, videoTimestamp: 3240),
                Exercise(name: "Cable Crossover", sets: 3, reps: "10-12", muscleGroup: .chest, videoTimestamp: 3360),
                Exercise(name: "Overhead Triceps Extension", sets: 3, reps: "10-12", muscleGroup: .arms, videoTimestamp: 3480),
                Exercise(name: "Lateral Raise 21s", sets: 3, reps: "21", muscleGroup: .shoulders, videoTimestamp: 3600),
                Exercise(name: "Neck Flexion/Extension", sets: 3, reps: "10-12", muscleGroup: .shoulders, videoTimestamp: 3720)
            ],
            type: .push
        ),
        WorkoutDay(
            dayNumber: 6,
            name: "Pull (Upper Body)",
            focusArea: "Back, Biceps",
            exercises: [
                Exercise(name: "Omni-Grip Lat Pulldown", sets: 3, reps: "10-12", muscleGroup: .back, videoTimestamp: 3840),
                Exercise(name: "Chest-Supported Row", sets: 3, reps: "10-12", muscleGroup: .back, videoTimestamp: 3960),
                Exercise(name: "Rope Face Pull", sets: 3, reps: "15-20", muscleGroup: .back, videoTimestamp: 4080),
                Exercise(name: "Incline Dumbbell Shrug", sets: 3, reps: "15-20", muscleGroup: .back, videoTimestamp: 4200),
                Exercise(name: "Reverse Pec Deck", sets: 2, reps: "15+", intensity: "Optional", muscleGroup: .back, videoTimestamp: 4320),
                Exercise(name: "Pronated/Supinated Curl", sets: 3, reps: "10 each", intensity: "Optional", muscleGroup: .arms, videoTimestamp: 4440)
            ],
            type: .pull
        )
    ]
    
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
            let request: NSFetchRequest<WorkoutSession> = WorkoutSession.fetchRequest()
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
