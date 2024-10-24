import UIKit

// MARK: - Date Helpers
extension Date {
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: self)
    }
    
    var formattedTime: String {
        formatted(date: .omitted, time: .shortened)
    }
}

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
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = true
        scroll.backgroundColor = UIColor(red: 249/255.0, green: 246/255.0, blue: 237/255.0, alpha: 1.0)
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var weightChartView: WeightChartView!
    private var waterIntakeView: WaterIntakeView!
    private var exerciseView: ExerciseView!
    
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
        weightChartView.delegate = self
        contentView.addSubview(weightChartView)
        
        waterIntakeView = WaterIntakeView(frame: .zero)
        waterIntakeView.translatesAutoresizingMaskIntoConstraints = false
        waterIntakeView.delegate = self
        contentView.addSubview(waterIntakeView)
        
        exerciseView = ExerciseView(frame: .zero)
        exerciseView.translatesAutoresizingMaskIntoConstraints = false
        exerciseView.delegate = self
        contentView.addSubview(exerciseView)
    }
    
    // MARK: - Layout
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 16),
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
            
            weightChartView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            weightChartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            weightChartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            exerciseView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            exerciseView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            exerciseView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            exerciseView.heightAnchor.constraint(greaterThanOrEqualToConstant: 400)
        ])
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        currentTab = sender.selectedSegmentIndex
        updateVisibleView()
    }
    
    private func updateVisibleView() {
        waterIntakeView.isHidden = currentTab != 0
        weightChartView.isHidden = currentTab != 1
        exerciseView.isHidden = currentTab != 2
        
        let activeView = currentTab == 0 ? waterIntakeView :
                        currentTab == 1 ? weightChartView :
                        exerciseView
        
        contentView.constraints.forEach { constraint in
            if constraint.firstAttribute == .bottom {
                contentView.removeConstraint(constraint)
            }
        }
        
        if let activeView = activeView {
            activeView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        }
        
        DispatchQueue.main.async {
            let size = self.contentView.systemLayoutSizeFitting(
                CGSize(
                    width: self.scrollView.bounds.width,
                    height: UIView.layoutFittingCompressedSize.height
                ),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            self.scrollView.contentSize = size
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
        exerciseView.updateExercises(exercises)
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
                    self?.activityData = data
                    
                    if let waterIntakes = data.waterIntakes {
                        self?.waterIntakeView.updateWaterLogs(
                            entries: waterIntakes,
                            goal: data.waterIntakeGoal
                        )
                    }
                    
                    if let exercises = data.exercises {
                        self?.exerciseView.updateExercises(exercises)
                    }
                    
                    self?.updateUI()
                case .failure(let error):
                    print("Error fetching activities: \(error)")
                    self?.showError(message: error.localizedDescription)
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
    func didAddWater(amount: Double) {
        print("Adding water amount: \(amount)ml")
        
        let dateString = Date().dateString
        let additionalData = ["time": Date().timeString]
        
        APIService.shared.addActivity(
            type: "water_intake",
            value: amount,
            date: dateString,
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
    
    func didEditWater(entryId: Int, newAmount: Double) {
        let dateString = Date().dateString
        let additionalData = ["time": Date().timeString]
        
        APIService.shared.updateActivity(
            id: entryId,
            type: "water_intake",
            value: newAmount,
            date: dateString,
            unit: "ml",
            additionalData: additionalData
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let waterIntakes = data.waterIntakes {
                        self?.waterIntakeView.updateWaterLogs(
                            entries: waterIntakes,
                            goal: data.waterIntakeGoal
                        )
                    }
                case .failure(let error):
                    self?.showError(message: "Failed to update water intake: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - ExerciseViewDelegate
extension ActivitiesViewController: ExerciseViewDelegate {
    func didTapAddExercise() {
        showAddExerciseModal()
    }
    
    private func showAddExerciseModal() {
        let pickerVC = UIViewController()
        pickerVC.preferredContentSize = CGSize(width: view.bounds.width, height: 200)
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerVC.view.addSubview(pickerView)
        pickerView.frame = pickerVC.view.bounds
        
        let alert = UIAlertController(title: "Add Exercise", message: nil, preferredStyle: .alert)
        alert.setValue(pickerVC, forKey: "contentViewController")
        
        alert.addTextField { textField in
            textField.placeholder = "Duration (minutes)"
            textField.keyboardType = .numberPad
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let durationText = alert.textFields?[0].text,
                  let duration = Double(durationText) else { return }
            
            let selectedExercise = ExerciseView.exerciseTypes[pickerView.selectedRow(inComponent: 0)]
            let additionalData = ["exercise_type": selectedExercise]
            
            self?.addExercise(
                type: selectedExercise,
                value: duration,
                date: Date().dateString,
                additionalData: additionalData
            )
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func didRequestDelete(exercise: ExerciseEntry) {
            APIService.shared.deleteActivity(id: exercise.id, type: "exercise") { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        if let exercises = data.exercises {
                            self?.exerciseView.updateExercises(exercises)
                        }
                    case .failure(let error):
                        self?.showError(message: "Failed to delete exercise: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        func didRequestEdit(exercise: ExerciseEntry) {
            showEditExerciseModal(exercise: exercise)
        }
        
        private func showEditExerciseModal(exercise: ExerciseEntry) {
            let alert = UIAlertController(title: "Edit Exercise", message: nil, preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.text = exercise.exerciseType
                textField.placeholder = "Exercise Type"
            }
            
            alert.addTextField { textField in
                textField.text = String(format: "%.0f", exercise.value)
                textField.placeholder = "Duration (minutes)"
                textField.keyboardType = .numberPad
            }
            
            let updateAction = UIAlertAction(title: "Update", style: .default) { [weak self] _ in
                guard let exerciseType = alert.textFields?[0].text,
                      let durationText = alert.textFields?[1].text,
                      let duration = Double(durationText) else { return }
                
                let additionalData = ["exercise_type": exerciseType]
                
                self?.updateExercise(
                    id: exercise.id,
                    type: exerciseType,
                    value: duration,
                    date: exercise.date,
                    additionalData: additionalData
                )
            }
            
            alert.addAction(updateAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(alert, animated: true)
        }
        
        private func addExercise(type: String, value: Double, date: String, additionalData: [String: String]) {
            APIService.shared.addActivity(
                type: "exercise",
                value: value,
                date: date,
                unit: "minutes",
                additionalData: additionalData
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        if let exercises = data.exercises {
                            self?.exerciseView.updateExercises(exercises)
                        }
                    case .failure(let error):
                        self?.showError(message: "Failed to add exercise: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        private func updateExercise(id: Int, type: String, value: Double, date: String, additionalData: [String: String]) {
            APIService.shared.updateActivity(
                id: id,
                type: "exercise",
                value: value,
                date: date,
                unit: "minutes",
                additionalData: additionalData
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        if let exercises = data.exercises {
                            self?.exerciseView.updateExercises(exercises)
                        }
                    case .failure(let error):
                        self?.showError(message: "Failed to update exercise: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    // MARK: - UIPickerViewDelegate & DataSource
    extension ActivitiesViewController: UIPickerViewDelegate, UIPickerViewDataSource {
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return ExerciseView.exerciseTypes.count
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return ExerciseView.exerciseTypes[row]
        }
    }

    // MARK: - WeightChartViewDelegate
    extension ActivitiesViewController: WeightChartViewDelegate {
        func didRequestAddWeight() {
            let alert = UIAlertController(title: "Add Weight", message: nil, preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.placeholder = "Weight (kg)"
                textField.keyboardType = .decimalPad
            }
            
            let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
                guard let weightText = alert.textFields?[0].text,
                      let weight = Double(weightText) else { return }
                
                self?.addWeight(
                    value: weight,
                    date: Date().dateString,
                    additionalData: [:]
                )
            }
            
            alert.addAction(addAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(alert, animated: true)
        }
        
        func didRequestEditWeight(entry: WeightEntry) {
            let alert = UIAlertController(title: "Edit Weight", message: nil, preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.placeholder = "Weight (kg)"
                textField.text = String(format: "%.1f", entry.value)
                textField.keyboardType = .decimalPad
            }
            
            let updateAction = UIAlertAction(title: "Update", style: .default) { [weak self] _ in
                guard let weightText = alert.textFields?[0].text,
                      let weight = Double(weightText) else { return }
                
                self?.updateWeight(id: entry.id, value: weight, date: entry.date)
            }
            
            alert.addAction(updateAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            present(alert, animated: true)
        }
        
        func didRequestDeleteWeight(entry: WeightEntry) {
            APIService.shared.deleteActivity(id: entry.id, type: "weight") { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        if let weights = data.weights {
                            self?.weightChartView.weights = weights
                        }
                    case .failure(let error):
                        self?.showError(message: "Failed to delete weight: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        private func addWeight(value: Double, date: String, additionalData: [String: String]) {
            APIService.shared.addActivity(
                type: "weight",
                value: value,
                date: date,
                unit: "kg",
                additionalData: additionalData
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        if let weights = data.weights {
                            self?.weightChartView.weights = weights
                        }
                    case .failure(let error):
                        self?.showError(message: "Failed to add weight: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        private func updateWeight(id: Int, value: Double, date: String) {
            APIService.shared.updateActivity(
                id: id,
                type: "weight",
                value: value,
                date: date,
                unit: "kg",
                additionalData: [:]
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        if let weights = data.weights {
                            self?.weightChartView.weights = weights
                        }
                    case .failure(let error):
                        self?.showError(message: "Failed to update weight: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
