import Foundation
import Realm
import RealmSwift
import Freddy

/// A collection of thoughts, from a Thought Leader (or `User`).
public final class Publication: Object, MediumContent {
    /// A unique identifier for the post.
    public dynamic var id: String = ""
    /// The publication's title.
    public dynamic var title: String = ""
    /// The publication's description.
    public dynamic var synopsis: String = ""
    /// The URL of the publication on Medium.
    public var url: URL? {
        return URL(string: urlString)
    }
    fileprivate dynamic var urlString: String = ""
    /// The URL to the publication's image on Medium.
    public var imageURL: URL? {
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

extension Publication: JSONDecodable {
    public convenience init(json: JSON) throws {
        self.init()
        id = try json.getString(at:"id")
        title = try json.getString(at:"name")
        synopsis = try json.getString(at:"description")
        urlString = try json.getString(at:"url")
        imageUrlString = try json.getString(at:"imageUrl")
    }
}
