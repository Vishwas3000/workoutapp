
import UIKit

class WeightChartCard: UIView {
    
    // MARK: - UI Components
    private let containerView = UIView()
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let currentWeightLabel = UILabel()
    private let changeLabel = UILabel()
    private let chartView = LineChartView()
    private let addButton = UIButton(type: .system)
    private let emptyStateView = EmptyStateView()
    
    // MARK: - Properties
    private var weightData: [WeightDataPoint] = []
    weak var delegate: WeightChartCardDelegate?
    
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
        headerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(headerView)
        
        titleLabel.text = "Weight Progress"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(subtitleLabel)
        
        currentWeightLabel.font = .systemFont(ofSize: 32, weight: .bold)
        currentWeightLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(currentWeightLabel)
        
        changeLabel.font = .systemFont(ofSize: 16, weight: .medium)
        changeLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(changeLabel)
        
        // Add button
        addButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        addButton.tintColor = .systemBlue
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        headerView.addSubview(addButton)
        
        // Chart
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.lineColor = .systemBlue
        chartView.fillColor = UIColor.systemBlue.withAlphaComponent(0.1)
        containerView.addSubview(chartView)
        
        // Empty state
        emptyStateView.configure(
            image: UIImage(systemName: "scalemass"),
            title: "No Weight Data",
            message: "Start tracking your weight to see progress"
        )
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        containerView.addSubview(emptyStateView)
        
        // Constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            headerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            
            currentWeightLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            currentWeightLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            
            changeLabel.centerYAnchor.constraint(equalTo: currentWeightLabel.centerYAnchor),
            changeLabel.leadingAnchor.constraint(equalTo: currentWeightLabel.trailingAnchor, constant: 12),
            
            addButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 32),
            addButton.heightAnchor.constraint(equalToConstant: 32),
            
            headerView.bottomAnchor.constraint(equalTo: currentWeightLabel.bottomAnchor),
            
            chartView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            chartView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            chartView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            chartView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            
            emptyStateView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            emptyStateView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            emptyStateView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            emptyStateView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Configuration
    func configure(with data: [WeightDataPoint]) {
        weightData = data
        
        let isEmpty = data.isEmpty
        chartView.isHidden = isEmpty
        emptyStateView.isHidden = !isEmpty
        
        if !isEmpty {
            // Update chart
            chartView.dataPoints = data.map { ($0.date, $0.weight) }
            chartView.animateChart()
            
            // Update labels
            if let currentWeight = data.last?.weight {
                currentWeightLabel.text = String(format: "%.1f lbs", currentWeight)
            }
            
            if data.count >= 2 {
                let firstWeight = data.first!.weight
                let lastWeight = data.last!.weight
                let change = lastWeight - firstWeight
                
                changeLabel.text = String(format: "%+.1f", change)
                changeLabel.textColor = change >= 0 ? .systemGreen : .systemRed
            } else {
                changeLabel.text = ""
            }
            
            // Update subtitle
            let days = data.count
            subtitleLabel.text = "Last \(days) days"
        } else {
            currentWeightLabel.text = "-- lbs"
            changeLabel.text = ""
            subtitleLabel.text = "No data"
        }
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        delegate?.didTapAddWeight()
    }
}

// MARK: - Delegate Protocol
protocol WeightChartCardDelegate: AnyObject {
    func didTapAddWeight()
}

// MARK: - Empty State View
class EmptyStateView: UIView {
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        messageLabel.font = .systemFont(ofSize: 14, weight: .regular)
        messageLabel.textAlignment = .center
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
    
    func configure(image: UIImage?, title: String, message: String) {
        imageView.image = image
        titleLabel.text = title
        messageLabel.text = message
    }
}
