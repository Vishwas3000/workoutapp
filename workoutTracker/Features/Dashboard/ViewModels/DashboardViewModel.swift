import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var greeting: String = ""
    @Published var userName: String = "Champion"
    @Published var todayWorkout: WorkoutDay?
    @Published var weeklyProgress: Float = 0.0
    @Published var currentStreak: Int = 0
    @Published var recentSessions: [WorkoutSession] = []
    @Published var totalWorkouts: Int = 0
    @Published var totalMinutes: Int = 0
    @Published var avgDuration: Int = 0
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    // MARK: - Services
    private let workoutService: WorkoutServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userService: UserServiceProtocol
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let refreshSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - Initialization
    init(
        workoutService: WorkoutServiceProtocol = WorkoutService.shared,
        analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared,
        userService: UserServiceProtocol = UserService.shared
    ) {
        self.workoutService = workoutService
        self.analyticsService = analyticsService
        self.userService = userService
        
        setupBindings()
        loadData()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Update greeting based on time
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .map { _ in self.generateGreeting() }
            .assign(to: &$greeting)
        
        // Get user name
        userService.currentUser
            .map { $0?.name ?? "Champion" }
            .assign(to: &$userName)
        
        // Refresh trigger
        refreshSubject
            .sink { [weak self] in
                self?.loadData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    private func loadData() {
        isLoading = true
        
        // Load today's workout
        workoutService.getTodayWorkout()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] workout in
                self?.todayWorkout = workout
            }
            .store(in: &cancellables)
        
        // Load weekly progress
        workoutService.getWeeklyProgress()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.weeklyProgress = progress
            }
            .store(in: &cancellables)
        
        // Load workout streak
        workoutService.getWorkoutStreak()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] streak in
                self?.currentStreak = streak
            }
            .store(in: &cancellables)
        
        // Load recent sessions
        workoutService.fetchRecentSessions(limit: 5)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] sessions in
                    self?.recentSessions = sessions
                    self?.calculateStats(from: sessions)
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func refresh() {
        refreshSubject.send()
    }
    
    func startTodayWorkout() -> WorkoutDay? {
        return todayWorkout
    }
    
    // MARK: - Private Methods
    private func generateGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 0..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        case 17..<21:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }
    
    private func calculateStats(from sessions: [WorkoutSession]) {
        let last30Sessions = Array(sessions.prefix(30))
        
        totalWorkouts = last30Sessions.count
        
        let totalTime = last30Sessions.reduce(0) { $0 + Int($1.duration) }
        totalMinutes = totalTime
        
        avgDuration = totalWorkouts > 0 ? totalTime / totalWorkouts : 0
    }
    
    // MARK: - Formatted Values
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
    
    var progressPercentage: Int {
        Int(weeklyProgress * 100)
    }
    
    var totalHours: String {
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
    }
    
    var avgDurationFormatted: String {
        "\(avgDuration)m"
    }
}
