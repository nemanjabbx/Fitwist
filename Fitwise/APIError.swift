import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case unauthorized
    case serverError(code: Int, message: String)
    case validationError(message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Error decoding response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Error encoding request: \(error.localizedDescription)"
        case .unauthorized:
            return "Session expired. Please login again."
        case .serverError(_, let message):
            return message
        case .validationError(let message):
            return message
        }
    }
}
