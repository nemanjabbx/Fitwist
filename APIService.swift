import Foundation
extension Notification.Name {
    static let userNeedsToLogin = Notification.Name("userNeedsToLogin")
}

extension NotificationCenter {
    static func postUserNeedsToLogin(animated: Bool = true) {
        NotificationCenter.default.post(
            name: .userNeedsToLogin,
            object: nil,
            userInfo: ["animated": animated]
        )
    }
}
// MARK: - Data Structures

public struct RegistrationData: Codable {
    var name: String
    var email: String
    var password: String
    var password_confirmation: String
    var height: String
    var weight: String
    var date_of_birth: String
    var gender: String
    var activity_level: String
    var goal: String
    var dietary_restrictions: String?
    var allergy_groups: [Int]?
    var unit_system: String

    public init(name: String = "", email: String = "", password: String = "", password_confirmation: String = "", height: String = "", weight: String = "", date_of_birth: String = "", gender: String = "", activity_level: String = "", goal: String = "", dietary_restrictions: String? = nil, allergy_groups: [Int]? = nil, unit_system: String = "") {
        self.name = name
        self.email = email
        self.password = password
        self.password_confirmation = password_confirmation
        self.height = height
        self.weight = weight
        self.date_of_birth = date_of_birth
        self.gender = gender
        self.activity_level = activity_level
        self.goal = goal
        self.dietary_restrictions = dietary_restrictions
        self.allergy_groups = allergy_groups
        self.unit_system = unit_system
    }
}

struct Empty: Codable {}

struct RegistrationResponse: Codable {
    let message: String
    let accessToken: String
    let tokenType: String
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case message
        case accessToken = "access_token"
        case tokenType = "token_type"
        case user
    }
}
struct LoginResponse: Codable {
    let message: String
    let accessToken: String
    let tokenType: String
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case message
        case accessToken = "access_token"
        case tokenType = "token_type"
        case user
    }
}

struct User: Codable {
    let id: Int
    let name: String
    let email: String
    let emailVerifiedAt: String?
    let role: String
    let dailyCalorieTarget: Int?
    let subscriptionType: String
    let subscriptionExpiresAt: String?
    let trialEndsAt: String?
    let createdAt: String
    let updatedAt: String
    let profile: UserProfile
    let allergyGroups: [AllergyGroup]
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, role, profile
        case emailVerifiedAt = "email_verified_at"
        case dailyCalorieTarget = "daily_calorie_target"
        case subscriptionType = "subscription_type"
        case subscriptionExpiresAt = "subscription_expires_at"
        case trialEndsAt = "trial_ends_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case allergyGroups = "allergy_groups"
    }
}

struct UserProfile: Codable {
    let id: Int
    let userId: Int
    let height: String
    let startWeight: String
    let currentWeight: String
    let startBmi: String
    let currentBmi: String
    let dateOfBirth: String
    let gender: String
    let activityLevel: String
    let goal: String
    let dailyWaterGoal: Int?
    let dietaryRestrictions: String
    let preferredSystem: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, height, gender, goal
        case userId = "user_id"
        case startWeight = "start_weight"
        case currentWeight = "current_weight"
        case startBmi = "start_bmi"
        case currentBmi = "current_bmi"
        case dateOfBirth = "date_of_birth"
        case activityLevel = "activity_level"
        case dailyWaterGoal = "daily_water_goal"
        case dietaryRestrictions = "dietary_restrictions"
        case preferredSystem = "preferred_system"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
struct AllergyGroup: Codable {
    let id: Int
    let name: String
}

struct DashboardData: Codable {
    let user: UserInfo
    let stats: UserStats
    let todayMeals: [MealData]
    let todayNutrition: NutritionData
    let preferredSystem: String
}

struct UserInfo: Codable {
    let name: String
    let email: String
    let gender: String
}
struct UserStats: Codable {
    let weight: String
    let weightChange: Double
    let bmi: String
    let todayCalories: Int
    let waterIntake: Double
    let waterIntakeGoal: Int

    enum CodingKeys: String, CodingKey {
        case weight, weightChange, bmi, todayCalories, waterIntake, waterIntakeGoal
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        weight = try container.decode(String.self, forKey: .weight)
        weightChange = try container.decode(Double.self, forKey: .weightChange)
        bmi = try container.decode(String.self, forKey: .bmi)
        todayCalories = try container.decode(Int.self, forKey: .todayCalories)
        
        // Fleksibilno dekodiranje waterIntake
        if let waterIntakeString = try? container.decode(String.self, forKey: .waterIntake) {
            waterIntake = Double(waterIntakeString) ?? 0.0
        } else {
            waterIntake = try container.decode(Double.self, forKey: .waterIntake)
        }
        
