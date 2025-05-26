import CoreData
import UIKit

protocol ExerciseCellDelegate: AnyObject {
  func didCompleteSet(_ set: CompletedSet, for exercise: Exercise)
}

class ExerciseCell: UITableViewCell {

  // MARK: - Properties
  private var exercise: Exercise?
  weak var delegate: ExerciseCellDelegate?

  // MARK: - UI Components
  private let nameLabel = UILabel()
  private let setsLabel = UILabel()
  private let repsLabel = UILabel()
  private let weightLabel = UILabel()
  private let stackView = UIStackView()
  private let completedSetsStackView = UIStackView()

  // MARK: - Initialization
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup
  private func setupUI() {
    selectionStyle = .none

    // Setup labels
    nameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
    nameLabel.numberOfLines = 0

    setsLabel.font = .systemFont(ofSize: 15)
    setsLabel.textColor = .secondaryLabel

    repsLabel.font = .systemFont(ofSize: 15)
    repsLabel.textColor = .secondaryLabel

    weightLabel.font = .systemFont(ofSize: 15)
    weightLabel.textColor = .secondaryLabel

    // Setup stack views
    stackView.axis = .vertical
    stackView.spacing = 8
    stackView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(stackView)

    completedSetsStackView.axis = .vertical
    completedSetsStackView.spacing = 4
    completedSetsStackView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(completedSetsStackView)

    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

      completedSetsStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 8),
      completedSetsStackView.leadingAnchor.constraint(
        equalTo: contentView.leadingAnchor, constant: 16),
      completedSetsStackView.trailingAnchor.constraint(
        equalTo: contentView.trailingAnchor, constant: -16),
      completedSetsStackView.bottomAnchor.constraint(
        equalTo: contentView.bottomAnchor, constant: -12),
    ])
  }

  // MARK: - Configuration
  func configure(with exercise: Exercise) {
    self.exercise = exercise

    // Clear previous views
    stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    completedSetsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

    // Add exercise info
    stackView.addArrangedSubview(nameLabel)
    stackView.addArrangedSubview(setsLabel)
    stackView.addArrangedSubview(repsLabel)
    stackView.addArrangedSubview(weightLabel)

    // Update labels
    nameLabel.text = exercise.name
    setsLabel.text = "Sets: \(exercise.sets)"
    repsLabel.text = "Reps: \(exercise.reps)"
    weightLabel.text = "Weight: \(exercise.weight)"

    // Add set tracking buttons
    for setNumber in 1...exercise.sets {
      let setView = createSetView(setNumber: setNumber)
      completedSetsStackView.addArrangedSubview(setView)
    }

    // Show completed sets
    for completedSet in exercise.completedSets {
      if let setView = completedSetsStackView.arrangedSubviews[completedSet.setNumber - 1]
        as? SetTrackingView
      {
        setView.configure(with: completedSet)
      }
    }
  }

  private func createSetView(setNumber: Int) -> SetTrackingView {
    let setView = SetTrackingView()
    setView.delegate = self
    setView.setNumber = setNumber
    return setView
  }
}

// MARK: - SetTrackingViewDelegate
extension ExerciseCell: SetTrackingViewDelegate {
  func didCompleteSet(_ set: CompletedSet) {
    guard let exercise = exercise else { return }
    delegate?.didCompleteSet(set, for: exercise)
  }
}
