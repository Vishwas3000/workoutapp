import Combine
import CoreData
import Foundation

protocol AnalyticsServiceProtocol {
  func getWeightData(for exerciseId: UUID) -> AnyPublisher<[WeightDataPoint], Never>
  func getVolumeData(for exerciseId: UUID) -> AnyPublisher<[VolumeDataPoint], Never>
  func getMuscleGroupDistribution() -> AnyPublisher<[MuscleGroupData], Never>
  func getPersonalRecords() -> AnyPublisher<[PersonalRecord], Never>
  func getWorkoutFrequency() -> AnyPublisher<[WorkoutFrequencyData], Never>
  func saveWeightEntry(weight: Double, unit: WeightUnit) -> AnyPublisher<Void, Never>
}

class AnalyticsService: AnalyticsServiceProtocol {

  static let shared = AnalyticsService()
  private let coreDataManager = PersistenceController.shared

  // MARK: - Weight Data

  func getWeightData(for exerciseId: UUID) -> AnyPublisher<[WeightDataPoint], Never> {
    Future<[WeightDataPoint], Never> { promise in
      let context = self.coreDataManager.container.viewContext
      let request = NSFetchRequest<ExerciseLog>(entityName: "ExerciseLog")
      request.predicate = NSPredicate(format: "exerciseId == %@", exerciseId as CVarArg)
      request.sortDescriptors = [NSSortDescriptor(key: "session.date", ascending: true)]

      do {
        let logs = try context.fetch(request)
        let dataPoints = logs.compactMap { log -> WeightDataPoint? in
          guard let sets = try? JSONDecoder().decode([ExerciseSet].self, from: log.sets ?? Data()),
            let date = log.session?.date
          else { return nil }

          let maxWeight = sets.compactMap { $0.weight }.max() ?? 0
          return WeightDataPoint(date: date, weight: maxWeight)
        }
        promise(.success(dataPoints))
      } catch {
        promise(.success([]))
      }
    }
    .eraseToAnyPublisher()
  }

  // MARK: - Volume Data

  func getVolumeData(for exerciseId: UUID) -> AnyPublisher<[VolumeDataPoint], Never> {
    Future<[VolumeDataPoint], Never> { promise in
      let context = self.coreDataManager.container.viewContext
      let request = NSFetchRequest<ExerciseLog>(entityName: "ExerciseLog")
      request.predicate = NSPredicate(format: "exerciseId == %@", exerciseId as CVarArg)
      request.sortDescriptors = [NSSortDescriptor(key: "session.date", ascending: true)]

      do {
        let logs = try context.fetch(request)
        let dataPoints = logs.compactMap { log -> VolumeDataPoint? in
          guard let sets = try? JSONDecoder().decode([ExerciseSet].self, from: log.sets ?? Data()),
            let date = log.session?.date
          else { return nil }

          let totalVolume = sets.reduce(0.0) { sum, set in
            let reps = Double(set.reps) ?? 0
            let weight = set.weight ?? 0
            return sum + (reps * weight)
          }

          return VolumeDataPoint(date: date, volume: totalVolume)
        }
        promise(.success(dataPoints))
      } catch {
        promise(.success([]))
      }
    }
    .eraseToAnyPublisher()
  }

  // MARK: - Muscle Group Distribution

  func getMuscleGroupDistribution() -> AnyPublisher<[MuscleGroupData], Never> {
    Future<[MuscleGroupData], Never> { promise in
      let context = self.coreDataManager.container.viewContext
      let request = NSFetchRequest<WorkoutSession>(entityName: "WorkoutSession")
      request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
      request.fetchLimit = 30  // Last 30 sessions

      do {
        let sessions = try context.fetch(request)
        var muscleGroupCounts: [MuscleGroup: Int] = [:]

        for session in sessions {
          guard let workoutDay = self.getWorkoutDay(for: session.workoutDayId) else { continue }

          for exercise in workoutDay.exercises {
            if let muscleGroup = MuscleGroup(rawValue: exercise.muscleGroup) {
              muscleGroupCounts[muscleGroup, default: 0] += 1
            }
          }
        }

        let total = Double(muscleGroupCounts.values.reduce(0, +))
        let distribution = muscleGroupCounts.map { (group, count) in
          MuscleGroupData(
            muscleGroup: group,
            percentage: total > 0 ? Double(count) / total : 0,
            sets: count
          )
        }

        promise(.success(distribution))
      } catch {
        promise(.success([]))
      }
    }
    .eraseToAnyPublisher()
  }

  // MARK: - Personal Records

  func getPersonalRecords() -> AnyPublisher<[PersonalRecord], Never> {
    Future<[PersonalRecord], Never> { promise in
      let context = self.coreDataManager.container.viewContext
      let request = NSFetchRequest<ExerciseLog>(entityName: "ExerciseLog")

      do {
        let logs = try context.fetch(request)
        var records: [String: PersonalRecord] = [:]

        for log in logs {
          guard let sets = try? JSONDecoder().decode([ExerciseSet].self, from: log.sets ?? Data()),
            let exercise = self.getExercise(for: log.exerciseId)
          else { continue }

          let maxWeight = sets.compactMap { $0.weight }.max() ?? 0
          let currentRecord = records[exercise.name]?.weight ?? 0

          if maxWeight > currentRecord {
            records[exercise.name] = PersonalRecord(
              exercise: exercise.name,
              weight: maxWeight,
              reps: Int(sets.first?.reps ?? "0") ?? 0,
              date: log.session?.date ?? Date()
            )
          }
        }

        promise(.success(Array(records.values)))
      } catch {
        promise(.success([]))
      }
    }
    .eraseToAnyPublisher()
  }

