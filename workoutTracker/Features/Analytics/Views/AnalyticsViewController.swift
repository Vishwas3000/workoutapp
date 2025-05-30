import UIKit

// MARK: - AnalyticsViewController
class AnalyticsViewController: UIViewController {
    
    weak var coordinator: AnalyticsCoordinator?
    
    init(coordinator: AnalyticsCoordinator? = nil) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Analytics"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
