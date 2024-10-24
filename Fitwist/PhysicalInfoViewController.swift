import UIKit
import Foundation


class PhysicalInfoViewController: UIViewController {
    
    var registrationData: RegistrationData!


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
    
    private let unitSystemSegmentedControl: UISegmentedControl = {
        let items = ["Metric (cm, kg)", "Imperial (ft, in, lbs)"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    private let heightTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Height (cm)"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let imperialHeightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.isHidden = true
        return stackView
    }()
    
    private let heightFeetTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Feet"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let heightInchesTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Inches"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let weightTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Weight (kg)"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let dateOfBirthTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Date of Birth"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let genderSegmentedControl: UISegmentedControl = {
        let items = ["Male", "Female", "Other"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    private let activityLevelSegmentedControl: UISegmentedControl = {
        let items = ["Sedentary", "Light", "Moderate", "Active", "Very Active"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Next", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor(hex: "#4caf50")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        setupDatePicker()
        setupUnitSystemControl()
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(unitSystemSegmentedControl)
        contentView.addSubview(heightTextField)
        contentView.addSubview(imperialHeightStackView)
        imperialHeightStackView.addArrangedSubview(heightFeetTextField)
        imperialHeightStackView.addArrangedSubview(heightInchesTextField)
        contentView.addSubview(weightTextField)
                contentView.addSubview(dateOfBirthTextField)
                contentView.addSubview(genderSegmentedControl)
                contentView.addSubview(activityLevelSegmentedControl)
                contentView.addSubview(nextButton)
                
                nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
            }
            
            private func setupConstraints() {
                NSLayoutConstraint.activate([
                    scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                    scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    
                    contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                    contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                    contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                    contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                    contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                    
                    unitSystemSegmentedControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
                    unitSystemSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                    unitSystemSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                    
                    heightTextField.topAnchor.constraint(equalTo: unitSystemSegmentedControl.bottomAnchor, constant: 20),
                    heightTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                    heightTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                    heightTextField.heightAnchor.constraint(equalToConstant: 44),
                    
                    imperialHeightStackView.topAnchor.constraint(equalTo: unitSystemSegmentedControl.bottomAnchor, constant: 20),
                    imperialHeightStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                    imperialHeightStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                    imperialHeightStackView.heightAnchor.constraint(equalToConstant: 44),
                    
                    weightTextField.topAnchor.constraint(equalTo: heightTextField.bottomAnchor, constant: 20),
                    weightTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                    weightTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                    weightTextField.heightAnchor.constraint(equalToConstant: 44),
                    
                    dateOfBirthTextField.topAnchor.constraint(equalTo: weightTextField.bottomAnchor, constant: 20),
                    dateOfBirthTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                    dateOfBirthTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                    dateOfBirthTextField.heightAnchor.constraint(equalToConstant: 44),
                    
                    genderSegmentedControl.topAnchor.constraint(equalTo: dateOfBirthTextField.bottomAnchor, constant: 20),
                    genderSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                    genderSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                    
                    activityLevelSegmentedControl.topAnchor.constraint(equalTo: genderSegmentedControl.bottomAnchor, constant: 20),
                    activityLevelSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                    activityLevelSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                    
                    nextButton.topAnchor.constraint(equalTo: activityLevelSegmentedControl.bottomAnchor, constant: 40),
                    nextButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                    nextButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                    nextButton.heightAnchor.constraint(equalToConstant: 44),
                    nextButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
                ])
            }
            
            private func setupDatePicker() {
                let datePicker = UIDatePicker()
                datePicker.datePickerMode = .date
                datePicker.preferredDatePickerStyle = .wheels
                datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
                dateOfBirthTextField.inputView = datePicker
            }
            
            private func setupUnitSystemControl() {
                unitSystemSegmentedControl.addTarget(self, action: #selector(unitSystemChanged), for: .valueChanged)
            }
            
            @objc private func dateChanged(_ sender: UIDatePicker) {
                let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy"
                    dateOfBirthTextField.text = formatter.string(from: sender.date)
            }
            
            @objc private func unitSystemChanged(_ sender: UISegmentedControl) {
                let isMetric = sender.selectedSegmentIndex == 0
                heightTextField.isHidden = !isMetric
                imperialHeightStackView.isHidden = isMetric
                
                if isMetric {
                    heightTextField.placeholder = "Height (cm)"
                    weightTextField.placeholder = "Weight (kg)"
                } else {
                    heightFeetTextField.placeholder = "Feet"
                    heightInchesTextField.placeholder = "Inches"
                    weightTextField.placeholder = "Weight (lbs)"
                }
            }
            
    @objc private func nextButtonTapped() {
        guard let weight = Double(weightTextField.text ?? ""),
              let dateOfBirth = dateOfBirthTextField.text, !dateOfBirth.isEmpty else {
            showAlert(message: "Please fill in all fields")
            return
        }
        
        let isMetric = unitSystemSegmentedControl.selectedSegmentIndex == 0
        var height: Double = 0
        
        if isMetric {
            guard let heightValue = Double(heightTextField.text ?? "") else {
                showAlert(message: "Please enter a valid height")
                return
            }
            height = heightValue
        } else {
            guard let feet = Double(heightFeetTextField.text ?? ""),
                  let inches = Double(heightInchesTextField.text ?? "") else {
                showAlert(message: "Please enter a valid height")
                return
            }
            height = feet * 30.48 + inches * 2.54 // Convert to cm
        }
        
        let genderIndex = genderSegmentedControl.selectedSegmentIndex
        let gender = ["male", "female", "other"][genderIndex]
        
        let activityLevelIndex = activityLevelSegmentedControl.selectedSegmentIndex
        let activityLevels = ["sedentary", "light", "moderate", "active", "very_active"]
        let activityLevel = activityLevels[activityLevelIndex]
        
        let heightInCm = isMetric ? height : height
        let weightInKg = isMetric ? weight : weight * 0.453592

        registrationData.unit_system = isMetric ? "metric" : "imperial"
        registrationData.height = String(format: "%.2f", heightInCm)
        registrationData.weight = String(format: "%.2f", weightInKg)
        registrationData.date_of_birth = dateOfBirth
        registrationData.gender = gender
        registrationData.activity_level = activityLevel

        let allergiesGoalsVC = AllergiesGoalsViewController()
        allergiesGoalsVC.registrationData = self.registrationData
        navigationController?.pushViewController(allergiesGoalsVC, animated: true)
    }
            
            private func navigateToAllergiesAndGoals() {
                let allergiesGoalsVC = AllergiesGoalsViewController()
                allergiesGoalsVC.registrationData = self.registrationData
                navigationController?.pushViewController(allergiesGoalsVC, animated: true)
            }
            
            private func showAlert(message: String, title: String = "Error") {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
