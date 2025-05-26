//
//  ProfileCoordinator.swift
//  workoutTracker
//
//  Created by Vishwas Prakash on 26/05/25.
//

import Foundation
import UIKit

// MARK: - Profile Coordinator
class ProfileCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let profileVC = ProfileViewController(coordinator: self)
        profileVC.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person.fill"),
            tag: 3
        )
        navigationController.setViewControllers([profileVC], animated: false)
    }
    
    func showSettings() {
        let settingsVC = SettingsViewController(coordinator: self)
        navigationController.pushViewController(settingsVC, animated: true)
    }
    
    func showWeightHistory() {
        let weightHistoryVC = WeightHistoryViewController(coordinator: self)
        navigationController.pushViewController(weightHistoryVC, animated: true)
    }
}
