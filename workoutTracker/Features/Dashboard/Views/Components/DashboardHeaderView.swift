
import UIKit

class DashboardHeaderView: UIView {
    
    // MARK: - UI Components
    private let greetingLabel = UILabel()
    private let nameLabel = UILabel()
    private let dateLabel = UILabel()
    private let motivationLabel = UILabel()
    
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
        greetingLabel.font = .systemFont(ofSize: 24, weight: .medium)
        greetingLabel.textColor = .secondaryLabel
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(greetingLabel)
        
        nameLabel.font = .systemFont(ofSize: 32, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nameLabel)
        
        dateLabel.font = .systemFont(ofSize: 16, weight: .regular)
        dateLabel.textColor = .secondaryLabel
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dateLabel)
        
        motivationLabel.font = .systemFont(ofSize: 14, weight: .medium)
        motivationLabel.textColor = .tertiaryLabel
        motivationLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(motivationLabel)
        
        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: topAnchor),
            greetingLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            dateLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            motivationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            motivationLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            motivationLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Configuration
    func configure(greeting: String, userName: String, date: String) {
        greetingLabel.text = greeting
        nameLabel.text = userName
        dateLabel.text = date
        motivationLabel.text = getMotivationalQuote()
    }
    
    private func getMotivationalQuote() -> String {
        let quotes = [
            "💪 Consistency is key!",
            "🔥 Every rep counts!",
            "🎯 Focus on progress, not perfection",
            "⚡ You're stronger than yesterday",
            "🌟 Make today count!"
        ]
        return quotes.randomElement() ?? ""
    }
}
