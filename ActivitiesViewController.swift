import UIKit

class ActivitiesViewController: UIViewController {
    
    // MARK: - Properties
    private var activityData: ActivityData?
    private var currentDate = Date()
    private var userPreferredSystem: String = "metric"
    private var currentTab: Int = 0
    
    // MARK: - UI Components
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Water", "Weight", "Exercise"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.backgroundColor = UIColor(red: 241/255.0, green: 237/255.0, blue: 226/255.0, alpha: 1.0)
        control.selectedSegmentTintColor = UIColor(red: 71/255.0, green: 145/255.0, blue: 219/255.0, alpha: 1.0)
        control.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        return control
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UIColor(red: 249/255.0, green: 246/255.0, blue: 237/255.0, alpha: 1.0)
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var weightChartView: WeightChartView!
    private var waterIntakeView: WaterIntakeView!
    private var exerciseView: UIView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 249/255.0, green: 246/255.0, blue: 237/255.0, alpha: 1.0)
        setupNavigationBar()
        setupUI()
        fetchActivitiesData()
    }
    
    private func setupNavigationBar() {
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.prefersLargeTitles = false
            navigationItem.largeTitleDisplayMode = .never
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.shadowImage = UIImage()
            navigationBar.isTranslucent = true
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Activities"
        
        view.addSubview(segmentedControl)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        setupViews()
        setupConstraints()
        
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        updateVisibleView()
    }
    
    private func setupViews() {
        weightChartView = WeightChartView(frame: .zero)
        weightChartView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(weightChartView)
        
        waterIntakeView = WaterIntakeView(frame: .zero)
        waterIntakeView.translatesAutoresizingMaskIntoConstraints = false
        waterIntakeView.delegate = self
        contentView.addSubview(waterIntakeView)
        
        exerciseView = createExerciseView()
        contentView.addSubview(exerciseView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            segmentedControl.heightAnchor.constraint(equalToConstant: 40),
            
            scrollView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            waterIntakeView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            waterIntakeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            waterIntakeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            waterIntakeView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            weightChartView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            weightChartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            weightChartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            weightChartView.heightAnchor.constraint(equalToConstant: 400),
            weightChartView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            exerciseView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            exerciseView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            exerciseView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            exerciseView.heightAnchor.constraint(equalToConstant: 400),
            exerciseView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func createExerciseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 241/255.0, green: 237/255.0, blue: 226/255.0, alpha: 1.0)
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Exercise tracking coming soon"
        label.textAlignment = .center
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        currentTab = sender.selectedSegmentIndex
        updateVisibleView()
    }
    
    private func updateVisibleView() {
        waterIntakeView.isHidden = currentTab != 0
        weightChartView.isHidden = currentTab != 1
        exerciseView.isHidden = currentTab != 2
        
        if currentTab == 0 {
            // Prilagođavamo contentSize za water intake view
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let height = self.waterIntakeView.systemLayoutSizeFitting(
                    CGSize(
                        width: self.scrollView.bounds.width - 40,
                        height: UIView.layoutFittingExpandedSize.height
                    )
                ).height
                self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: height + 32)
            }
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Data Updates
    private func updateWeightChart(with weights: [WeightEntry]) {
        weightChartView.weights = weights
    }
    
    private func updateWaterIntakeDisplay(intake: Double, goal: Int) {
        waterIntakeView.updateWaterLogs(
            entries: activityData?.waterIntakes ?? [],
            goal: goal
        )
    }
    
    private func updateExerciseList(with exercises: [ExerciseEntry]) {
        // TODO: Implement when needed
    }
    
    private func updateUI() {
        guard let data = activityData else { return }
        
        if let weights = data.weights {
            updateWeightChart(with: weights)
        }
        
        if let waterIntake = data.todayWaterIntake {
            updateWaterIntakeDisplay(intake: waterIntake, goal: data.waterIntakeGoal)
        }
        
        if let exercises = data.exercises {
            updateExerciseList(with: exercises)
        }
    }
    
    // MARK: - API Calls
    private func fetchActivitiesData() {
        print("Fetching activities data...")
        APIService.shared.getActivitiesData { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    print("Successfully fetched activities data")
                    print("Water goal being passed to view: \(data.waterIntakeGoal)")
                    self?.activityData = data
                    
                    if let waterIntakes = data.waterIntakes {
                        self?.waterIntakeView.updateWaterLogs(
                            entries: waterIntakes,
                            goal: data.waterIntakeGoal
                        )
                    }
                    
                    self?.updateUI()
                case .failure(let error):
                    print("Error fetching activities: \(error)")
                    self?.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func addWaterIntake(amount: Double, date: String, timeString: String) {
        let additionalData = ["time": timeString]
        
        APIService.shared.addActivity(
            type: "water_intake",
            value: amount,
            date: date,
            unit: "ml",
            additionalData: additionalData
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    print("Successfully added water intake")
                    self?.activityData = data
                    if let waterIntakes = data.waterIntakes {
                        self?.waterIntakeView.updateWaterLogs(
                            entries: waterIntakes,
                            goal: data.waterIntakeGoal
                        )
                    }
                case .failure(let error):
                    print("Error adding water intake: \(error)")
                    self?.showError(message: "Failed to add water intake")
                }
            }
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - WaterIntakeViewDelegate
extension ActivitiesViewController: WaterIntakeViewDelegate {
    func didDeleteWater(entryId: Int) {
        APIService.shared.deleteActivity(id: entryId, type: "water_intake") { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let waterIntakes = data.waterIntakes {
                        self?.waterIntakeView.updateWaterLogs(
                            entries: waterIntakes,
                            goal: data.waterIntakeGoal
                        )
                    }
                case .failure:
                    self?.showError(message: "Failed to delete water intake")
                }
            }
        }
    }
    
    func didAddWater(amount: Double) {
        print("Adding water amount: \(amount)ml")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        let timeString = timeFormatter.string(from: Date())
        
        addWaterIntake(amount: amount, date: dateString, timeString: timeString)
    }
}
