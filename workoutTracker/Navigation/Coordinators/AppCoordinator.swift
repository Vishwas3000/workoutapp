import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController = UINavigationController()
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        // Check if user has completed onboarding
        let hasOnboarded = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        if hasOnboarded {
            showMainInterface()
        } else {
            showOnboarding()
        }
    }
    
    private func showOnboarding() {
        let onboardingVC = OnboardingViewController()
        onboardingVC.coordinator = self
        window.rootViewController = onboardingVC
    }
    
    func showMainInterface() {
        let tabBarController = MainTabBarController()
        
        // Dashboard
        let dashboardCoordinator = DashboardCoordinator(navigationController: UINavigationController())
        dashboardCoordinator.start()
        childCoordinators.append(dashboardCoordinator)
        
        // Analytics
        let analyticsCoordinator = AnalyticsCoordinator(navigationController: UINavigationController())
        analyticsCoordinator.start()
        childCoordinators.append(analyticsCoordinator)
        
        // Workouts
        let workoutCoordinator = WorkoutCoordinator(navigationController: UINavigationController())
        workoutCoordinator.start()
        childCoordinators.append(workoutCoordinator)
        
        // Profile
        let profileCoordinator = ProfileCoordinator(navigationController: UINavigationController())
        profileCoordinator.start()
        childCoordinators.append(profileCoordinator)
        
        tabBarController.viewControllers = [
            dashboardCoordinator.navigationController,
            analyticsCoordinator.navigationController,
            workoutCoordinator.navigationController,
            profileCoordinator.navigationController
        ]
        
        window.rootViewController = tabBarController
    }
}

