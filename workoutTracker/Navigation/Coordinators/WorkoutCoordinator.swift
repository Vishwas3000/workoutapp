import UIKit

// MARK: - Workout Coordinator
class WorkoutCoordinator: Coordinator {
  var childCoordinators: [Coordinator] = []
  var navigationController: UINavigationController

  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }

  func start() {
    let workoutListVC = WorkoutListViewController(coordinator: self)
    workoutListVC.tabBarItem = UITabBarItem(
      title: "Workouts",
      image: UIImage(systemName: "dumbbell.fill"),
      tag: 2
    )
    navigationController.setViewControllers([workoutListVC], animated: false)
  }

  func showWorkoutDetail(workout: WorkoutDay) {
    let detailVC = WorkoutDetailViewController(workout: workout, coordinator: self)
    navigationController.pushViewController(detailVC, animated: true)
  }

  func startWorkout(workout: WorkoutDay) {
      let sessionVC = WorkoutSessionViewController(workoutDay: workout)
    let navController = UINavigationController(rootViewController: sessionVC)
    navController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
    navigationController.present(navController, animated: true)
  }
}
