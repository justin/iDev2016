import Foundation
import Realm
import RealmSwift
import Freddy

/// Used to represent an authenticated Medium account.
public final class User: Object, MediumContent {
    /// A unique identifier for the user.
    public dynamic var id: String = ""
    /// The user’s username on Medium.
    public dynamic var username: String = ""
    /// The user’s name on Medium.
    public dynamic var name: String = ""
    /// The URL to the user’s profile on Medium.
    public var url: URL? {
        return URL(string: urlString)
    }
    fileprivate dynamic var urlString: String = ""
    /// The URL to the user’s avatar on Medium.
    public var imageUrl: URL? {
        return URL(string: imageUrlString)
    }
    fileprivate dynamic var imageUrlString: String = ""
    
    
    // MARK: Realm Overrides
    // ====================================
    // Realm Overrides
    // ====================================
    
    /**
     The Primary Key attribute used for Realm.
     
     - Returns: A `String` named for the variable attribute that is identified as the primary key.
     */
    override public static func primaryKey() -> String? {
        return "id"
    }
}

extension User: JSONDecodable {
    public convenience init(json: JSON) throws {
        self.init()
        id = try json.string("data", "id")
        username = try json.string("data", "username")
        name = try json.string("data", "name")
        urlString = try json.string("data", "url")
        imageUrlString = try json.string("data", "imageUrl")
    }
}
