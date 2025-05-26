import Foundation
import Combine

protocol UserServiceProtocol {
    var currentUser: AnyPublisher<User?, Never> { get }
    func updateUser(_ user: User) -> AnyPublisher<Void, Error>
    func updateUserPreferences(_ preferences: UserPreferences) -> AnyPublisher<Void, Error>
}

class UserService: UserServiceProtocol {
    
    static let shared = UserService()
    
    @Published private var user: User?
    
    var currentUser: AnyPublisher<User?, Never> {
        $user.eraseToAnyPublisher()
    }
    
    private init() {
        loadUser()
    }
    
    private func loadUser() {
        // Load from UserDefaults or Core Data
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.user = user
        } else {
            // Create default user
            self.user = User(
                id: UUID(),
                name: "Champion",
                email: nil,
                preferences: UserPreferences()
            )
        }
    }
    
    func updateUser(_ user: User) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            self.user = user
            
            // Save to UserDefaults
            if let encoded = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(encoded, forKey: "currentUser")
                promise(.success(()))
            } else {
                promise(.failure(UserServiceError.encodingFailed))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateUserPreferences(_ preferences: UserPreferences) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            guard var currentUser = self.user else {
                promise(.failure(UserServiceError.noUser))
                return
            }
            
            currentUser.preferences = preferences
            self.user = currentUser
            
            // Save to UserDefaults
            if let encoded = try? JSONEncoder().encode(currentUser) {
                UserDefaults.standard.set(encoded, forKey: "currentUser")
                promise(.success(()))
            } else {
                promise(.failure(UserServiceError.encodingFailed))
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Models
enum WeightUnit: String, Codable, CaseIterable {
    case lbs = "lbs"
    case kg = "kg"
    
    var conversionFactor: Double {
        switch self {
        case .lbs: return 1.0
        case .kg: return 2.20462
        }
    }
    
    func convert(_ weight: Double, to unit: WeightUnit) -> Double {
        if self == unit { return weight }
        
        switch (self, unit) {
        case (.lbs, .kg):
            return weight / 2.20462
        case (.kg, .lbs):
            return weight * 2.20462
        default:
            return weight
        }
    }
}

struct User: Codable {
    let id: UUID
    var name: String
    var email: String?
    var targetWeight: Double?
    var currentWeight: Double?
    var profileImage: Data?
    var preferences: UserPreferences
}

struct UserPreferences: Codable {
    var preferredWeightUnit: WeightUnit
    var restTimerEnabled: Bool
    var defaultRestTime: Int // seconds
    var soundsEnabled: Bool
    var vibrationsEnabled: Bool
    var darkModeEnabled: Bool
    
    init(
        preferredWeightUnit: WeightUnit = .lbs,
        restTimerEnabled: Bool = true,
        defaultRestTime: Int = 90,
        soundsEnabled: Bool = true,
        vibrationsEnabled: Bool = true,
        darkModeEnabled: Bool = false
    ) {
        self.preferredWeightUnit = preferredWeightUnit
        self.restTimerEnabled = restTimerEnabled
        self.defaultRestTime = defaultRestTime
        self.soundsEnabled = soundsEnabled
        self.vibrationsEnabled = vibrationsEnabled
        self.darkModeEnabled = darkModeEnabled
    }
    
    // Custom decoding to handle missing values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.preferredWeightUnit = try container.decodeIfPresent(WeightUnit.self, forKey: .preferredWeightUnit) ?? .lbs
        self.restTimerEnabled = try container.decodeIfPresent(Bool.self, forKey: .restTimerEnabled) ?? true
        self.defaultRestTime = try container.decodeIfPresent(Int.self, forKey: .defaultRestTime) ?? 90
        self.soundsEnabled = try container.decodeIfPresent(Bool.self, forKey: .soundsEnabled) ?? true
        self.vibrationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .vibrationsEnabled) ?? true
        self.darkModeEnabled = try container.decodeIfPresent(Bool.self, forKey: .darkModeEnabled) ?? false
    }
}

// MARK: - Errors
enum UserServiceError: LocalizedError {
    case noUser
    case encodingFailed
    
    var errorDescription: String? {
        switch self {
        case .noUser:
            return "No user found"
        case .encodingFailed:
            return "Failed to save user data"
        }
    }
}
