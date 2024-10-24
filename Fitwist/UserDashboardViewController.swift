import UIKit

class UserDashboardViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }
    
    private func setupTabs() {
        let homeVC = HomeViewController()
        let dietPlanVC = UIViewController()
        let activitiesVC = ActivitiesViewController()
        let profileVC = UIViewController()
        
        // Podesite navigation bar samo za view controllere koji ga trebaju
        [dietPlanVC, activitiesVC, profileVC].forEach { viewController in
            viewController.navigationItem.largeTitleDisplayMode = .never
        }
        
        let homeNav = UINavigationController(rootViewController: homeVC)
        let dietPlanNav = UINavigationController(rootViewController: dietPlanVC)
        let activitiesNav = UINavigationController(rootViewController: activitiesVC)
        let profileNav = UINavigationController(rootViewController: profileVC)
        
        // Sakrij navigation bar za home screen
        homeNav.setNavigationBarHidden(true, animated: false)
        
        // Podesite navigation bar appearance samo za ostale navigation controllere
        [dietPlanNav, activitiesNav, profileNav].forEach { nav in
            nav.navigationBar.prefersLargeTitles = false
            nav.navigationBar.setBackgroundImage(UIImage(), for: .default)
            nav.navigationBar.shadowImage = UIImage()
            nav.navigationBar.isTranslucent = true
            nav.navigationBar.backgroundColor = UIColor(red: 249/255.0, green: 246/255.0, blue: 237/255.0, alpha: 1.0)
            nav.navigationBar.frame.size.height = 14
        }
        
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        dietPlanVC.tabBarItem = UITabBarItem(title: "Diet Plan", image: UIImage(systemName: "leaf"), tag: 1)
        activitiesVC.tabBarItem = UITabBarItem(title: "Progress", image: UIImage(systemName: "chart.bar"), tag: 2)
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 3)
        
        viewControllers = [homeNav, dietPlanNav, activitiesNav, profileNav]
    }
    
    private func setupAppearance() {
        // Tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        }
        
        tabBar.tintColor = UIColor(named: "AccentColor") ?? .systemGreen
        tabBar.unselectedItemTintColor = .gray
        
        // Navigation bar global appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(red: 249/255.0, green: 246/255.0, blue: 237/255.0, alpha: 1.0)
        navBarAppearance.shadowImage = nil
        navBarAppearance.shadowColor = nil
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        if #available(iOS 15.0, *) {
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        }
    }
}

class HomeViewController: UIViewController {
    
    private let avatarImageView: UIImageView = {
           let imageView = UIImageView()
           imageView.contentMode = .scaleAspectFit
           imageView.layer.cornerRadius = 30
           imageView.clipsToBounds = true
           imageView.translatesAutoresizingMaskIntoConstraints = false
           return imageView
       }()

       private let nameEmailStackView: UIStackView = {
           let stackView = UIStackView()
           stackView.axis = .vertical
           stackView.spacing = 4
           stackView.translatesAutoresizingMaskIntoConstraints = false
           return stackView
       }()
    
    
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
    
    private let userInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    

    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let userStatsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let caloriesWaterView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let caloriesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let waterIntakeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let mealsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let nutritionOverviewView: NutritionalOverviewView = {
        let view = NutritionalOverviewView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var dashboardData: DashboardData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchDashboardData()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 249/255.0, green: 246/255.0, blue: 237/255.0, alpha: 1.0)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(userInfoView)
        contentView.addSubview(caloriesWaterView)
        contentView.addSubview(mealsStackView)
        contentView.addSubview(nutritionOverviewView)
        
        userInfoView.addSubview(avatarImageView)
                userInfoView.addSubview(nameEmailStackView)
                nameEmailStackView.addArrangedSubview(nameLabel)
                nameEmailStackView.addArrangedSubview(emailLabel)
        userInfoView.addSubview(nameLabel)
        userInfoView.addSubview(emailLabel)
        userInfoView.addSubview(userStatsStackView)
        
        caloriesWaterView.addSubview(caloriesLabel)
        caloriesWaterView.addSubview(waterIntakeLabel)
        
        setupConstraints()
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
            
            userInfoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            userInfoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            userInfoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            avatarImageView.topAnchor.constraint(equalTo: userInfoView.topAnchor, constant: 20),
                        avatarImageView.leadingAnchor.constraint(equalTo: userInfoView.leadingAnchor, constant: 20),
                        avatarImageView.widthAnchor.constraint(equalToConstant: 60),
                        avatarImageView.heightAnchor.constraint(equalToConstant: 60),