  // MARK: - Workout Frequency

  func getWorkoutFrequency() -> AnyPublisher<[WorkoutFrequencyData], Never> {
    Future<[WorkoutFrequencyData], Never> { promise in
      let context = self.coreDataManager.container.viewContext
      let request = NSFetchRequest<WorkoutSession>(entityName: "WorkoutSession")
      request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

      do {
        let sessions = try context.fetch(request)
        let calendar = Calendar.current
        let today = Date()
        let startDate = calendar.date(byAdding: .day, value: -30, to: today) ?? today

        var frequencyData: [String: Int] = [:]

        for session in sessions {
          let sessionDate = session.date
          guard sessionDate >= startDate else { continue }

          let dayOfWeek = calendar.weekdaySymbols[
            calendar.component(.weekday, from: sessionDate) - 1]
          frequencyData[dayOfWeek, default: 0] += 1
        }

        let dataPoints = frequencyData.map { (dayOfWeek, count) in
          WorkoutFrequencyData(dayOfWeek: dayOfWeek, count: count)
        }.sorted { $0.dayOfWeek < $1.dayOfWeek }

        promise(.success(dataPoints))
      } catch {
        promise(.success([]))
      }
    }
    .eraseToAnyPublisher()
  }

  // MARK: - Weight Entry

  func saveWeightEntry(weight: Double, unit: WeightUnit) -> AnyPublisher<Void, Never> {
    Future<Void, Never> { promise in
      let context = self.coreDataManager.container.viewContext
      let weightEntry = WeightEntry(context: context)
      weightEntry.id = UUID()
      weightEntry.weight = weight
      weightEntry.unit = unit.rawValue
      weightEntry.date = Date()

      do {
        try context.save()
        promise(.success(()))
      } catch {
        context.rollback()
        promise(.success(()))
      }
    }
    .eraseToAnyPublisher()
  }

  // MARK: - Helper Methods

  private func getWorkoutDay(for id: UUID?) -> WorkoutDay? {
    guard let id = id else { return nil }
    let context = coreDataManager.container.viewContext
    let request = NSFetchRequest<WorkoutDay>(entityName: "WorkoutDay")
    request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
    request.fetchLimit = 1

    return try? context.fetch(request).first
  }

  private func getExercise(for id: UUID?) -> Exercise? {
    guard let id = id else { return nil }
    let context = coreDataManager.container.viewContext
    let request = NSFetchRequest<Exercise>(entityName: "Exercise")
    request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
    request.fetchLimit = 1

    return try? context.fetch(request).first
  }
}

// MARK: - Mock Data Generation

extension AnalyticsService {
  static func generateMockWeightData() -> [WeightDataPoint] {
    let calendar = Calendar.current
    let today = Date()

    return (0..<30).map { daysAgo in
      let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) ?? today
      let weight = Double.random(in: 100...150)
      return WeightDataPoint(date: date, weight: weight)
    }
  }

  static func generateMockVolumeData() -> [VolumeDataPoint] {
    let calendar = Calendar.current
    let today = Date()

    return (0..<30).map { daysAgo in
      let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) ?? today
      let volume = Double.random(in: 1000...2000)
      return VolumeDataPoint(date: date, volume: volume)
    }
  }

  static func generateMockMuscleGroupData() -> [MuscleGroupData] {
    [
      MuscleGroupData(muscleGroup: .chest, percentage: 0.25, sets: 12),
      MuscleGroupData(muscleGroup: .back, percentage: 0.20, sets: 10),
      MuscleGroupData(muscleGroup: .legs, percentage: 0.30, sets: 15),
      MuscleGroupData(muscleGroup: .shoulders, percentage: 0.15, sets: 8),
      MuscleGroupData(muscleGroup: .arms, percentage: 0.10, sets: 6),
    ]
  }

  static func generateMockPersonalRecords() -> [PersonalRecord] {
    let calendar = Calendar.current
    let today = Date()

    return [
      PersonalRecord(
        exercise: "Bench Press",
        weight: 225,
        reps: 5,
        date: calendar.date(byAdding: .day, value: -5, to: today) ?? today
      ),
      PersonalRecord(
        exercise: "Squat",
        weight: 315,
        reps: 3,
        date: calendar.date(byAdding: .day, value: -3, to: today) ?? today
      ),
      PersonalRecord(
        exercise: "Deadlift",
        weight: 405,
        reps: 1,
        date: calendar.date(byAdding: .day, value: -1, to: today) ?? today
      ),
    ]
  }

  static func generateMockWorkoutFrequency() -> [WorkoutFrequencyData] {
    let calendar = Calendar.current
    let today = Date()

    return (0..<30).map { daysAgo in
      let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) ?? today
      let dayOfWeek = calendar.weekdaySymbols[calendar.component(.weekday, from: date) - 1]
      let count = Int.random(in: 0...2)
      return WorkoutFrequencyData(dayOfWeek: dayOfWeek, count: count)
    }
  }
}
