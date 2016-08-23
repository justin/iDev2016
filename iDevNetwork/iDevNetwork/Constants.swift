import Foundation

internal struct Constants {
    // Headers
    static let accept = "Accept"
    static let authorization = "Authorization"
    static let contentType = "Content-Type"
    
    // Values
    static let applicationJSON = "application/json"
    
    // Servers
    static let APIServer = "https://api.medium.com/v1"
}

internal enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

internal extension HTTPMethod {
    func toString() -> String {
        return self.rawValue
    }
}
