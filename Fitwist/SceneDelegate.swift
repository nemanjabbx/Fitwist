import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
          
          // Globalne postavke za navigation bar
          let navBarAppearance = UINavigationBarAppearance()
          navBarAppearance.configureWithOpaqueBackground()
          navBarAppearance.backgroundColor = UIColor(red: 249/255.0, green: 246/255.0, blue: 237/255.0, alpha: 1.0)
          navBarAppearance.shadowImage = nil
          navBarAppearance.shadowColor = nil
          navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
          
          UINavigationBar.appearance().standardAppearance = navBarAppearance
          UINavigationBar.appearance().compactAppearance = navBarAppearance
          UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
          UINavigationBar.appearance().prefersLargeTitles = false
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        setupNotifications()
        showInitialScreen()
        
        window.makeKeyAndVisible()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserNeedsToLogin),
            name: .userNeedsToLogin,
            object: nil
        )
    }
    
    @objc private func handleUserNeedsToLogin(_ notification: Notification) {
        let animated = (notification.userInfo?["animated"] as? Bool) ?? true
        showLoginScreen(animated: animated)
    }
    
    private func showLoginScreen(animated: Bool) {
        let welcomeVC = WelcomeViewController()
        let navController = UINavigationController(rootViewController: welcomeVC)
        
        if animated {
            UIView.transition(
                with: window!,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: {
                    self.window?.rootViewController = navController
                },
                completion: nil
            )
        } else {
            window?.rootViewController = navController
        }
    }
    
    private func showInitialScreen() {
        if UserManager.shared.isUserLoggedIn() {
            let dashboardVC = UserDashboardViewController()
            window?.rootViewController = UINavigationController(rootViewController: dashboardVC)
        } else {
            showLoginScreen(animated: false)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