        // Fleksibilno dekodiranje waterIntakeGoal
        if let intValue = try? container.decode(Int.self, forKey: .waterIntakeGoal) {
                    waterIntakeGoal = intValue
                } else if let stringValue = try? container.decode(String.self, forKey: .waterIntakeGoal),
                          let intFromString = Int(stringValue) {
                    waterIntakeGoal = intFromString
                } else {
                    print("Warning: Using fallback water intake goal")
                    waterIntakeGoal = 2000 // Fallback samo ako sve ostalo ne uspe
                }
    }
}



struct NutritionData: Codable {
    let carbs: Double
    let fats: Double
    let protein: Double
    let calories: Double
}
struct MealData: Codable {
    let id: Int?
    let mealPlanId: Int?
    let date: String
    let breakfastRecipe: RecipeData?
    let lunchRecipe: RecipeData?
    let dinnerRecipe: RecipeData?
    let snackRecipe: RecipeData?
    
    enum CodingKeys: String, CodingKey {
        case id
        case mealPlanId = "meal_plan_id"
        case date
        case breakfastRecipe = "breakfast_recipe"
        case lunchRecipe = "lunch_recipe"
        case dinnerRecipe = "dinner_recipe"
        case snackRecipe = "snack_recipe"
    }
}

struct TodayMealsData: Codable {
    let meals: [MealData]
    let nutrition: NutritionData
    let preferredSystem: String
}



struct RecipeData: Codable {
    let id: Int
    let name: String?
    let description: String?
    let calories: String?
    let carbohydrates: String?
    let fats: String?
    let protein: String?
    let difficulty: String?
    let preparationTime: Int?
    let cookingTime: Int?
    let servingSize: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, calories, carbohydrates, fats, protein, difficulty
        case preparationTime = "preparation_time"
        case cookingTime = "cooking_time"
        case servingSize = "serving_size"
    }
}

struct UserPreferences: Codable {
    let preferred_system: String
    let dietary_restrictions: String?
    let activity_level: String
    let goal: String
}

struct ErrorResponse: Codable {
    let message: String
}
struct ActivityData: Codable {
    let weights: [WeightEntry]?
    let waterIntakes: [WaterIntakeEntry]?
    let exercises: [ExerciseEntry]?
    let todayWaterIntake: Double?
    let waterIntakeGoal: Int // non-optional
    
    enum CodingKeys: String, CodingKey {
        case weights, exercises, waterIntakes
        case todayWaterIntake
        case waterIntakeGoal
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        weights = try? container.decode([WeightEntry].self, forKey: .weights)
        waterIntakes = try? container.decode([WaterIntakeEntry].self, forKey: .waterIntakes)
        exercises = try? container.decode([ExerciseEntry].self, forKey: .exercises)
        todayWaterIntake = try? container.decode(Double.self, forKey: .todayWaterIntake)
        
        if let intValue = try? container.decode(Int.self, forKey: .waterIntakeGoal) {
            waterIntakeGoal = intValue
            print("Decoded waterIntakeGoal as Int: \(intValue)")
        } else if let stringValue = try? container.decode(String.self, forKey: .waterIntakeGoal),
                  let intFromString = Int(stringValue) {
            waterIntakeGoal = intFromString
            print("Decoded waterIntakeGoal from String: \(intFromString)")
        } else {
            print("Using default waterIntakeGoal")
            waterIntakeGoal = 1749 // default vrednost
        }
    }
}
struct WeightEntry: Codable {
    let id: Int
    let userId: Int
    let date: String
    let activityType: String
    let value: Double
    let unit: String
    let additionalData: String?
    let notes: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case date
        case activityType = "activity_type"
        case value
        case unit
        case additionalData = "additional_data"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(Int.self, forKey: .userId)
        date = try container.decode(String.self, forKey: .date)
        activityType = try container.decode(String.self, forKey: .activityType)
        unit = try container.decode(String.self, forKey: .unit)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        
        // Handle value that could be string or number
        if let stringValue = try? container.decode(String.self, forKey: .value) {
            value = Double(stringValue) ?? 0.0
        } else {
            value = try container.decode(Double.self, forKey: .value)
        }
        
        // Handle additionalData that could be string, array or null
        if let stringData = try? container.decode(String.self, forKey: .additionalData) {
            additionalData = stringData
        } else if let _ = try? container.decodeNil(forKey: .additionalData) {
            additionalData = nil
        } else {
            additionalData = "[]" // Default to empty array string if it's an empty array in JSON
        }
    }
}

