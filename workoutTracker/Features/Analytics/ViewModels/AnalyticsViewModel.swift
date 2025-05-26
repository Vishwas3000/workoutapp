
import Foundation
import Combine

class AnalyticsViewModel: ObservableObject {
    
    // MARK: - Time Period
    enum TimePeriod: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        
        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .year: return 365
            }
        }
    }
    
    // MARK: - Published Properties
    @Published var selectedPeriod: TimePeriod = .week
    @Published var weightData: [WeightDataPoint] = []
    @Published var volumeData: [VolumeDataPoint] = []
    @Published var muscleGroupData: [MuscleGroupData] = []
    @Published var personalRecords: [PersonalRecord] = []
    @Published var workoutFrequency: [WorkoutFrequencyData] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    // Weight stats
    @Published var currentWeight: Double = 0.0
    @Published var weightChange: Double = 0.0
    @Published var targetWeight: Double = 0.0
    
    // Volume stats
    @Published var totalVolume: Double = 0.0
    @Published var avgVolume: Double = 0.0
    @Published var volumeTrend: Double = 0.0
    
    // MARK: - Services
    private let analyticsService: AnalyticsServiceProtocol
    private let workoutService: WorkoutServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(
        analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared,
        workoutService: WorkoutServiceProtocol = WorkoutService.shared
    ) {
        self.analyticsService = analyticsService
        self.workoutService = workoutService
        
        setupBindings()
        loadData()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Reload data when period changes
        $selectedPeriod
            .dropFirst()
            .sink { [weak self] _ in
                self?.loadData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    func loadData() {
        isLoading = true
        error = nil
        
        let days = selectedPeriod.days
        
        // Load all analytics data
        Publishers.CombineLatest4(
            analyticsService.fetchWeightData(days: days),
            analyticsService.fetchVolumeData(days: days),
            analyticsService.fetchMuscleGroupDistribution(days: days),
            analyticsService.fetchPersonalRecords()
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            },
            receiveValue: { [weak self] weightData, volumeData, muscleData, prData in
                self?.processAnalyticsData(
                    weight: weightData,
                    volume: volumeData,
                    muscle: muscleData,
                    pr: prData
                )
            }
        )
        .store(in: &cancellables)
        
        // Load workout frequency
        analyticsService.fetchWorkoutFrequency(days: days)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] frequency in
                    self?.workoutFrequency = frequency
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Data Processing
    private func processAnalyticsData(
        weight: [WeightDataPoint],
        volume: [VolumeDataPoint],
        muscle: [MuscleGroupData],
        pr: [PersonalRecord]
    ) {
        // Weight data
        self.weightData = weight
        if let latest = weight.last {
            currentWeight = latest.weight
        }
        if let first = weight.first, let last = weight.last {
            weightChange = last.weight - first.weight
        }
        
        // Volume data
        self.volumeData = volume
        totalVolume = volume.reduce(0) { $0 + $1.volume }
        avgVolume = volume.isEmpty ? 0 : totalVolume / Double(volume.count)
        
        // Calculate volume trend
        if volume.count >= 2 {
            let recentAvg = volume.suffix(volume.count / 2).reduce(0) { $0 + $1.volume } / Double(volume.count / 2)
            let oldAvg = volume.prefix(volume.count / 2).reduce(0) { $0 + $1.volume } / Double(volume.count / 2)
            volumeTrend = oldAvg > 0 ? ((recentAvg - oldAvg) / oldAvg) * 100 : 0
        }
        
        // Muscle group data
        self.muscleGroupData = muscle
        
        // Personal records
        self.personalRecords = pr.sorted { $0.date > $1.date }
    }
    
    // MARK: - Public Methods
    func refresh() {
        loadData()
    }
    
    func addWeightEntry(weight: Double, unit: WeightUnit = .lbs) {
        analyticsService.saveWeightEntry(weight: weight, unit: unit)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    self?.loadData()
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Formatted Values
    var weightChangeFormatted: String {
        let sign = weightChange >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", weightChange)) lbs"
    }
    
    var volumeTrendFormatted: String {
        let sign = volumeTrend >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", volumeTrend))%"
    }
    
    var totalVolumeFormatted: String {
        if totalVolume >= 1000000 {
            return String(format: "%.1fM", totalVolume / 1000000)
        } else if totalVolume >= 1000 {
            return String(format: "%.1fK", totalVolume / 1000)
        } else {
            return String(format: "%.0f", totalVolume)
        }
    }
}

// MARK: - Supporting Models
struct WeightDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
}

struct VolumeDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let volume: Double
}

struct MuscleGroupData: Identifiable {
    let id = UUID()
    let muscleGroup: MuscleGroup
    let percentage: Double
    let sets: Int
}

struct PersonalRecord: Identifiable {
    let id = UUID()
    let exercise: String
    let weight: Double
    let reps: Int
    let date: Date
}

struct WorkoutFrequencyData: Identifiable {
    let id = UUID()
    let dayOfWeek: String
    let count: Int
}
