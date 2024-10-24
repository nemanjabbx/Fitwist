import UIKit
import Foundation

class RegistrationViewController: UIViewController {
    
    private var registrationData = RegistrationData()

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
        label.text = "Sign Up & Try for Free"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit // Adjust the content mode
        imageView.image = UIImage(named: "logo") // Replace with your logo image name
        return imageView
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        let fontSize: CGFloat = 16 // Povećana veličina fonta
        label.font = UIFont.systemFont(ofSize: fontSize)

        let text = "Fitwist customizes meal plans tailored to your tastes, budget, and daily routine. Achieve your dietary and nutritional objectives with our app. Start crafting your personalized meal plan in just moments.\n\nAre you ready to try it out?"

        let attributedString = NSMutableAttributedString(string: text)

        let boldRange1 = (text as NSString).range(of: "Fitwist")
        let boldRange2 = (text as NSString).range(of: "Are you ready to try it out?")

        attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: fontSize), range: boldRange1)
        attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: fontSize), range: boldRange2)

        label.attributedText = attributedString
        label.textAlignment = .center
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter your name"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(hex: "#f1ede2") // svetla boja pozadine
        return textField
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter your email"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.backgroundColor = UIColor(hex: "#f1ede2") // svetla boja pozadine
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter your password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.backgroundColor = UIColor(hex: "#f1ede2") // svetla boja pozadine
        return textField
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Confirm your password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.backgroundColor = UIColor(hex: "#f1ede2") // svetla boja pozadine
        return textField
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Next", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor(hex: "#4caf50") ?? .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 249/255.0, green: 246/255.0, blue: 237/255.0, alpha: 1.0)

        setupUI()
        setupConstraints()
        
        // Dodaj gest prepoznavanje tap-a
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        scrollView.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(logoImageView) // Add the logo here
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(emailTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(confirmPasswordTextField)
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
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Dodavanje logoa
            logoImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10), // Razmak od titleLabel
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 100), // Visina logoa, prilagodite prema potrebi
            logoImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8), // Širina logoa, prilagodite prema potrebi

            // Smanjen razmak između logoa i descriptionLabel
            descriptionLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 10), // Smanjeno
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            nameTextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20), // Ostatak ostaje isti
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            nextButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 40),
            nextButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 44),
            nextButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func nextButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
                     let email = emailTextField.text, !email.isEmpty,
                     let password = passwordTextField.text, !password.isEmpty,
                     let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(message: "Please fill in all fields")
            return
        }
        
        guard password == confirmPassword else {
            showAlert(message: "Passwords do not match")
            return
        }
        
        registrationData.name = name
                registrationData.email = email
                registrationData.password = password
                registrationData.password_confirmation = confirmPassword

                let physicalInfoVC = PhysicalInfoViewController()
                physicalInfoVC.registrationData = self.registrationData
                navigationController?.pushViewController(physicalInfoVC, animated: true)
        
        navigateToPhysicalInfo()
    }
    
    private func navigateToPhysicalInfo() {
        let physicalInfoVC = PhysicalInfoViewController()
        physicalInfoVC.registrationData = self.registrationData
        navigationController?.pushViewController(physicalInfoVC, animated: true)
    }
    
    private func showAlert(message: String, title: String = "Error") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