struct WaterIntakeEntry: Codable {
    let id: Int
    let userId: Int
    let date: String
    let activityType: String
    let value: Double
    let unit: String
    let additionalData: String?
    let notes: String?
    let createdAt: String
    let updatedAt: String
    
    var parsedDate: Date {
           let formatter = DateFormatter()
           formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
           if let date = formatter.date(from: date) {
               return date
           }
           // Ako ne može da parsira originalni format, probaj alternativni
           formatter.dateFormat = "yyyy-MM-dd"
           return formatter.date(from: date) ?? Date()
       }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case date
        case activityType = "activity_type"
        case value
        case unit
        case additionalData = "additional_data"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(Int.self, forKey: .userId)
        date = try container.decode(String.self, forKey: .date)
        activityType = try container.decode(String.self, forKey: .activityType)
        unit = try container.decode(String.self, forKey: .unit)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        additionalData = try container.decodeIfPresent(String.self, forKey: .additionalData)
        
        if let stringValue = try? container.decode(String.self, forKey: .value) {
            value = Double(stringValue) ?? 0.0
        } else {
            value = try container.decode(Double.self, forKey: .value)
        }
    }
    
    var time: String? {
        guard let additionalData = additionalData,
              let data = additionalData.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: String] else {
            return nil
        }
        return json["time"]
    }
}

struct ExerciseEntry: Codable {
    let id: Int
    let userId: Int
    let date: String
    let activityType: String
    let value: Double
    let unit: String
    let additionalData: String?
    let notes: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case date
        case activityType = "activity_type"
        case value
        case unit
        case additionalData = "additional_data"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(Int.self, forKey: .userId)
        date = try container.decode(String.self, forKey: .date)
        activityType = try container.decode(String.self, forKey: .activityType)
        unit = try container.decode(String.self, forKey: .unit)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        additionalData = try container.decodeIfPresent(String.self, forKey: .additionalData)
        
        if let stringValue = try? container.decode(String.self, forKey: .value) {
            value = Double(stringValue) ?? 0.0
        } else {
            value = try container.decode(Double.self, forKey: .value)
        }
    }
    
    var exerciseType: String? {
        guard let additionalData = additionalData,
              let data = additionalData.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: String] else {
            return nil
        }
        return json["exercise_type"]
    }
}

// MARK: - APIService

class APIService {
    static let shared = APIService()
    private init() {}
    
    private let baseURL = "https://bbxperience.info/api"
    
    func register(userData: RegistrationData, completion: @escaping (Result<RegistrationResponse, Error>) -> Void) {
        performRequest(endpoint: "/app-register", method: "POST", body: userData, completion: completion)
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        let body = ["email": email, "password": password]
        performRequest(endpoint: "/app-login", method: "POST", body: body, completion: completion)
    }
    
    func getDashboardData(completion: @escaping (Result<DashboardData, Error>) -> Void) {
            performRequest(endpoint: "/user/dashboard", method: "GET", completion: completion)
        }

    func getUserInfo(completion: @escaping (Result<UserInfo, Error>) -> Void) {
        performRequest(endpoint: "/user/info", method: "GET", completion: completion)
    }
    func getTodayMeals(completion: @escaping (Result<TodayMealsData, Error>) -> Void) {
        performRequest(endpoint: "/user/today-meals", method: "GET", completion: completion)
    }
    
    func getUserPreferences(completion: @escaping (Result<UserPreferences, Error>) -> Void) {
        performRequest(endpoint: "/user/preferences", method: "GET", completion: completion)
    }
    
