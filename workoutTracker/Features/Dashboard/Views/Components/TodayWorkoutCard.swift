import UIKit

protocol TodayWorkoutCardDelegate: AnyObject {
  func didTapStartWorkout(workout: WorkoutDay)
}

class TodayWorkoutCard: UIView {

  // MARK: - Properties
  weak var delegate: TodayWorkoutCardDelegate?
  private var currentWorkout: WorkoutDay?

  // MARK: - UI Components
  private let containerView = UIView()
  private let headerStackView = UIStackView()
  private let headerLabel = UILabel()
  private let workoutIconLabel = UILabel()
  private let workoutNameLabel = UILabel()
  private let detailsStackView = UIStackView()
  private let exerciseCountLabel = UILabel()
  private let durationLabel = UILabel()
  private let muscleGroupsLabel = UILabel()
  private let startButton = UIButton(type: .system)
  private let restDayView = RestDayView()

  // MARK: - Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup
  private func setupUI() {
    // Container setup
    containerView.backgroundColor = .secondarySystemBackground
    containerView.layer.cornerRadius = 16
    containerView.layer.shadowColor = UIColor.black.cgColor
    containerView.layer.shadowOpacity = 0.1
    containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
    containerView.layer.shadowRadius = 8
    containerView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(containerView)

    // Header setup
    headerStackView.axis = .horizontal
    headerStackView.alignment = .center
    headerStackView.spacing = 8
    headerStackView.translatesAutoresizingMaskIntoConstraints = false

    headerLabel.text = "TODAY'S WORKOUT"
    headerLabel.font = .systemFont(ofSize: 14, weight: .semibold)
    headerLabel.textColor = .systemBlue

    workoutIconLabel.font = .systemFont(ofSize: 40)
    workoutIconLabel.translatesAutoresizingMaskIntoConstraints = false

    headerStackView.addArrangedSubview(headerLabel)
    headerStackView.addArrangedSubview(UIView())  // Spacer

    // Workout name
    workoutNameLabel.font = .systemFont(ofSize: 24, weight: .bold)
    workoutNameLabel.numberOfLines = 0
    workoutNameLabel.translatesAutoresizingMaskIntoConstraints = false

    // Details stack
    detailsStackView.axis = .vertical
    detailsStackView.spacing = 8
    detailsStackView.translatesAutoresizingMaskIntoConstraints = false

    exerciseCountLabel.font = .systemFont(ofSize: 16, weight: .medium)
    exerciseCountLabel.textColor = .secondaryLabel

    durationLabel.font = .systemFont(ofSize: 16, weight: .medium)
    durationLabel.textColor = .secondaryLabel

    muscleGroupsLabel.font = .systemFont(ofSize: 14, weight: .regular)
    muscleGroupsLabel.textColor = .tertiaryLabel
    muscleGroupsLabel.numberOfLines = 0

    detailsStackView.addArrangedSubview(exerciseCountLabel)
    detailsStackView.addArrangedSubview(durationLabel)
    detailsStackView.addArrangedSubview(muscleGroupsLabel)

    // Start button
    startButton.setTitle("Start Workout", for: .normal)
    startButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
    startButton.backgroundColor = .systemBlue
    startButton.setTitleColor(.white, for: .normal)
    startButton.layer.cornerRadius = 12
    startButton.translatesAutoresizingMaskIntoConstraints = false
    startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)

    // Rest day view
    restDayView.translatesAutoresizingMaskIntoConstraints = false
    restDayView.isHidden = true

    // Add subviews
    containerView.addSubview(headerStackView)
    containerView.addSubview(workoutIconLabel)
    containerView.addSubview(workoutNameLabel)
    containerView.addSubview(detailsStackView)
    containerView.addSubview(startButton)
    containerView.addSubview(restDayView)

    // Constraints
    NSLayoutConstraint.activate([
      containerView.topAnchor.constraint(equalTo: topAnchor),
      containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
      containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

      headerStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
      headerStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
      headerStackView.trailingAnchor.constraint(
        equalTo: containerView.trailingAnchor, constant: -20),

      workoutIconLabel.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 16),
      workoutIconLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),

      workoutNameLabel.centerYAnchor.constraint(equalTo: workoutIconLabel.centerYAnchor),
      workoutNameLabel.leadingAnchor.constraint(
        equalTo: workoutIconLabel.trailingAnchor, constant: 12),
      workoutNameLabel.trailingAnchor.constraint(
        equalTo: containerView.trailingAnchor, constant: -20),

      detailsStackView.topAnchor.constraint(equalTo: workoutIconLabel.bottomAnchor, constant: 16),
      detailsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
      detailsStackView.trailingAnchor.constraint(
        equalTo: containerView.trailingAnchor, constant: -20),