                        nameEmailStackView.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
                        nameEmailStackView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 15),
                        nameEmailStackView.trailingAnchor.constraint(equalTo: userInfoView.trailingAnchor, constant: -20),

            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 15),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            userStatsStackView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
            userStatsStackView.leadingAnchor.constraint(equalTo: userInfoView.leadingAnchor, constant: 20),
            userStatsStackView.trailingAnchor.constraint(equalTo: userInfoView.trailingAnchor, constant: -20),
            userStatsStackView.bottomAnchor.constraint(equalTo: userInfoView.bottomAnchor, constant: -20),
            
            caloriesWaterView.topAnchor.constraint(equalTo: userInfoView.bottomAnchor, constant: 20),
            caloriesWaterView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            caloriesWaterView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            caloriesLabel.topAnchor.constraint(equalTo: caloriesWaterView.topAnchor, constant: 15),
            caloriesLabel.leadingAnchor.constraint(equalTo: caloriesWaterView.leadingAnchor, constant: 15),
            
            waterIntakeLabel.topAnchor.constraint(equalTo: caloriesLabel.bottomAnchor, constant: 10),
            waterIntakeLabel.leadingAnchor.constraint(equalTo: caloriesWaterView.leadingAnchor, constant: 15),
            waterIntakeLabel.bottomAnchor.constraint(equalTo: caloriesWaterView.bottomAnchor, constant: -15),
            
            mealsStackView.topAnchor.constraint(equalTo: caloriesWaterView.bottomAnchor, constant: 20),
            mealsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mealsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            nutritionOverviewView.topAnchor.constraint(equalTo: mealsStackView.bottomAnchor, constant: 20),
            nutritionOverviewView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nutritionOverviewView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nutritionOverviewView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func fetchDashboardData() {
        APIService.shared.getDashboardData { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.dashboardData = data
                    self?.updateUI(with: data)
                case .failure(let error):
                    print("Error fetching dashboard data: \(error)")
                    // Handle error (e.g., show an alert)
                }
            }
        }
    }
    
    private func updateUI(with dashboardData: DashboardData) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Update user info
            self.nameLabel.text = dashboardData.user.name
            self.emailLabel.text = dashboardData.user.email
            
            // Update profile info
            if dashboardData.user.gender == "female" {
                self.avatarImageView.image = UIImage(named: "avatar_f")
            } else {
                self.avatarImageView.image = UIImage(named: "avatar_m")
            }
            
            // Update stats
            self.updateUserStats(with: dashboardData)
            
            // Only update meals if there are any
            if !dashboardData.todayMeals.isEmpty {
                self.updateMeals(with: dashboardData.todayMeals)
            }
            
            self.updateNutritionOverview(with: dashboardData.todayNutrition)
            
            // Update calories and water intake
            self.caloriesLabel.text = "Calories: \(dashboardData.stats.todayCalories) kcal"
            self.waterIntakeLabel.text = "Water Intake: \(dashboardData.stats.waterIntake) ml"
        }
    }
    
    private func updateUserStats(with data: DashboardData) {
           let stats = [
               ("Weight", "\(data.stats.weight) kg"),
               ("BMI", data.stats.bmi),
               ("Gender", data.user.gender.capitalized),
               ("Weight Loss", String(format: "%.1f kg", data.stats.weightChange))
           ]
           
           userStatsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
           
           let row1 = createStatRow(title1: stats[0].0, value1: stats[0].1, title2: stats[1].0, value2: stats[1].1)
           let row2 = createStatRow(title1: stats[2].0, value1: stats[2].1, title2: stats[3].0, value2: stats[3].1)
           
           userStatsStackView.addArrangedSubview(row1)
           userStatsStackView.addArrangedSubview(row2)
       }
       
       private func createStatRow(title1: String, value1: String, title2: String, value2: String) -> UIView {
           let rowView = UIView()
           
           let stat1View = createStatView(title: title1, value: value1)
           let stat2View = createStatView(title: title2, value: value2)
           
           rowView.addSubview(stat1View)
           rowView.addSubview(stat2View)
           
           stat1View.translatesAutoresizingMaskIntoConstraints = false
           stat2View.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([
               stat1View.topAnchor.constraint(equalTo: rowView.topAnchor),
               stat1View.leadingAnchor.constraint(equalTo: rowView.leadingAnchor),
               stat1View.bottomAnchor.constraint(equalTo: rowView.bottomAnchor),
               stat1View.widthAnchor.constraint(equalTo: rowView.widthAnchor, multiplier: 0.5),
               
               stat2View.topAnchor.constraint(equalTo: rowView.topAnchor),
               stat2View.trailingAnchor.constraint(equalTo: rowView.trailingAnchor),
               stat2View.bottomAnchor.constraint(equalTo: rowView.bottomAnchor),
               stat2View.widthAnchor.constraint(equalTo: rowView.widthAnchor, multiplier: 0.5)
           ])
           
           return rowView
       }
       
       private func createStatView(title: String, value: String) -> UIView {
           let view = UIView()
           
           let titleLabel = UILabel()
           titleLabel.text = title
           titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
           titleLabel.textColor = .gray
           
           let valueLabel = UILabel()
           valueLabel.text = value
           valueLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
           
           view.addSubview(titleLabel)
           view.addSubview(valueLabel)
           
           titleLabel.translatesAutoresizingMaskIntoConstraints = false
           valueLabel.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([
               titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
               titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               
               valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
               valueLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               valueLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
           ])
           
           return view
       }

    
    private func updateMeals(with meals: [MealData]) {
        mealsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for meal in meals {
            // Dodaj doručak
            if let breakfast = meal.breakfastRecipe {
                let mealView = createMealView(mealType: "breakfast", recipe: breakfast)
                mealsStackView.addArrangedSubview(mealView)
            }
            
            // Dodaj ručak
            if let lunch = meal.lunchRecipe {
                let mealView = createMealView(mealType: "lunch", recipe: lunch)
                mealsStackView.addArrangedSubview(mealView)
            }
            
            // Dodaj večeru
            if let dinner = meal.dinnerRecipe {
                let mealView = createMealView(mealType: "dinner", recipe: dinner)
                mealsStackView.addArrangedSubview(mealView)
            }
            
            // Dodaj užinu
            if let snack = meal.snackRecipe {
                let mealView = createMealView(mealType: "snack", recipe: snack)
                mealsStackView.addArrangedSubview(mealView)
            }
        }
        
        if mealsStackView.arrangedSubviews.isEmpty {
            let noMealsLabel = UILabel()
            noMealsLabel.text = "Nema obroka za danas"
            noMealsLabel.textAlignment = .center
            noMealsLabel.textColor = .gray
            noMealsLabel.font = UIFont.systemFont(ofSize: 16)
            mealsStackView.addArrangedSubview(noMealsLabel)
        }
    }
      
    private func createMealView(mealType: String, recipe: RecipeData) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(red: 241/255.0, green: 237/255.0, blue: 226/255.0, alpha: 1.0)
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
//        view.layer.borderColor = UIColor.systemGreen.cgColor
        view.layer.borderColor = UIColor(red: 50/255.0, green: 49/255.0, blue: 45/255.0, alpha: 1.0).cgColor
        view.layer.borderWidth = 0.5
        
        let mealTypeLabel = UILabel()
        mealTypeLabel.text = mealType.uppercased()
        mealTypeLabel.font = UIFont.italicSystemFont(ofSize: 12)
        mealTypeLabel.textColor = .gray
        
        let nameLabel = UILabel()
        nameLabel.text = recipe.name ?? "No name"
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = recipe.description ?? "No description"
        descriptionLabel.font = UIFont.italicSystemFont(ofSize: 14)
        descriptionLabel.textColor = .gray
        descriptionLabel.numberOfLines = 2
        
        let caloriesLabel = UILabel()
        if let calories = recipe.calories {
            caloriesLabel.text = "\(Int(Double(calories) ?? 0)) kcal"
        } else {
            caloriesLabel.text = "0 kcal"
        }
        caloriesLabel.font = UIFont.italicSystemFont(ofSize: 14)
        caloriesLabel.textAlignment = .right
        caloriesLabel.textColor = .systemGreen
        
        let mealIcon: UIImageView = {
            let imageView = UIImageView()
            switch mealType {
            case "breakfast":
                imageView.image = UIImage(systemName: "sunrise")
            case "lunch":
                imageView.image = UIImage(systemName: "sun.max")
            case "dinner":
                imageView.image = UIImage(systemName: "moon")
            case "snack":
                imageView.image = UIImage(systemName: "leaf")
            default:
                imageView.image = UIImage(systemName: "fork.knife")
            }
            imageView.tintColor = .systemGreen
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        view.addSubview(mealIcon)
        view.addSubview(mealTypeLabel)
        view.addSubview(nameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(caloriesLabel)
        
        mealIcon.translatesAutoresizingMaskIntoConstraints = false
        mealTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        caloriesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mealIcon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            mealIcon.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mealIcon.widthAnchor.constraint(equalToConstant: 40),
            mealIcon.heightAnchor.constraint(equalToConstant: 40),
            
            mealTypeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            mealTypeLabel.leadingAnchor.constraint(equalTo: mealIcon.trailingAnchor, constant: 10),
            
            nameLabel.topAnchor.constraint(equalTo: mealTypeLabel.bottomAnchor, constant: 5),
            nameLabel.leadingAnchor.constraint(equalTo: mealIcon.trailingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: mealIcon.trailingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            caloriesLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 5),
            caloriesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            caloriesLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            
            view.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
        ])
        
        return view
    }
                private func updateNutritionOverview(with nutrition: NutritionData) {
                    nutritionOverviewView.updateData(
                        calories: Int(nutrition.calories),
                        carbs: Int(nutrition.carbs),
                        fats: Int(nutrition.fats),
                        protein: Int(nutrition.protein)
                    )
                }
            }

