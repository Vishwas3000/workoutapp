
import UIKit

class QuickStatsCard: UIView {
    
    // MARK: - UI Components
    private let containerView = UIView()
    private let headerLabel = UILabel()
    private let statsStackView = UIStackView()
    
    private let workoutsStatView = StatItemView()
    private let timeStatView = StatItemView()
    private let avgDurationStatView = StatItemView()
    
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
        headerLabel.text = "QUICK STATS"
        headerLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        headerLabel.textColor = .systemPurple
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(headerLabel)
        
        // Stats stack view
        statsStackView.axis = .horizontal
        statsStackView.distribution = .fillEqually
        statsStackView.spacing = 16
        statsStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(statsStackView)
        
        // Add stat views
        statsStackView.addArrangedSubview(workoutsStatView)
        statsStackView.addArrangedSubview(timeStatView)
        statsStackView.addArrangedSubview(avgDurationStatView)
        
        // Configure stat views
        workoutsStatView.configure(
            icon: "figure.strengthtraining.traditional",
            iconColor: .systemBlue
        )
        
        timeStatView.configure(
            icon: "clock.fill",
            iconColor: .systemGreen
        )
        
        avgDurationStatView.configure(
            icon: "timer",
            iconColor: .systemOrange
        )
        
        // Constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            headerLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            statsStackView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 20),
            statsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            statsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            statsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            statsStackView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    // MARK: - Configuration
    func configure(totalWorkouts: Int, totalTime: String, avgDuration: String) {
        workoutsStatView.updateValues(value: "\(totalWorkouts)", label: "Workouts")
        timeStatView.updateValues(value: totalTime, label: "Total Time")
        avgDurationStatView.updateValues(value: avgDuration, label: "Avg Duration")
    }
}

// MARK: - StatItemView
private class StatItemView: UIView {
    
    private let iconView = UIView()
    private let iconImageView = UIImageView()
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Icon container
        iconView.layer.cornerRadius = 20
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)
        
        // Icon image
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconView.addSubview(iconImageView)
        
        // Value label
        valueLabel.font = .systemFont(ofSize: 24, weight: .bold)
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(valueLabel)
        
        // Title label
        titleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: topAnchor),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            valueLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 8),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func configure(icon: String, iconColor: UIColor) {
        iconView.backgroundColor = iconColor.withAlphaComponent(0.2)
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = iconColor
    }
    
    func updateValues(value: String, label: String) {
        valueLabel.text = value
        titleLabel.text = label
    }
}
