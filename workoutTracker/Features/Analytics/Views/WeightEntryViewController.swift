//
//  WeightEntryViewController.swift
//  workoutTracker
//
//  Created by Vishwas Prakash on 26/05/25.
//

import Foundation
import UIKit

class WeightEntryViewController: UIViewController {
    
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
        title = "Add Weight"
    }
}
