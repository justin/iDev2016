import UIKit

protocol Reusable: class {
    static var reuseIdentifier: String { get }
    static var nib: UINib { get }
}

extension UITableView {
    // Allowing UITableView class registration with Reusable
    func registerReusableNib(_ cellClass: Reusable.Type) {
        register(cellClass.nib, forCellReuseIdentifier: cellClass.reuseIdentifier)
    }
    
    // Safely dequeue a `Reusable` item
    func dequeueReusable<T: Reusable>(cellClass: T.Type) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: cellClass.reuseIdentifier) as? T else {
            fatalError("Misconfigured cell type, \(cellClass)!")
        }
        return cell
    }
    
    // Safely dequeue a `Reusable` item for a given index path
    func dequeueReusable<T: Reusable>(cellClass: T.Type, forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: cellClass.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Misconfigured cell type, \(cellClass)!")
        }
        
        return cell
    }
}
