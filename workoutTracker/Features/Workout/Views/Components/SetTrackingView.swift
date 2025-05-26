import CoreData
import UIKit

protocol SetTrackingViewDelegate: AnyObject {
  func didCompleteSet(_ set: CompletedSet)
}

class SetTrackingView: UIView {

  // MARK: - Properties
  weak var delegate: SetTrackingViewDelegate?
  var setNumber: Int = 0
  private var isCompleted = false

  // MARK: - UI Components
  private let containerView = UIView()
  private let setNumberLabel = UILabel()
  private let repsTextField = UITextField()
  private let weightTextField = UITextField()
  private let completeButton = UIButton(type: .system)

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
    // Container view
    containerView.backgroundColor = .secondarySystemBackground
    containerView.layer.cornerRadius = 8
    containerView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(containerView)

    // Set number label
    setNumberLabel.font = .systemFont(ofSize: 15, weight: .medium)
    setNumberLabel.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(setNumberLabel)

    // Reps text field
    repsTextField.placeholder = "Reps"
    repsTextField.keyboardType = .numberPad
    repsTextField.borderStyle = .roundedRect
    repsTextField.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(repsTextField)

    // Weight text field
    weightTextField.placeholder = "Weight"
    weightTextField.keyboardType = .decimalPad
    weightTextField.borderStyle = .roundedRect
    weightTextField.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(weightTextField)

    // Complete button
    completeButton.setTitle("Complete", for: .normal)
    completeButton.backgroundColor = .systemBlue
    completeButton.setTitleColor(.white, for: .normal)
    completeButton.layer.cornerRadius = 8
    completeButton.translatesAutoresizingMaskIntoConstraints = false
    completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    containerView.addSubview(completeButton)

    NSLayoutConstraint.activate([
      containerView.topAnchor.constraint(equalTo: topAnchor),
      containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
      containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

      setNumberLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
      setNumberLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

      repsTextField.leadingAnchor.constraint(equalTo: setNumberLabel.trailingAnchor, constant: 12),
      repsTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
      repsTextField.widthAnchor.constraint(equalToConstant: 80),

      weightTextField.leadingAnchor.constraint(equalTo: repsTextField.trailingAnchor, constant: 12),
      weightTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
      weightTextField.widthAnchor.constraint(equalToConstant: 80),

      completeButton.leadingAnchor.constraint(
        equalTo: weightTextField.trailingAnchor, constant: 12),
      completeButton.trailingAnchor.constraint(
        equalTo: containerView.trailingAnchor, constant: -12),
      completeButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
      completeButton.widthAnchor.constraint(equalToConstant: 100),
    ])
  }

  // MARK: - Configuration
  func configure(with completedSet: CompletedSet) {
    repsTextField.text = "\(completedSet.reps)"
    weightTextField.text = String(format: "%.1f", completedSet.weight)
    isCompleted = true
    updateUI()
  }

  private func updateUI() {
    if isCompleted {
      repsTextField.isEnabled = false
      weightTextField.isEnabled = false
      completeButton.isEnabled = false
      completeButton.backgroundColor = .systemGray
    } else {
      repsTextField.isEnabled = true
      weightTextField.isEnabled = true
      completeButton.isEnabled = true
      completeButton.backgroundColor = .systemBlue
    }
  }

  // MARK: - Actions
  @objc private func completeButtonTapped() {
    guard let repsText = repsTextField.text,
      let reps = Int(repsText),
      let weightText = weightTextField.text,
      let weight = Double(weightText)
    else {
      return
    }

    let context = PersistenceController.shared.container.viewContext
    let completedSet = CompletedSet.create(context: context, reps: reps, weight: weight)
    completedSet.setValue(Int16(setNumber), forKey: "setNumber")

    delegate?.didCompleteSet(completedSet)
    isCompleted = true
    updateUI()
  }
}