class NutritionalOverviewView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Nutritional Overview"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "All meals including snack"
        label.font = UIFont.italicSystemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()

    
    private let totalCaloriesLabel: UILabel = {
        let label = UILabel()
        label.text = "Total\nCalories"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold) // Changed to .bold
        label.textColor = .black
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let calorieValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        label.textColor = .systemGreen
        label.textAlignment = .center
        return label
    }()
    
    private let kcalLabel: UILabel = {
        let label = UILabel()
        label.text = "kcal"
        label.font = UIFont.italicSystemFont(ofSize: 18) // italic font
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()

    
    private let macrosLabel: UILabel = {
        let label = UILabel()
        label.text = "% Daily Value *"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .gray
        return label
    }()
    
    private let carbsLabel: UILabel = {
        let label = UILabel()
        label.text = "Carbs"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private let carbsValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    private let fatsLabel: UILabel = {
        let label = UILabel()
        label.text = "Fats"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private let fatsValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    private let proteinLabel: UILabel = {
        let label = UILabel()
        label.text = "Protein"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        return label
    }()
    
    private let proteinValueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    private let explanationLabel: UILabel = {
        let label = UILabel()
        label.text = "* % Daily Value (DV) shows how much a nutrient contributes to your daily diet across all meals throughout the day. Calories are tailored to your meal plan."
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    private let topSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let bottomSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 8
        self.backgroundColor = UIColor.white
        
        let titleStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleStackView.axis = .vertical
        titleStackView.alignment = .center
        titleStackView.spacing = 4
        
        let caloriesStackView = UIStackView(arrangedSubviews: [totalCaloriesLabel, calorieValueLabel, kcalLabel])
        caloriesStackView.axis = .vertical
        caloriesStackView.alignment = .center
        caloriesStackView.spacing = 4
        
        let macrosStackView = UIStackView(arrangedSubviews: [macrosLabel, createMacrosRow(label: carbsLabel, value: carbsValueLabel), createMacrosRow(label: fatsLabel, value: fatsValueLabel), createMacrosRow(label: proteinLabel, value: proteinValueLabel)])
        macrosStackView.axis = .vertical
        macrosStackView.spacing = 8
        
        let mainStackView = UIStackView(arrangedSubviews: [titleStackView, topSeparator, caloriesStackView, bottomSeparator, macrosStackView, explanationLabel])
        mainStackView.axis = .vertical
        mainStackView.spacing = 16
        mainStackView.alignment = .fill
        
        self.addSubview(mainStackView)
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        topSeparator.translatesAutoresizingMaskIntoConstraints = false
        bottomSeparator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
            
            topSeparator.heightAnchor.constraint(equalToConstant: 2), // Increased thickness
            bottomSeparator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func createMacrosRow(label: UILabel, value: UILabel) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [label, value])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }
    
    func updateData(calories: Int, carbs: Int, fats: Int, protein: Int) {
        calorieValueLabel.text = "\(calories)"
        carbsValueLabel.text = "\(carbs)g"
        fatsValueLabel.text = "\(fats)g"
        proteinValueLabel.text = "\(protein)g"
    }
}
                                               
