import UIKit

class ActivitiesViewController: UIViewController {
    
    // MARK: - Properties
    private var activityData: ActivityData?
    private var currentDate = Date()
    private var userPreferredSystem: String = "metric"
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var weightChartView: WeightChartView!
    private var waterIntakeView: WaterIntakeView!
    
    private let exerciseView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchActivitiesData() // Ovo mora da se pozove nakon setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Activities"
        
        // Add scrollView to main view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Setup views
        setupWeightChart()
        setupWaterIntake()
        setupExercise()
        
        // Setup constraints
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // WeightChartView constraints
            weightChartView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            weightChartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            weightChartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            weightChartView.heightAnchor.constraint(equalToConstant: 400),
            
            // WaterIntakeView constraints
            waterIntakeView.topAnchor.constraint(equalTo: weightChartView.bottomAnchor, constant: 20),
                    waterIntakeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                    waterIntakeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                    // umesto fiksne visine stavi minimalnu visinu
                    waterIntakeView.heightAnchor.constraint(greaterThanOrEqualToConstant: 500),  // povećaj na 500 ili više ako treba
            
            // ExerciseView constraints
            exerciseView.topAnchor.constraint(equalTo: waterIntakeView.bottomAnchor, constant: 20),
            exerciseView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            exerciseView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            exerciseView.heightAnchor.constraint(equalToConstant: 300),
            exerciseView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupWeightChart() {
        weightChartView = WeightChartView(frame: .zero)
        weightChartView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(weightChartView)
        
//        weightChartView.onAddTapped = { [weak self] in
//            self?.showWeightInputModal()
//        }
        
    }
    
    private func setupWaterIntake() {
        waterIntakeView = WaterIntakeView(frame: .zero)
        waterIntakeView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(waterIntakeView)
        
        waterIntakeView.delegate = self
        
        waterIntakeView.onAddTapped = { [weak self] in
            self?.showWaterIntakeInputModal()
        }
    }
    
    private func setupExercise() {
        contentView.addSubview(exerciseView)
        // TODO: Add exercise setup implementation
    }
    
    // MARK: - UI Updates
    private func updateWeightChart(with weights: [WeightEntry]) {
        weightChartView.weights = weights
    }
    
    private func updateWaterIntakeDisplay(intake: Double, goal: Double) {
        waterIntakeView.updateWaterLogs(
            entries: activityData?.waterIntakes ?? [],
            goal: goal // direktno prosleđujemo dobijenu vrednost
        )
    }
    
    private func updateExerciseList(with exercises: [ExerciseEntry]) {
        // TODO: Implement exercise list update
    }
    
    private func updateUI() {
        if let weights = activityData?.weights {
            updateWeightChart(with: weights)
        }
        
        if let waterIntake = activityData?.todayWaterIntake,
           let waterGoal = activityData?.waterIntakeGoal {
            updateWaterIntakeDisplay(intake: waterIntake, goal: waterGoal)
        }
        
        if let exercises = activityData?.exercises {
            updateExerciseList(with: exercises)
        }
    }
    
    // MARK: - User Actions
    private func showWeightInputModal() {
        let alert = UIAlertController(title: "Add Weight", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Weight (kg)"
            textField.keyboardType = UIKeyboardType.decimalPad
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Date"
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .wheels
            textField.inputView = datePicker
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let weightText = alert.textFields?[0].text,
                  let weight = Double(weightText),
                  let dateField = alert.textFields?[1],
                  let datePicker = dateField.inputView as? UIDatePicker else { return }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: datePicker.date)
            
            self?.addWeight(value: weight, date: dateString)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showWaterIntakeInputModal() {
        let alert = UIAlertController(title: "Add Water Intake", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Amount (ml)"
            textField.keyboardType = UIKeyboardType.numberPad
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let amountText = alert.textFields?[0].text,
                  let amount = Double(amountText) else { return }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: Date())
            
            self?.addWaterIntake(value: amount, date: dateString)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - API Calls
    private func addWeight(value: Double, date: String) {
        APIService.shared.addActivity(
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
                        self?.updateWeightChart(with: weights)
                    }
                case .failure(let error):
                    print("Error adding weight: \(error)")
                    self?.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func addWaterIntake(value: Double, date: String) {
        let additionalData = ["time": Date().formatted(date: .omitted, time: .shortened)]
        
        APIService.shared.addActivity(
            type: "water_intake",
            value: value,
            date: date,
            unit: "ml",
            additionalData: additionalData
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let intake = data.todayWaterIntake,
                       let goal = data.waterIntakeGoal {
                        self?.updateWaterIntakeDisplay(intake: intake, goal: goal)
                    }
                case .failure(let error):
                    print("Error adding water intake: \(error)")
                    self?.showError(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func fetchActivitiesData() {
        print("Fetching activities data...")
        APIService.shared.getActivitiesData { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    print("Successfully fetched activities data")
                    self?.activityData = data
                    
                    // Ažuriraj water intake view sa novim podacima
                    if let waterIntakes = data.waterIntakes {
                        self?.waterIntakeView.updateWaterLogs(
                            entries: waterIntakes,
                            goal: data.waterIntakeGoal ?? 2000
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
    
    // MARK: - Helper Methods
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
                         self?.waterIntakeView.updateWaterLogs(entries: waterIntakes, goal: data.waterIntakeGoal ?? 2000)
                     }
                 case .failure(_): // promeni 'error' u '_'
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
        
        let additionalData = ["time": timeString]
        
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
                    // Update activity data
                    self?.activityData = data
                    
                    // Update water intake view with new data
                    if let waterIntakes = data.waterIntakes {
                        self?.waterIntakeView.updateWaterLogs(
                            entries: waterIntakes,
                            goal: data.waterIntakeGoal ?? 2000
                        )
                    }
                case .failure(let error):
                    print("Error adding water intake: \(error)")
                    self?.showError(message: "Failed to add water intake")
                }
            }
        }
    }
}
