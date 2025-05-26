import UIKit

class AnalyticsCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let analyticsVC = AnalyticsViewController(coordinator: self)
        analyticsVC.tabBarItem = UITabBarItem(
            title: "Analytics",
            image: UIImage(systemName: "chart.xyaxis.line"),
            tag: 1
        )
        navigationController.setViewControllers([analyticsVC], animated: false)
    }
    
    func showWeightEntry() {
        let weightEntryVC = WeightEntryViewController(coordinator: self)
        let navController = UINavigationController(rootViewController: weightEntryVC)
        navigationController.present(navController, animated: true)
    }
}
