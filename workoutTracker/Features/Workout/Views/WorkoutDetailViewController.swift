import UIKit

class WorkoutDetailViewController: UIViewController {
    
    private let workout: WorkoutDay
    weak var coordinator: WorkoutCoordinator?
    
    init(workout: WorkoutDay, coordinator: WorkoutCoordinator? = nil) {
        self.workout = workout
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = workout.name
    }
}