    // MARK: - Generic Request Methods
       private func performRequest<T: Encodable, U: Decodable>(endpoint: String, method: String, body: T, completion: @escaping (Result<U, Error>) -> Void) {
           guard let url = URL(string: baseURL + endpoint) else {
               completion(.failure(NSError(domain: "APIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
               return
           }
           
           var request = URLRequest(url: url)
           request.httpMethod = method
           request.setValue("application/json", forHTTPHeaderField: "Accept")
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           
           do {
               request.httpBody = try JSONEncoder().encode(body)
           } catch {
               completion(.failure(error))
               return
           }
           
           addAuthHeader(to: &request)
           performDataTask(with: request, completion: completion)
       }
       
       private func performRequest<U: Decodable>(endpoint: String, method: String, completion: @escaping (Result<U, Error>) -> Void) {
           guard let url = URL(string: baseURL + endpoint) else {
               completion(.failure(NSError(domain: "APIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
               return
           }
           
           var request = URLRequest(url: url)
           request.httpMethod = method
           request.setValue("application/json", forHTTPHeaderField: "Accept")
           
           addAuthHeader(to: &request)
           performDataTask(with: request, completion: completion)
       }
    
    private func performDataTask<U: Decodable>(with request: URLRequest, completion: @escaping (Result<U, Error>) -> Void) {
           URLSession.shared.dataTask(with: request) { data, response, error in
               if let error = error {
                   completion(.failure(error))
                   return
               }
               
               guard let httpResponse = response as? HTTPURLResponse else {
                   completion(.failure(NSError(domain: "APIService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"])))
                   return
               }
               
               print("HTTP status code: \(httpResponse.statusCode)")
               
               if httpResponse.statusCode == 401 {
                   // Handle unauthorized error
                   self.handleUnauthorized()
                   completion(.failure(NSError(domain: "APIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Session expired. Please login again."])))
                   return
               }
               
               guard let data = data else {
                   completion(.failure(NSError(domain: "APIService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                   return
               }
               
               print("Received JSON: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
               
               if httpResponse.statusCode == 200 {
                   do {
                       let decodedResponse = try JSONDecoder().decode(U.self, from: data)
                       completion(.success(decodedResponse))
                   } catch {
                       print("Decoding error: \(error)")
                       completion(.failure(error))
                   }
               } else {
                   do {
                       let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                       completion(.failure(NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])))
                   } catch {
                       let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response"
                       completion(.failure(NSError(domain: "APIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Request failed: \(responseString)"])))
                   }
               }
           }.resume()
       }
       
    private func handleUnauthorized() {
            DispatchQueue.main.async {
                // Clear user data
                UserManager.shared.clearUserData()
                
                // Post notification to show login screen
                NotificationCenter.postUserNeedsToLogin(animated: true)
            }
        }
  
    private func addAuthHeader(to request: inout URLRequest) {
        if let token = UserManager.shared.getUserToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
    // MARK: - Activity Related Methods
        func getActivitiesData(completion: @escaping (Result<ActivityData, Error>) -> Void) {
            performRequest(endpoint: "/user/activities/data", method: "GET", completion: completion)
        }
        
        func addActivity(type: String, value: Double, date: String, unit: String, additionalData: [String: Any]? = nil, completion: @escaping (Result<ActivityData, Error>) -> Void) {
            // Create a codable structure for the request body
            struct ActivityRequest: Codable {
                let activity_type: String
                let value: Double
                let date: String
                let unit: String
                let additional_data: String
            }
            
            let additionalDataString = additionalData?.jsonString ?? "{}"
            let requestBody = ActivityRequest(
                activity_type: type,
                value: value,
                date: date,
                unit: unit,
                additional_data: additionalDataString
            )
            
            performRequest(endpoint: "/user/activities/\(type)", method: "POST", body: requestBody, completion: completion)
        }
        
        func updateActivity(id: Int, type: String, value: Double, date: String, unit: String, additionalData: [String: Any]? = nil, completion: @escaping (Result<ActivityData, Error>) -> Void) {
            struct ActivityUpdateRequest: Codable {
                let activity_type: String
                let value: Double
                let date: String
                let unit: String
                let additional_data: String
            }
            
            let additionalDataString = additionalData?.jsonString ?? "{}"
            let requestBody = ActivityUpdateRequest(
                activity_type: type,
                value: value,
                date: date,
                unit: unit,
                additional_data: additionalDataString
            )
            
            performRequest(endpoint: "/user/activities/\(type)/\(id)", method: "PUT", body: requestBody, completion: completion)
        }
        
        func deleteActivity(id: Int, type: String, completion: @escaping (Result<ActivityData, Error>) -> Void) {
            performRequest(endpoint: "/user/activities/\(type)/\(id)", method: "DELETE", completion: completion)
        }
        
        func getWaterIntakeData(date: String, completion: @escaping (Result<ActivityData, Error>) -> Void) {
            performRequest(endpoint: "/user/activities/water_intake?date=\(date)", method: "GET", completion: completion)
        }
    func addWaterIntake(value: Double, date: String, time: String, completion: @escaping (Result<ActivityData, Error>) -> Void) {
        let additionalData = ["time": time]
        
        addActivity(
            type: "water_intake",
            value: value,
            date: date,
            unit: "ml",
            additionalData: additionalData
        ) { result in
            switch result {
            case .success(let data):
                // Odmah nakon uspešnog dodavanja, osvežavamo podatke
                self.getActivitiesData { refreshResult in
                    completion(refreshResult)
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
extension Dictionary {
    var jsonString: String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
}
