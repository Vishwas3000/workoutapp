
import Foundation
import Combine
import CoreData

protocol AnalyticsServiceProtocol {
    func fetchWeightData(days: Int) -> AnyPublisher<[WeightDataPoint], Error>
    func fetchVolumeData(days: Int) -> AnyPublisher<[VolumeDataPoint], Error>
    func fetchMuscleGroupDistribution(days: Int) -> AnyPublisher<[MuscleGroupData], Error>
    func fetchPersonalRecords() -> AnyPublisher<[PersonalRecord], Error>
    func fetchWorkoutFrequency(days: Int) -> AnyPublisher<[WorkoutFrequencyData], Error>
    func saveWeightEntry(weight: Double, unit: WeightUnit) -> AnyPublisher<Void, Error>
}

class AnalyticsService: AnalyticsServiceProtocol {
    
    static let shared = AnalyticsService()
    private let coreDataManager = PersistenceController.shared
    private let workoutService = WorkoutService.shared
    
    // MARK: - Weight Data
    func fetchWeightData(days: Int) -> AnyPublisher<[WeightDataPoint], Error> {
        Future<[WeightDataPoint], Error> { promise in
            let context = self.coreDataManager.container.viewContext
            let request: NSFetchRequest<WeightEntry> = WeightEntry.fetchRequest()
            
            let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
            request.predicate = NSPredicate(format: "date >= %@", startDate as NSDate)
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            
            do {
                let entries = try context.fetch(request)
                let dataPoints = entries.map { WeightDataPoint(date: $0.date, weight: $0.weight) }
                
                // If no data, generate mock data for demo
                if dataPoints.isEmpty {
                    let mockData = self.generateMockWeightData(days: days)
                    promise(.success(mockData))
                } else {
                    promise(.success(dataPoints))
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Volume Data
    func fetchVolumeData(days: Int) -> AnyPublisher<[VolumeDataPoint], Error> {
        Future<[VolumeDataPoint], Error> { promise in
            let context = self.coreDataManager.container.viewContext
            let request: NSFetchRequest<WorkoutSession> = WorkoutSession.fetchRequest()
            
            let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
            request.predicate = NSPredicate(format: "date >= %@", startDate as NSDate)
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            
            do {
                let sessions = try context.fetch(request)
                var volumeByDate: [Date: Double] = [:]
                
                // Calculate volume for each session
                for session in sessions {
                    if let exerciseLogs = session.exerciseLogs as? Set<ExerciseLog> {
                        let sessionVolume = exerciseLogs.reduce(0.0) { total, log in
                            if let setsData = log.sets,
                               let sets = try? JSONDecoder().decode([ExerciseSet].self, from: setsData) {
                                let exerciseVolume = sets.reduce(0.0) { setTotal, set in
                                    let weight = set.weight ?? 0
                                    let reps = Double(set.reps ?? 0)
                                    return setTotal + (weight * reps)
                                }
                                return total + exerciseVolume
                            }
                            return total
                        }
                        
                        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: session.date)
                        if let date = Calendar.current.date(from: dateComponents) {
                            volumeByDate[date, default: 0] += sessionVolume
                        }
                    }
                }
                
                let dataPoints = volumeByDate.map { VolumeDataPoint(date: $0.key, volume: $0.value) }
                    .sorted { $0.date < $1.date }
                
                // If no data, generate mock data
                if dataPoints.isEmpty {
                    let mockData = self.generateMockVolumeData(days: days)
                    promise(.success(mockData))
                } else {
                    promise(.success(dataPoints))
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Muscle Group Distribution
    func fetchMuscleGroupDistribution(days: Int) -> AnyPublisher<[MuscleGroupData], Error> {
        Future<[MuscleGroupData], Error> { promise in
            let context = self.coreDataManager.container.viewContext
            let request: NSFetchRequest<WorkoutSession> = WorkoutSession.fetchRequest()
            
            let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
            request.predicate = NSPredicate(format: "date >= %@", startDate as NSDate)
            
            do {
                let sessions = try context.fetch(request)
                var muscleGroupSets: [MuscleGroup: Int] = [:]
                
                // Count sets for each muscle group
                for session in sessions {
                    if let workout = self.workoutService.workoutPlan.first(where: { $0.id == session.workoutDayId }) {
                        for exercise in workout.exercises {
                            muscleGroupSets[exercise.muscleGroup, default: 0] += exercise.sets
                        }
                    }
                }
                
                let totalSets = muscleGroupSets.values.reduce(0, +)
                let distribution = muscleGroupSets.map { muscle, sets in
                    MuscleGroupData(
                        muscleGroup: muscle,
                        percentage: totalSets > 0 ? Double(sets) / Double(totalSets) : 0,
                        sets: sets
                    )
                }.sorted { $0.sets > $1.sets }
                
                // If no data, generate mock distribution
                if distribution.isEmpty {
                    let mockData = self.generateMockMuscleGroupData()
                    promise(.success(mockData))
                } else {
                    promise(.success(distribution))
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Personal Records
    func fetchPersonalRecords() -> AnyPublisher<[PersonalRecord], Error> {
        Future<[PersonalRecord], Error> { promise in
            // For now, return mock data
            // In a real app, this would query exercise logs for max weights
            let mockPRs = self.generateMockPersonalRecords()
            promise(.success(mockPRs))
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Workout Frequency
    func fetchWorkoutFrequency(days: Int) -> AnyPublisher<[WorkoutFrequencyData], Error> {
        Future<[WorkoutFrequencyData], Error> { promise in
            let context = self.coreDataManager.container.viewContext
            let request: NSFetchRequest<WorkoutSession> = WorkoutSession.fetchRequest()
            
            let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
            request.predicate = NSPredicate(format: "date >= %@", startDate as NSDate)
            
            do {
                let sessions = try context.fetch(request)
                var frequencyByDay: [String: Int] = [
                    "Mon": 0, "Tue": 0, "Wed": 0, "Thu": 0, "Fri": 0, "Sat": 0, "Sun": 0
                ]
                
                let formatter = DateFormatter()
                formatter.dateFormat = "EEE"
                
                for session in sessions {
                    let dayName = formatter.string(from: session.date)
                    frequencyByDay[dayName, default: 0] += 1
                }
                
                let frequencyData = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].map { day in
                    WorkoutFrequencyData(dayOfWeek: day, count: frequencyByDay[day] ?? 0)
                }
                
                promise(.success(frequencyData))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Save Weight Entry
    func saveWeightEntry(weight: Double, unit: WeightUnit) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            let context = self.coreDataManager.container.viewContext
            let entry = WeightEntry(context: context)
            
            entry.id = UUID()
            entry.date = Date()
            entry.weight = unit == .kg ? weight * 2.20462 : weight // Convert to lbs for storage
            entry.unit = "lbs"
            
            do {
                try context.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Mock Data Generators
    private func generateMockWeightData(days: Int) -> [WeightDataPoint] {
        var data: [WeightDataPoint] = []
        let startWeight = 180.0
        let calendar = Calendar.current
        
        for i in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -days + i + 1, to: Date()) {
                // Simulate gradual weight loss with some fluctuation
                let trend = -0.05 * Double(i) // Losing ~0.05 lbs per day
                let fluctuation = Double.random(in: -1...1)
                let weight = startWeight + trend + fluctuation
                data.append(WeightDataPoint(date: date, weight: weight))
            }
        }
        
        return data
    }
    
    private func generateMockVolumeData(days: Int) -> [VolumeDataPoint] {
        var data: [VolumeDataPoint] = []
        let calendar = Calendar.current
        
        for i in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -days + i + 1, to: Date()) {
                // Skip some days (rest days)
                if i % 7 != 6 { // Not Sunday
                    let baseVolume = 20000.0
                    let trend = 100.0 * Double(i) // Gradual increase
                    let variation = Double.random(in: -2000...2000)
                    let volume = baseVolume + trend + variation
                    data.append(VolumeDataPoint(date: date, volume: volume))
                }
            }
        }
        
        return data
    }
    
    private func generateMockMuscleGroupData() -> [MuscleGroupData] {
        return [
            MuscleGroupData(muscleGroup: .legs, percentage: 0.25, sets: 48),
            MuscleGroupData(muscleGroup: .chest, percentage: 0.20, sets: 36),
            MuscleGroupData(muscleGroup: .back, percentage: 0.20, sets: 36),
            MuscleGroupData(muscleGroup: .shoulders, percentage: 0.15, sets: 27),
            MuscleGroupData(muscleGroup: .arms, percentage: 0.15, sets: 27),
            MuscleGroupData(muscleGroup: .core, percentage: 0.05, sets: 12)
        ]
    }
    
    private func generateMockPersonalRecords() -> [PersonalRecord] {
        let calendar = Calendar.current
        return [
            PersonalRecord(
                exercise: "Barbell Back Squat",
                weight: 315,
                reps: 1,
                date: calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            ),
            PersonalRecord(
                exercise: "Barbell Bench Press",
                weight: 225,
                reps: 1,
                date: calendar.date(byAdding: .day, value: -14, to: Date()) ?? Date()
            ),
            PersonalRecord(
                exercise: "Barbell Deadlift",
                weight: 405,
                reps: 1,
                date: calendar.date(byAdding: .day, value: -21, to: Date()) ?? Date()
            ),
            PersonalRecord(
                exercise: "Overhead Press",
                weight: 135,
                reps: 5,
                date: calendar.date(byAdding: .day, value: -28, to: Date()) ?? Date()
            ),
            PersonalRecord(
                exercise: "Weighted Pull-Up",
                weight: 45,
                reps: 8,
                date: calendar.date(byAdding: .day, value: -10, to: Date()) ?? Date()
            )
        ]
    }
}
