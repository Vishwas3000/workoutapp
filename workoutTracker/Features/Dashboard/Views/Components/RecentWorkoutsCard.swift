import CoreData
import UIKit

protocol RecentWorkoutsCardDelegate: AnyObject {
  func didTapViewAllWorkouts()
  func didSelectWorkoutSession(_ session: WorkoutSession)
}

class RecentWorkoutsCard: UIView {

  // MARK: - Properties
  weak var delegate: RecentWorkoutsCardDelegate?
  private var workoutSessions: [WorkoutSession] = []

  // MARK: - UI Components
  private let containerView = UIView()
  private let headerStackView = UIStackView()
  private let headerLabel = UILabel()
  private let viewAllButton = UIButton(type: .system)
  private let workoutsStackView = UIStackView()
  private let emptyStateLabel = UILabel()

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
    // Container
    containerView.backgroundColor = .secondarySystemBackground
    containerView.layer.cornerRadius = 16
    containerView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(containerView)

    // Header stack view
    headerStackView.axis = .horizontal
    headerStackView.alignment = .center
    headerStackView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(headerStackView)

    // Header label
    headerLabel.text = "RECENT WORKOUTS"
    headerLabel.font = .systemFont(ofSize: 14, weight: .semibold)
    headerLabel.textColor = .systemOrange

    // View all button
    viewAllButton.setTitle("View All", for: .normal)
    viewAllButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
    viewAllButton.addTarget(self, action: #selector(viewAllTapped), for: .touchUpInside)

    headerStackView.addArrangedSubview(headerLabel)
    headerStackView.addArrangedSubview(UIView())  // Spacer
    headerStackView.addArrangedSubview(viewAllButton)

    // Workouts stack view
    workoutsStackView.axis = .vertical
    workoutsStackView.spacing = 12
    workoutsStackView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(workoutsStackView)

    // Empty state
    emptyStateLabel.text = "No recent workouts"
    emptyStateLabel.font = .systemFont(ofSize: 16, weight: .regular)
    emptyStateLabel.textColor = .secondaryLabel
    emptyStateLabel.textAlignment = .center
    emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
    emptyStateLabel.isHidden = true
    containerView.addSubview(emptyStateLabel)

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

      workoutsStackView.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 16),
      workoutsStackView.leadingAnchor.constraint(
        equalTo: containerView.leadingAnchor, constant: 20),
      workoutsStackView.trailingAnchor.constraint(
        equalTo: containerView.trailingAnchor, constant: -20),
      workoutsStackView.bottomAnchor.constraint(
        lessThanOrEqualTo: containerView.bottomAnchor, constant: -20),

      emptyStateLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
      emptyStateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
      emptyStateLabel.trailingAnchor.constraint(
        equalTo: containerView.trailingAnchor, constant: -20),
    ])

    // Add bottom constraint with priority
    let bottomConstraint = workoutsStackView.bottomAnchor.constraint(
      equalTo: containerView.bottomAnchor, constant: -20)
    bottomConstraint.priority = .defaultHigh
    bottomConstraint.isActive = true
  }

  // MARK: - Configuration
  func configure(with sessions: [WorkoutSession]) {
    workoutSessions = sessions

    // Clear existing views
    workoutsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

    // Update UI
    let isEmpty = sessions.isEmpty
    workoutsStackView.isHidden = isEmpty
    emptyStateLabel.isHidden = !isEmpty
    viewAllButton.isHidden = isEmpty

    if !isEmpty {
      // Show up to 5 recent workouts
      for session in sessions.prefix(5) {
        let workoutRow = createWorkoutRow(for: session)
        workoutsStackView.addArrangedSubview(workoutRow)
      }
    }
  }

  private func createWorkoutRow(for session: WorkoutSession) -> UIView {
    let rowView = UIView()
    rowView.backgroundColor = .tertiarySystemBackground
    rowView.layer.cornerRadius = 12

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(workoutRowTapped(_:)))
    rowView.addGestureRecognizer(tapGesture)
    rowView.tag = workoutSessions.firstIndex(where: { $0.id == session.id }) ?? 0

    // Icon
    let iconLabel = UILabel()
    iconLabel.font = .systemFont(ofSize: 24)
    iconLabel.translatesAutoresizingMaskIntoConstraints = false
    rowView.addSubview(iconLabel)

    // Title label
    let titleLabel = UILabel()
    titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    rowView.addSubview(titleLabel)

    // Date label
    let dateLabel = UILabel()
    dateLabel.font = .systemFont(ofSize: 14, weight: .regular)
    dateLabel.textColor = .secondaryLabel
    dateLabel.translatesAutoresizingMaskIntoConstraints = false
    rowView.addSubview(dateLabel)

    // Duration label
    let durationLabel = UILabel()
    durationLabel.font = .systemFont(ofSize: 14, weight: .regular)
    durationLabel.textColor = .secondaryLabel
    durationLabel.textAlignment = .right
    durationLabel.translatesAutoresizingMaskIntoConstraints = false
    rowView.addSubview(durationLabel)

    // Configure content
    if let workout = WorkoutService.shared.workoutPlan.first(where: {
      $0.id == session.workoutDayId
    }),
      let workoutType = WorkoutType(rawValue: workout.type)
    {
      iconLabel.text = workoutType.icon
      titleLabel.text = workout.name
    } else {
      iconLabel.text = "💪"
      titleLabel.text = "Workout"
    }

    // Format date
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    dateLabel.text = formatter.localizedString(for: session.date, relativeTo: Date())

    // Format duration
    let minutes = Int(session.duration) / 60
    durationLabel.text = "\(minutes) min"

    // Constraints
    NSLayoutConstraint.activate([
      iconLabel.leadingAnchor.constraint(equalTo: rowView.leadingAnchor, constant: 16),
      iconLabel.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),

      titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
      titleLabel.topAnchor.constraint(equalTo: rowView.topAnchor, constant: 16),

      dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
      dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
      dateLabel.bottomAnchor.constraint(equalTo: rowView.bottomAnchor, constant: -16),

      durationLabel.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
      durationLabel.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -16),

      rowView.heightAnchor.constraint(greaterThanOrEqualToConstant: 68),
    ])

    return rowView
  }

  // MARK: - Actions
  @objc private func viewAllTapped() {
    delegate?.didTapViewAllWorkouts()
  }

  @objc private func workoutRowTapped(_ gesture: UITapGestureRecognizer) {
    guard let view = gesture.view,
      view.tag < workoutSessions.count
    else { return }

    let session = workoutSessions[view.tag]
    delegate?.didSelectWorkoutSession(session)
  }
}
