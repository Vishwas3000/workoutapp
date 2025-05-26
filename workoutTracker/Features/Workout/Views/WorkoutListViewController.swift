import UIKit

class WorkoutListViewController: UIViewController {
    
    weak var coordinator: WorkoutCoordinator?
    
    init(coordinator: WorkoutCoordinator? = nil) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Workouts"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
