import Foundation
import Realm
import RealmSwift
import iDevData
import iDevCore

/**
 Operation to persist objects of `T` type to the Realm database.
 
 - Note: `T` must be a Realm `Object`.
 */
internal final class PersistDataOperation<T: Object>: Operation {
    /// The objects that you are going to persist.
    private let objects: [Object]
    
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
     Initialize a `PersistDataOperation` to write to the Realm data store.
     
     - Parameter objects: The objects you want persisted.
     
     */
    init(objects: [Object]) {
        self.objects = objects
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
            let realm = try Realm()
            try realm.write {
                realm.add(objects, update: true)
            }
            
            logInfo("Successfully wrote \(objects.count) objects to Realm.")
        } catch {
            logError("Error writing to Realm: \(error)")
        }
        
        isFinished = true
    }
}
