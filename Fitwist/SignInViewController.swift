import UIKit

class SignInViewController: UIViewController {
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit // prilagodite kako želite
        imageView.image = UIImage(named: "logo") // zamenite sa imenom vaše slike
        return imageView
    }()
    
    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome back 👏"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold) // prilagodite veličinu i težinu fonta
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()
    private let signInPromptLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Please sign in to continue. If you don’t have an account yet, you can create one easily. We value your privacy and security, so rest assured that your information is safe with us."
        label.font = UIFont.italicSystemFont(ofSize: 16) // Postavite font na italic
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0 // Omogućava višelinijski prikaz
        return label
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(hex: "#f1ede2") // svetla boja pozadine
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(hex: "#f1ede2") // svetla boja pozadine
        return textField
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = UIColor(hex: "#4caf50")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Dismiss keyboard when tapping outside text fields
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 249/255.0, green: 246/255.0, blue: 237/255.0, alpha: 1.0)

        // Dodajte logo, label, i prompt
        view.addSubview(logoImageView)
        view.addSubview(welcomeLabel)
        view.addSubview(signInPromptLabel) // Dodajte ovu liniju
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signInButton)
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            // Postavite logo
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 240),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),

            // Postavite welcome label ispod logoa
            welcomeLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Postavite sign in prompt ispod welcome label
            signInPromptLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 10), // Razmak između
            signInPromptLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signInPromptLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Postavite email text field
            emailTextField.topAnchor.constraint(equalTo: signInPromptLabel.bottomAnchor, constant: 40),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),

            // Postavite password text field
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),

            // Postavite sign in button
            signInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 40),
            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signInButton.heightAnchor.constraint(equalToConstant: 44),

            // Postavite loading indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        signInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
    }
    @objc private func signInButtonTapped() {
        // Dismiss the keyboard
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showError(message: "Please enter email and password")
            return
        }
        
        // Validacija email formata
        guard isValidEmail(email) else {
            showError(message: "Please enter a valid email address")
            return
        }
        
        // Disable interaction and show loading
        view.isUserInteractionEnabled = false
        loadingIndicator.startAnimating()
        
        APIService.shared.signIn(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // Re-enable interaction and hide loading
                self.view.isUserInteractionEnabled = true
                self.loadingIndicator.stopAnimating()
                
                switch result {
                case .success(let response):
                    print("Login successful")
                    UserManager.shared.saveUserData(
                        token: response.accessToken,
                        userId: response.user.id,
                        email: response.user.email
                    )
                    self.navigateToUserDashboard()
                    
                case .failure(let error):
                    let errorMessage: String
                    switch error {
                    case let apiError as APIError:
                        errorMessage = apiError.localizedDescription
                    case let decodingError as DecodingError:
                        errorMessage = "Error processing server response"
                        print("Decoding error: \(decodingError)")
                    case let urlError as URLError:
                        errorMessage = "Network error: \(urlError.localizedDescription)"
                    default:
                        errorMessage = error.localizedDescription
                    }
                    self.showError(message: errorMessage)
                }
            }
        }
    }

       
       private func navigateToUserDashboard() {
           let userDashboardVC = UserDashboardViewController()
           let navigationController = UINavigationController(rootViewController: userDashboardVC)
           navigationController.modalPresentationStyle = .fullScreen
           self.present(navigationController, animated: true, completion: nil)
       }
       
       private func showAlert(message: String) {
           let alert = UIAlertController(
               title: "Error",
               message: message,
               preferredStyle: .alert
           )
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           present(alert, animated: true)
       }
    private func isValidEmail(_ email: String) -> Bool {
          let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
          let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
          return emailPred.evaluate(with: email)
      }
      
      // Pomocna metoda za prikazivanje greške
      private func showError(message: String) {
          let alert = UIAlertController(
              title: "Error",
              message: message,
              preferredStyle: .alert
          )
          let okAction = UIAlertAction(title: "OK", style: .default)
          alert.addAction(okAction)
          present(alert, animated: true)
      }
}
