import Foundation
import Freddy
import iDevData
import iDevCore
import Realm
import RealmSwift

/**
 Completion handler that fires at the end of a `ParseJSONOperation`
 
 - Parameter Result<[Object]>: A `Result` enum that will return an array of `Objects` on success or
 an `ErrorType` on failure.
 
 - Returns: Nothing
 
 - Note: See `Result` for how to work with the `Result` type.
 */
typealias JSONParsingCompletionHandler = (Result<[Object]>) -> Void

/**
 Operation to parse `JSON` into objects of `T` type.
 
 - Note: `T` must be a a class that conforms to the `JSONDecodable` protocol.
 */
internal final class ParseJSONOperation<T: JSONDecodable>: Operation {
    /// The actions you want to happen at the end of the parsing operation.
    var completionHandler: JSONParsingCompletionHandler?
    /// The JSON you want to parse into objects of `T` type.
    private let json: JSON
    /// The resulting parsed objects after running `json` through Freddy.
    private var parsedObjects: [T]?
    
    // MARK: Operation Property Overrides
    private var internalFinished: Bool = false
    override var isFinished: Bool {
        get {
            return internalFinished
        }
        set (newValue) {
            willChangeValue(forKey: "isFinished")
            internalFinished = newValue
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
     Initialize a `ParseJSONOperation`
     
     - Parameter json: The `JSON` object you want to parse into Realm objects.
     
     - Note: At present, `JSON` is unique to Freddy, the JSON library we are using.
     
     */
    init(json: JSON) {
        self.json = json
        super.init()
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
        
        do {
            // Check if we are getting a dictionary or an array.
            if let data = try? json.array("data", alongPath: .NullBecomesNil) {
                parsedObjects = try data!.map(T.init)
            } else if (try? json.dictionary("data", alongPath: .NullBecomesNil)) != nil {
                let result = try T(json: json)
                parsedObjects = [result]
            }
        } catch {
            logError("Error parsing JSON: \(error)")
            if let completion = completionHandler {
                completion(Result.failure(error))
            }
            isFinished = true
            return
        }
        
        guard let parsed = parsedObjects else {
            logVerbose("Nothing left to parse. Punting out")
            isFinished = true
            return
        }
        
        let objects = parsed.flatMap { $0 as? Object }
        if let completion = completionHandler {
            completion(Result.success(objects))
        }
        
        isFinished = true
    }
}
