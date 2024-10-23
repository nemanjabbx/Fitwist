import UIKit
import Foundation



class AllergiesGoalsViewController: UIViewController {
    
    var registrationData: RegistrationData?


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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Allergies and Dietary Preferences"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private let allergyGroupsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Select any allergy groups that apply to you:"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private let allergyGroupsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    private let goalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Primary Goal:"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let goalSegmentedControl: UISegmentedControl = {
        let items = ["Lose Weight", "Maintain Weight", "Gain Weight"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    private let dietaryRestrictionsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Dietary Restrictions:"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let dietaryRestrictionsTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        return textView
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Register", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor(hex: "#4caf50") ?? .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupConstraints()
        setupAllergyGroups()
        
        // Dismiss keyboard when tapping outside of text view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(allergyGroupsLabel)
        contentView.addSubview(allergyGroupsStackView)
        contentView.addSubview(goalLabel)
        contentView.addSubview(goalSegmentedControl)
        contentView.addSubview(dietaryRestrictionsLabel)
        contentView.addSubview(dietaryRestrictionsTextView)
        contentView.addSubview(registerButton)
        
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
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
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            allergyGroupsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            allergyGroupsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            allergyGroupsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            allergyGroupsStackView.topAnchor.constraint(equalTo: allergyGroupsLabel.bottomAnchor, constant: 10),
            allergyGroupsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                        allergyGroupsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                        
                        goalLabel.topAnchor.constraint(equalTo: allergyGroupsStackView.bottomAnchor, constant: 20),
                        goalLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                        goalLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                        
                        goalSegmentedControl.topAnchor.constraint(equalTo: goalLabel.bottomAnchor, constant: 10),
                        goalSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                        goalSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                        
                        dietaryRestrictionsLabel.topAnchor.constraint(equalTo: goalSegmentedControl.bottomAnchor, constant: 20),
                        dietaryRestrictionsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                        dietaryRestrictionsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                        
                        dietaryRestrictionsTextView.topAnchor.constraint(equalTo: dietaryRestrictionsLabel.bottomAnchor, constant: 10),
                        dietaryRestrictionsTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                        dietaryRestrictionsTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                        dietaryRestrictionsTextView.heightAnchor.constraint(equalToConstant: 100),
                        
                        registerButton.topAnchor.constraint(equalTo: dietaryRestrictionsTextView.bottomAnchor, constant: 40),
                        registerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                        registerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                        registerButton.heightAnchor.constraint(equalToConstant: 44),
                        registerButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
                    ])
                }
                
                private func setupAllergyGroups() {
                    // Ovo bi trebalo da bude dobavljeno sa servera, ali za sada ćemo koristiti hardkodirane vrednosti
                    let allergyGroups = ["Milk", "Eggs", "Fish", "Shellfish", "Tree nuts", "Peanuts", "Wheat", "Soybeans"]
                    
                    for (index, group) in allergyGroups.enumerated() {
                        let checkBox = UIButton(type: .system)
                        checkBox.setTitle(group, for: .normal)
                        checkBox.setImage(UIImage(systemName: "square"), for: .normal)
                        checkBox.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
                        checkBox.tintColor = UIColor(hex: "#4caf50")
                        checkBox.contentHorizontalAlignment = .left
                        checkBox.tag = index
                        checkBox.addTarget(self, action: #selector(allergyGroupTapped(_:)), for: .touchUpInside)
                        allergyGroupsStackView.addArrangedSubview(checkBox)
                    }
                }
                
                @objc private func allergyGroupTapped(_ sender: UIButton) {
                    sender.isSelected.toggle()
                }
                
    @objc private func registerButtonTapped() {
           guard var registrationData = registrationData else {
               showAlert(message: "Registration data is missing")
               return
           }
           
        registrationData.allergy_groups = allergyGroupsStackView.arrangedSubviews.compactMap { view -> Int? in
               guard let button = view as? UIButton, button.isSelected else { return nil }
               return button.tag + 1
           }
           
        registrationData.goal = ["lose_weight", "maintain", "gain_weight"][goalSegmentedControl.selectedSegmentIndex]
                registrationData.dietary_restrictions = dietaryRestrictionsTextView.text
        
           APIService.shared.register(userData: registrationData) { [weak self] result in
               DispatchQueue.main.async {
                   switch result {
                   case .success(let response):
                       print("Registration successful. Token: \(response.accessToken)")
                       self?.navigateToUserDashboard()
                   case .failure(let error):
                       print("Registration failed: \(error.localizedDescription)")
                       self?.showAlert(message: "Registration failed: \(error.localizedDescription)")
                   }
               }
           }
       }
    private func navigateToUserDashboard() {
        DispatchQueue.main.async {
            let userDashboardVC = UserDashboardViewController() // Pretpostavljamo da imate ovaj view controller
            
            // Ako koristite UINavigationController
            if let navigationController = self.navigationController {
                navigationController.setViewControllers([userDashboardVC], animated: true)
            } else {
                // Ako nemate navigation controller, možete postaviti root view controller
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = UINavigationController(rootViewController: userDashboardVC)
                    window.makeKeyAndVisible()
                }
            }
        }
    }
    private func navigateToMainScreen() {
        DispatchQueue.main.async {
            let userDashboardViewController = UserDashboardViewController()
            let navigationController = UINavigationController(rootViewController: userDashboardViewController)
            
            if #available(iOS 15.0, *) {
                // Za iOS 15 i novije
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = navigationController
                    window.makeKeyAndVisible()
                }
            } else {
                // Za iOS verzije pre 15.0
                if let window = UIApplication.shared.windows.first {
                    window.rootViewController = navigationController
                    window.makeKeyAndVisible()
                }
            }
        }
    }
//                private func registerUser() {
//                    guard let _ = registrationData else {
//                        showAlert(message: "Registration data is missing")
//                        return
//                    }
//                    
//                    // Ovde bismo implementirali poziv ka API-ju
//                    // Za sada ćemo samo simulirati uspešnu registraciju
//                    
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Simuliramo mrežni zahtev
//                        self.showAlert(message: "Registration successful!", title: "Success") { _ in
//                            // Ovde bismo navigirali na glavni ekran aplikacije
//                            print("Navigate to main app screen")
//                            // TODO: Implementirati navigaciju na glavni ekran
//                        }
//                    }
//                }
                
                private func showAlert(message: String, title: String = "Error", completion: ((UIAlertAction) -> Void)? = nil) {
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
                    present(alert, animated: true, completion: nil)
                }
            }
