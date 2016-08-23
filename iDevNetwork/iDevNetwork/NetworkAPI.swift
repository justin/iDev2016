import Foundation
import Realm
import RealmSwift
import iDevData
import iDevCore

public final class NetworkAPI {
    /**
     Higher priority units of work to be processed. Should be reserved exclusively for user requested data.
     */
    fileprivate let foregroundQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Foreground Network Queue"
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    /// Lower priority units of work to be processed.
    fileprivate let backgroundQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Background Network Queue"
        queue.qualityOfService = .background
        return queue
    }()
    
    /// The API token provided by the Medium API
    private let accessToken: String
    /// The `URLSession` object you want to use to work with the API.
    private let session: URLSession
    
    // MARK: Initialization
    // ====================================
    // Initialization
    // ====================================
    
    /**
     Initialize a new `NetworkAPI` object.
     
     - Parameter accessToken: The API token provided by the Medium API administrator.
     - Parameter session: The `URLSession` object you want to use to work with the API.
     */
    public init(accessToken: String, session: URLSession) {
        self.accessToken = accessToken
        self.session = session
    }
    
    /**
     Retrieve the user profile for the authenticated user.
     
     - parameter accessToken: The API integration token from the Medium settings screen.
     - parameter session: The `URLSession` instance you want to perform the operation through.
     - parameter completionHandler: The optional completion handler that will return a `Result` instance with either a `User` object or an error.
     */
    public func getProfile(completionHandler: MediumAPIOperationCompletionHandler?) -> Operation {
        let template = GetUserProfileRequest(accessToken: accessToken)
        let operation = MediumAPIOperation<User>(requestTemplate: template, session: session, completionHandler: completionHandler)
        addToQueue(operation: operation)
        return operation
    }
    
    /**
     Retrieve the publications a user has access to.
     
     - parameter userID: The user's unique identifier.
     - parameter completionHandler: The optional completion handler that will return a `Result` instance with either a `User` object or an error.
     */
    public func getPublications(userID: String, completionHandler: MediumAPIOperationCompletionHandler?) -> Operation {
        let template = GetPublicationsRequest(userID: userID, accessToken: accessToken)
        let operation = MediumAPIOperation<Publication>(requestTemplate: template, session: session, completionHandler: completionHandler)
        addToQueue(operation: operation)
        return operation
    }
}

// MARK: Private/Convenience
// ====================================
// Private/Convenience
// ====================================
private extension NetworkAPI {
    /**
     Add the `Operation` to a prioritized operation queue.
     
     - Parameter operation: The `Operation` to run.
     */
    func addToQueue(operation: Operation) {
        if (operation.queuePriority == .low || operation.queuePriority == .veryLow) {
            backgroundQueue.addOperation(operation)
            return
        }
        
        foregroundQueue.addOperation(operation)
    }
}
