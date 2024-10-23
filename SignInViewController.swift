import UIKit

class SignInViewController: UIViewController {
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
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
    }
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private func setupUI() {
          view.backgroundColor = .white
          
          view.addSubview(emailTextField)
          view.addSubview(passwordTextField)
          view.addSubview(signInButton)
          view.addSubview(loadingIndicator)
          
          NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            signInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 40),
            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signInButton.heightAnchor.constraint(equalToConstant: 44),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                        loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        signInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
    }
    
    @objc private func signInButtonTapped() {
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
