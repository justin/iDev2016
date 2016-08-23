import UIKit
import Realm
import RealmSwift
import iDevNetwork
import iDevData
import iDevCore

class PublicationsDataSource: NSObject, UITableViewDataSource {
    fileprivate let tableView: UITableView
    fileprivate let realm: Realm
    
    fileprivate var publications: Results<Publication>!
    fileprivate var notificationToken: NotificationToken? = nil
    
    init(tableView: UITableView, realm: Realm) {
        self.tableView = tableView
        self.realm = realm
        super.init()
        
        fetchData()
    }
    
    func publicationsCount() -> Int {
        return publications.count
    }
    
    func publication(atIndex index: Int) -> Publication {
        return publications[index]
    }
    
    // MARK: UITableViewDataSource
    // ====================================
    // UITableViewDataSource
    // ====================================
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return publications.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PublicationTableViewCell =
            tableView.dequeueReusable(cellClass: PublicationTableViewCell.self, forIndexPath: indexPath)
        
        let pub = publication(atIndex: indexPath.row)
        cell.viewModel = PublicationViewModel(publication: pub)
        return cell
    }
}

private extension PublicationsDataSource {
    func fetchData() {
        self.publications = realm.allObjects(ofType: Publication.self)
        notificationToken = self.publications.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .Initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
                break
            case .Update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                tableView.endUpdates()
                break
            case .Error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
    }
}
