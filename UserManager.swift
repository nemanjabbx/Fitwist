import Foundation

class UserManager {
    static let shared = UserManager()
    
    private init() {}
    
    func saveUserData(token: String, userId: Int, email: String) {
        UserDefaults.standard.set(token, forKey: "userToken")
        UserDefaults.standard.set(userId, forKey: "userId")
        UserDefaults.standard.set(email, forKey: "userEmail")
    }
    
    func getUserToken() -> String? {
        return UserDefaults.standard.string(forKey: "userToken")
    }
    
    func getUserId() -> Int? {
        return UserDefaults.standard.integer(forKey: "userId")
    }
    
    func getUserEmail() -> String? {
        return UserDefaults.standard.string(forKey: "userEmail")
    }
    
    func clearUserData() {
        UserDefaults.standard.removeObject(forKey: "userToken")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "userEmail")
    }
    
    func isUserLoggedIn() -> Bool {
        return getUserToken() != nil
    }
}
