import UIKit
import Combine

class DashboardViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = DashboardViewModel()
    private var cancellables = Set<AnyCancellable>()
    private weak var coordinator: DashboardCoordinator?
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let refreshControl = UIRefreshControl()
    
    private let headerView = DashboardHeaderView()
    private let todayWorkoutCard = TodayWorkoutCard()
    private let weekProgressCard = WeekProgressCard()
    private let quickStatsCard = QuickStatsCard()
    private let recentWorkoutsCard = RecentWorkoutsCard()
    
    // MARK: - Initialization
    init(coordinator: DashboardCoordinator? = nil) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refresh()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Dashboard"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Add cards
        let cards: [UIView] = [headerView, todayWorkoutCard, weekProgressCard, quickStatsCard, recentWorkoutsCard]
        cards.forEach { card in
            card.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(card)
        }
        
        // Set delegates
        todayWorkoutCard.delegate = self
        recentWorkoutsCard.delegate = self
        
        // Setup constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            todayWorkoutCard.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            todayWorkoutCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            todayWorkoutCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            weekProgressCard.topAnchor.constraint(equalTo: todayWorkoutCard.bottomAnchor, constant: 16),
            weekProgressCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            weekProgressCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            quickStatsCard.topAnchor.constraint(equalTo: weekProgressCard.bottomAnchor, constant: 16),
            quickStatsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            quickStatsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            recentWorkoutsCard.topAnchor.constraint(equalTo: quickStatsCard.bottomAnchor, constant: 16),
            recentWorkoutsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            recentWorkoutsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            recentWorkoutsCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupBindings() {
        // Header bindings
        Publishers.CombineLatest3(
            viewModel.$greeting,
            viewModel.$userName,
            Just(viewModel.formattedDate)
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] greeting, userName, date in
            self?.headerView.configure(greeting: greeting, userName: userName, date: date)
        }
        .store(in: &cancellables)
        
        // Today's workout
        viewModel.$todayWorkout
            .receive(on: DispatchQueue.main)
            .sink { [weak self] workout in
                self?.todayWorkoutCard.configure(with: workout)
            }
            .store(in: &cancellables)
        
        // Weekly progress
        Publishers.CombineLatest(
            viewModel.$weeklyProgress,
            viewModel.$currentStreak
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] progress, streak in
            self?.weekProgressCard.configure(progress: progress, streak: streak)
        }
        .store(in: &cancellables)
        
        // Quick stats
        viewModel.$totalWorkouts
            .combineLatest(viewModel.$totalMinutes, viewModel.$avgDuration)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] workouts, totalMinutes, avgDuration in
                guard let self = self else { return }
                
                // Calculate formatted values
                let hours = totalMinutes / 60
                let minutes = totalMinutes % 60
                let totalTimeFormatted = minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
                let avgDurationFormatted = "\(avgDuration)m"
                
                self.quickStatsCard.configure(
                    totalWorkouts: workouts,
                    totalTime: totalTimeFormatted,
                    avgDuration: avgDurationFormatted
                )
            }
            .store(in: &cancellables)
        
        // Recent workouts
        viewModel.$recentSessions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessions in
                self?.recentWorkoutsCard.configure(with: sessions)
            }
            .store(in: &cancellables)
        
        // Loading state
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        // Error handling
        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    @objc private func handleRefresh() {
        viewModel.refresh()
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - TodayWorkoutCardDelegate
extension DashboardViewController: TodayWorkoutCardDelegate {
    func didTapStartWorkout(workout: WorkoutDay) {
        coordinator?.showWorkoutSession(workout: workout)
    }
}

// MARK: - RecentWorkoutsCardDelegate
extension DashboardViewController: RecentWorkoutsCardDelegate {
    func didTapViewAllWorkouts() {
        tabBarController?.selectedIndex = 2
    }
    
    func didSelectWorkoutSession(_ session: WorkoutSession) {
        // Show workout details
        coordinator?.showWorkoutDetails(session: session)
    }
}
