//
//  CoreDataModels.swift
//  workoutTracker
//
//  Created by Vishwas Prakash on 25/05/25.
//

import Foundation
import CoreData

// MARK: - WorkoutSession
@objc(WorkoutSession)
public class WorkoutSession: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var workoutDayId: UUID
    @NSManaged public var duration: Int32
    @NSManaged public var notes: String?
    @NSManaged public var exerciseLogs: NSSet?
}

extension WorkoutSession {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutSession> {
        return NSFetchRequest<WorkoutSession>(entityName: "WorkoutSession")
    }
    
    @objc(addExerciseLogsObject:)
    @NSManaged public func addToExerciseLogs(_ value: ExerciseLog)
    
    @objc(removeExerciseLogsObject:)
    @NSManaged public func removeFromExerciseLogs(_ value: ExerciseLog)
    
    @objc(addExerciseLogs:)
    @NSManaged public func addToExerciseLogs(_ values: NSSet)
    
    @objc(removeExerciseLogs:)
    @NSManaged public func removeFromExerciseLogs(_ values: NSSet)
}

// MARK: - ExerciseLog
@objc(ExerciseLog)
public class ExerciseLog: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var exerciseId: UUID
    @NSManaged public var sets: Data? // JSON encoded [ExerciseSet]
    @NSManaged public var session: WorkoutSession?
}

extension ExerciseLog {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseLog> {
        return NSFetchRequest<ExerciseLog>(entityName: "ExerciseLog")
    }
}

// MARK: - WeightEntry
@objc(WeightEntry)
public class WeightEntry: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var weight: Double
    @NSManaged public var unit: String
}

extension WeightEntry {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeightEntry> {
        return NSFetchRequest<WeightEntry>(entityName: "WeightEntry")
    }
}

// MARK: - PersonalRecordEntry
@objc(PersonalRecordEntry)
public class PersonalRecordEntry: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var exerciseName: String
    @NSManaged public var weight: Double
    @NSManaged public var reps: Int16
    @NSManaged public var date: Date
}

extension PersonalRecordEntry {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersonalRecordEntry> {
        return NSFetchRequest<PersonalRecordEntry>(entityName: "PersonalRecordEntry")
    }
}
