import UIKit

// MARK: - Dashboard Coordinator
class DashboardCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let dashboardVC = DashboardViewController(coordinator: self)
        dashboardVC.tabBarItem = UITabBarItem(
            title: "Dashboard",
            image: UIImage(systemName: "house.fill"),
            tag: 0
        )
        navigationController.setViewControllers([dashboardVC], animated: false)
    }
    
    func showWorkoutSession(workout: WorkoutDay) {
        let sessionVC = WorkoutSessionViewController(workout: workout, coordinator: self)
        let navController = UINavigationController(rootViewController: sessionVC)
        navController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        navigationController.present(navController, animated: true)
    }
    
    func showWorkoutDetails(session: WorkoutSession) {
        // Implementation for showing workout history details
    }
}