      startButton.topAnchor.constraint(equalTo: detailsStackView.bottomAnchor, constant: 20),
      startButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
      startButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
      startButton.heightAnchor.constraint(equalToConstant: 50),
      startButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),

      restDayView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 20),
      restDayView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
      restDayView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
      restDayView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
    ])

    setupAnimations()
  }

  private func setupAnimations() {
    // Add subtle animation to the button
    startButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
    startButton.addTarget(
      self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside])
  }

  // MARK: - Configuration
  func configure(with workout: WorkoutDay?) {
    currentWorkout = workout

    if let workout = workout {
      // Show workout details
      workoutIconLabel.isHidden = false
      workoutNameLabel.isHidden = false
      detailsStackView.isHidden = false
      startButton.isHidden = false
      restDayView.isHidden = true

      if let workoutType = WorkoutType(rawValue: workout.type) {
        workoutIconLabel.text = workoutType.icon
        workoutNameLabel.text = workout.name
        exerciseCountLabel.text =
          "📋 \(workout.exercises.count) exercises • \(workout.totalSets) total sets"
        durationLabel.text = "⏱ Estimated time: \(workout.estimatedDuration) minutes"

        let muscleGroups = workout.muscleGroups.map { $0.rawValue }.joined(separator: ", ")
        muscleGroupsLabel.text = "💪 Focus: \(muscleGroups)"

        // Update button color based on workout type
        if let color = UIColor(named: workoutType.color) {
          startButton.backgroundColor = color
          headerLabel.textColor = color
        }
      } else {
        // Fallback for unknown workout type
        workoutIconLabel.text = "💪"
        workoutNameLabel.text = workout.name
        exerciseCountLabel.text =
          "📋 \(workout.exercises.count) exercises • \(workout.totalSets) total sets"
        durationLabel.text = "⏱ Estimated time: \(workout.estimatedDuration) minutes"

        let muscleGroups = workout.muscleGroups.map { $0.rawValue }.joined(separator: ", ")
        muscleGroupsLabel.text = "💪 Focus: \(muscleGroups)"

        startButton.backgroundColor = .systemBlue
        headerLabel.textColor = .systemBlue
      }
    } else {
      // Show rest day
      workoutIconLabel.isHidden = true
      workoutNameLabel.isHidden = true
      detailsStackView.isHidden = true
      startButton.isHidden = true
      restDayView.isHidden = false

      headerLabel.textColor = .systemGray
    }
  }

  // MARK: - Actions
  @objc private func startButtonTapped() {
    guard let workout = currentWorkout else { return }
    delegate?.didTapStartWorkout(workout: workout)
  }

  @objc private func buttonTouchDown() {
    UIView.animate(withDuration: 0.1) {
      self.startButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    }
  }

  @objc private func buttonTouchUp() {
    UIView.animate(withDuration: 0.1) {
      self.startButton.transform = .identity
    }
  }
}

// MARK: - RestDayView
private class RestDayView: UIView {

  private let imageView = UIImageView()
  private let titleLabel = UILabel()
  private let subtitleLabel = UILabel()
  private let tipsLabel = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI() {
    // Image
    imageView.image = UIImage(systemName: "bed.double.fill")
    imageView.tintColor = .systemGray
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false

    // Title
    titleLabel.text = "Rest Day"
    titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
    titleLabel.textAlignment = .center
    titleLabel.translatesAutoresizingMaskIntoConstraints = false

    // Subtitle
    subtitleLabel.text = "Recovery is just as important as training!"
    subtitleLabel.font = .systemFont(ofSize: 18, weight: .medium)
    subtitleLabel.textColor = .secondaryLabel
    subtitleLabel.textAlignment = .center
    subtitleLabel.numberOfLines = 0
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

    // Tips
    let tips = """
      💧 Stay hydrated
      🥗 Eat nutritious foods
      😴 Get quality sleep
      🧘 Light stretching or yoga
      """

    tipsLabel.text = tips
    tipsLabel.font = .systemFont(ofSize: 16, weight: .regular)
    tipsLabel.textColor = .tertiaryLabel
    tipsLabel.numberOfLines = 0
    tipsLabel.translatesAutoresizingMaskIntoConstraints = false

    addSubview(imageView)
    addSubview(titleLabel)
    addSubview(subtitleLabel)
    addSubview(tipsLabel)

    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: topAnchor),
      imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
      imageView.widthAnchor.constraint(equalToConstant: 80),
      imageView.heightAnchor.constraint(equalToConstant: 80),

      titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
      titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
      titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

      subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
      subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
      subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

      tipsLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
      tipsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
      tipsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
      tipsLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }
}
