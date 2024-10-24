import UIKit
import Foundation


class WelcomeViewController: UIViewController {

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome to Fitwist"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor =  UIColor(hex: "#2e2d2b");
        label.textAlignment = .center
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Definišite tekst
        let text = "Explore a vast collection of effortless recipes tailored to fit your calorie requirements.\nSave time, save money, and achieve your objectives."
        
        // Kreirajte NSMutableAttributedString
        let attributedString = NSMutableAttributedString(string: text)
        
        // Definišite opseg teksta koji želite da italicizujete
        let italicRange = (text as NSString).range(of: "Save time, save money, and achieve your objectives.")
        
        // Dodajte italic atribut
        attributedString.addAttribute(.font, value: UIFont.italicSystemFont(ofSize: 16), range: italicRange)
        
        // Postavite attributedText labelu
        label.attributedText = attributedString
        label.font = UIFont.italicSystemFont(ofSize: 16) // Postavite font na italic
        label.textColor = .darkGray
        label.textAlignment = .center
        label.numberOfLines = 0 // Omogućite više linija
        return label
    }()


    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()

    private let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign In", for: .normal)
        button.setTitleColor(UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0), for: .normal) // svetlo plava
        button.setTitleColor(UIColor(hex: "#2e2d2b"), for: .normal) // boja za tekst

        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor =  UIColor(red: 249/255.0, green: 246/255.0, blue: 237/255.0, alpha: 1.0)
        
        view.addSubview(titleLabel)
        view.addSubview(logoImageView) // Dodajte sliku
        view.addSubview(descriptionLabel) // Dodajte opis
        view.addSubview(signUpButton)
        view.addSubview(signInButton)
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor), // Centrirajte sliku horizontalno
            logoImageView.widthAnchor.constraint(equalToConstant: 240), // Postavite širinu slike
            logoImageView.heightAnchor.constraint(equalToConstant: 85), // Postavite visinu slike
            
            descriptionLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 10),
          descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
          descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
      
            
            signUpButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            
            signInButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 20),
            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            signInButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
    }

    @objc private func signUpTapped() {
        let registrationVC = RegistrationViewController()
        navigationController?.pushViewController(registrationVC, animated: true)
    }

    @objc private func signInTapped() {
        let signInVC = SignInViewController()
        
        // Opciono: Dodajte animaciju pri prelasku
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = .push
        transition.subtype = .fromRight
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.window?.layer.add(transition, forKey: kCATransition)
        
        navigationController?.pushViewController(signInVC, animated: false)
    }
}
