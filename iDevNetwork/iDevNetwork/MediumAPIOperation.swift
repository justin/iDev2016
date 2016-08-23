import Foundation
import iDevData
import iDevCore
import Realm
import RealmSwift
import Freddy

/**
 Completion handler that fires at the end of a `MediumAPIOperationCompletionHandler`
 
 - Parameter Result<[Object]>: A `Result` enum that will return an array of `Objects` on success or
 an `ErrorType` on failure.
 
 - Returns: Nothing
 
 - Note: See `Result` for how to work with the `Result` type.
 */
public typealias MediumAPIOperationCompletionHandler = (Result<[Object]>) -> Void

/**
 Composite class that brings together network requests (`NetworkOperation`),
 JSON parsing (`ParseJSONOperation`) and persistence (`PersistDataOperation`) as a single operation.
 */
class MediumAPIOperation<T: JSONDecodable>: Operation {
    /// The API request you want to execute.
    fileprivate let request: GeneratedRequest
    /// The `URLSession` instance you are using.
    fileprivate var session: URLSession!
    /// Whether or not the operation should finish by persisting its returned objects.
    fileprivate let persist: Bool
    /// The actions you want to happen at the end of the parsing operation.
    var completionHandler: MediumAPIOperationCompletionHandler?
    /// The parsed objects generated after the `ParseJSONOperation` completes.
    fileprivate var parsedObjects: [Object]?
    /// The internal operation queue that runs the network, parsing, and persistance operations.
    fileprivate let internalQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "MediumAPIOperation Internal Queue"
        return queue
    }()
    /// The last thing we do before punting out.
    fileprivate var finalOperation: BlockOperation!
    
    // MARK: Operation Property Overrides
    private var internalExecuting: Bool = false
    override dynamic var isExecuting: Bool {
        get {
            return internalExecuting
        }
        
        set(newValue) {
            willChangeValue(forKey: "isExecuting")
            internalExecuting = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    private var internalFinished: Bool = false
    override dynamic var isFinished: Bool {
        get {
            return internalFinished
        }
        set (newAnswer) {
            willChangeValue(forKey: "isFinished")
            internalFinished = newAnswer
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    // MARK: Initialization
    // ====================================
    // Initialization
    // ====================================
    /**
     Initialize an `MediumAPIOperation` based off an `APIRequestTemplate`
     
     - Parameter requestTemplate: The request you want to fire off.
     - Parameter session: The `URLSession` you want to use for the request.
     - Parameter qos: The quality of service the operation should receive.
     - Parameter persist: Whether to persist the data returned or not. Defaults to yes.
     */
    init(requestTemplate: GeneratedRequest, session: URLSession,
         qos: QualityOfService = .default, persist: Bool = true, completionHandler: MediumAPIOperationCompletionHandler?) {
        self.request = requestTemplate
        self.session = session
        self.persist = persist
        self.internalQueue.qualityOfService = qos
        self.completionHandler = completionHandler
        super.init()
        
        self.qualityOfService = qos
    }
    
    // MARK: Operation
    // ====================================
    // Operation
    // ====================================
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        internalQueue.isSuspended = true
        
        let requestOperation = NetworkOperation(requestTemplate: request, session: session)
        requestOperation.qualityOfService = self.qualityOfService
        requestOperation.completionHandler = { result in
            switch (result) {
            case .success(let json):
                self.parseJSON(json: json)
                break
            case .failure(let error):
                logError("Error fetching JSON from API server: \(error)")
                if let completion = self.completionHandler {
                    completion(Result.failure(error))
                }
                
                self.isFinished = true
                break
            }
        }
        
        internalQueue.addOperation(requestOperation)
        
        finalOperation = BlockOperation(block: {
            if let completion = self.completionHandler,
                let objects = self.parsedObjects {
                completion(Result.success(objects))
            }
            
            self.isFinished = true
        })
        
        internalQueue.isSuspended = false
    }
}

// MARK: Private/Convenience
// ====================================
// Private/Convenience
// ====================================
private extension MediumAPIOperation {
    /**
     Fire off an internal operation to parse JSON into Realm `Object` models.
     
     - Parameter json: The JSON that you want to parse into objects.
     */
    func parseJSON(json: JSON) {
        let jsonOperation = ParseJSONOperation<T>(json: json)
        jsonOperation.qualityOfService = self.qualityOfService
        jsonOperation.completionHandler = { result in
            switch (result) {
            case .success(let objects):
                self.parsedObjects = objects
                self.persistData(objects: objects)
                break
            case .failure(let error):
                logError("Error parsing JSON: \(error)")
                if let completion = self.completionHandler {
                    completion(Result.failure(error))
                }
                self.isFinished = true
            }
        }
        
        if self.persist == false {
            finalOperation.addDependency(jsonOperation)
            internalQueue.addOperation(finalOperation)
        }
        
        internalQueue.addOperation(jsonOperation)
    }
    
    /**
     Fire off an internal operation to persist the parsed JSON.
     
     - Parameter objects: An array of Realm `Object` . . . objects to be persisted.
     */
    func persistData(objects: [Object]) {
        // If we don't want to persist our data, just punt out and return our `Object` items.
        guard persist == true else {
            if let completion = completionHandler,
               let objects = parsedObjects {
                completion(Result.success(objects))
            }
            
            isFinished = true
            return
        }
        
        let persistenceOperation = PersistDataOperation(objects: objects)
        persistenceOperation.qualityOfService = self.qualityOfService
        self.internalQueue.addOperation(persistenceOperation)
        
        finalOperation.addDependency(persistenceOperation)
        internalQueue.addOperation(finalOperation)
    }
}
