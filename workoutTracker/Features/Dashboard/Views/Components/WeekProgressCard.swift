import UIKit

class WeekProgressCard: UIView {
    
    // MARK: - UI Components
    private let containerView = UIView()
    private let headerLabel = UILabel()
    private let progressView = UIProgressView()
    private let progressLabel = UILabel()
    private let streakLabel = UILabel()
    private let daysStackView = UIStackView()
    
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
        
        // Header
        headerLabel.text = "WEEKLY PROGRESS"
        headerLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        headerLabel.textColor = .systemGreen
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(headerLabel)
        
        // Progress view
        progressView.progressTintColor = .systemGreen
        progressView.trackTintColor = .systemGray5
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(progressView)
        
        // Progress label
        progressLabel.font = .systemFont(ofSize: 24, weight: .bold)
        progressLabel.textColor = .systemGreen
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(progressLabel)
        
        // Streak label
        streakLabel.font = .systemFont(ofSize: 16, weight: .medium)
        streakLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(streakLabel)
        
        // Days stack view
        daysStackView.axis = .horizontal
        daysStackView.distribution = .fillEqually
        daysStackView.spacing = 8
        daysStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(daysStackView)
        
        setupDayIndicators()
        
        // Constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            headerLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            progressLabel.topAnchor.constraint(equalTo: headerLabel.topAnchor),
            progressLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            progressView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 16),
            progressView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            
            streakLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 16),
            streakLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            streakLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            daysStackView.topAnchor.constraint(equalTo: streakLabel.bottomAnchor, constant: 20),
            daysStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            daysStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            daysStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            daysStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupDayIndicators() {
        let days = ["M", "T", "W", "T", "F", "S", "S"]
        
        for day in days {
            let dayView = createDayIndicator(day: day, isCompleted: false)
            daysStackView.addArrangedSubview(dayView)
        }
    }
    
    private func createDayIndicator(day: String, isCompleted: Bool) -> UIView {
        let container = UIView()
        container.backgroundColor = isCompleted ? .systemGreen : .systemGray5
        container.layer.cornerRadius = 8
        
        let label = UILabel()
        label.text = day
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = isCompleted ? .white : .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    // MARK: - Configuration
    func configure(progress: Float, streak: Int) {
        // Update progress
        progressView.setProgress(progress, animated: true)
        progressLabel.text = "\(Int(progress * 100))%"
        
        // Update streak
        let streakText = streak > 0 ? "🔥 \(streak) day streak" : "Start your streak today!"
        let workoutsCompleted = Int(progress * 6)
        streakLabel.text = "\(streakText) • \(workoutsCompleted)/6 workouts this week"
        
        // Update day indicators
        updateDayIndicators(workoutsCompleted: workoutsCompleted)
    }
    
    private func updateDayIndicators(workoutsCompleted: Int) {
        for (index, view) in daysStackView.arrangedSubviews.enumerated() {
            let isCompleted = index < workoutsCompleted
            
            UIView.animate(withDuration: 0.3, delay: Double(index) * 0.05) {
                view.backgroundColor = isCompleted ? .systemGreen : .systemGray5
                if let label = view.subviews.first as? UILabel {
                    label.textColor = isCompleted ? .white : .secondaryLabel
                }
            }
        }
    }
}
