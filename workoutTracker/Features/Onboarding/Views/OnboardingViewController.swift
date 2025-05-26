
import UIKit

class OnboardingViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: AppCoordinator?
    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private var pages: [UIView] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        createPages()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Scroll view
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Page control
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .systemGray3
        pageControl.currentPageIndicatorTintColor = .systemBlue
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -20),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }
    
    private func createPages() {
        let page1 = createPage(
            title: "Welcome to GymTracker Pro",
            subtitle: "Your Personal Fitness Companion",
            imageName: "figure.strengthtraining.traditional",
            color: .systemBlue
        )
        
        let page2 = createPage(
            title: "Track Your Progress",
            subtitle: "Log workouts, monitor weight, and see your gains with detailed analytics",
            imageName: "chart.line.uptrend.xyaxis",
            color: .systemGreen
        )
        
        let page3 = createPageWithButton(
            title: "6-Day Push/Pull/Legs",
            subtitle: "Science-backed program designed for maximum muscle growth and strength",
            imageName: "calendar",
            color: .systemOrange
        )
        
        pages = [page1, page2, page3]
        
        // Add pages to scroll view
        for (index, page) in pages.enumerated() {
            scrollView.addSubview(page)
            page.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                page.topAnchor.constraint(equalTo: scrollView.topAnchor),
                page.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                page.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
                page.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: CGFloat(index) * UIScreen.main.bounds.width)
            ])
        }
        
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * CGFloat(pages.count), height: 0)
    }
    
    private func createPage(title: String, subtitle: String, imageName: String, color: UIColor) -> UIView {
        let page = UIView()
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: imageName)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = color
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 18, weight: .regular)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        page.addSubview(imageView)
        page.addSubview(titleLabel)
        page.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: page.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: page.centerYAnchor, constant: -100),
            imageView.widthAnchor.constraint(equalToConstant: 120),
            imageView.heightAnchor.constraint(equalToConstant: 120),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: page.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: page.trailingAnchor, constant: -40),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: page.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: page.trailingAnchor, constant: -40)
        ])
        
        return page
    }
    
    private func createPageWithButton(title: String, subtitle: String, imageName: String, color: UIColor) -> UIView {
        let page = createPage(title: title, subtitle: subtitle, imageName: imageName, color: color)
        
        let button = UIButton(type: .system)
        button.setTitle("Get Started", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(getStartedTapped), for: .touchUpInside)
        
        page.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: page.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: page.bottomAnchor, constant: -100),
            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        return page
    }
    
    // MARK: - Actions
    @objc private func getStartedTapped() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        coordinator?.showMainInterface()
    }
}

// MARK: - UIScrollViewDelegate
extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
}
