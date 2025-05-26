import UIKit
import CoreData
import Combine

class WorkoutSessionViewController: UIViewController {
    
    // MARK: - Properties
    private let workoutDay: WorkoutDay
    private let viewModel: WorkoutSessionViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let startButton = UIButton(type: .system)
    private let timerLabel = UILabel()
    private var timer: Timer?
    private var elapsedTime: TimeInterval = 0
    
    // MARK: - Initialization
    init(workoutDay: WorkoutDay) {
        self.workoutDay = workoutDay
        self.viewModel = WorkoutSessionViewModel(workoutDay: workoutDay)
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
        startTimer()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = workoutDay.type
        view.backgroundColor = .systemBackground
        
        // Setup tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ExerciseCell.self, forCellReuseIdentifier: "ExerciseCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Setup timer label
        timerLabel.font = .monospacedDigitSystemFont(ofSize: 24, weight: .medium)
        timerLabel.textAlignment = .center
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timerLabel)
        
        // Setup start button
        startButton.setTitle("Start Workout", for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        startButton.backgroundColor = .systemBlue
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 25
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        view.addSubview(startButton)
        
        NSLayoutConstraint.activate([
            timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            timerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            timerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -16),
            
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupBindings() {
        viewModel.$isWorkoutActive
            .sink { [weak self] isActive in
                self?.startButton.setTitle(isActive ? "End Workout" : "Start Workout", for: .normal)
                self?.startButton.backgroundColor = isActive ? .systemRed : .systemBlue
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime += 1
            self.updateTimerLabel()
        }
    }
    
    private func updateTimerLabel() {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        timerLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    // MARK: - Actions
    @objc private func startButtonTapped() {
        if viewModel.isWorkoutActive {
            // End workout
            viewModel.endWorkout()
            timer?.invalidate()
            timer = nil
            dismiss(animated: true)
        } else {
            // Start workout
            viewModel.startWorkout()
        }
    }
}

// MARK: - UITableViewDataSource
extension WorkoutSessionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutDay.exercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseCell", for: indexPath) as! ExerciseCell
        let exercise = Array(workoutDay.exercises)[indexPath.row]
        cell.configure(with: exercise)
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension WorkoutSessionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Exercises"
    }
}

// MARK: - ExerciseCellDelegate
extension WorkoutSessionViewController: ExerciseCellDelegate {
    func didCompleteSet(_ set: CompletedSet, for exercise: Exercise) {
        viewModel.addCompletedSet(set, for: exercise)
    }
}
