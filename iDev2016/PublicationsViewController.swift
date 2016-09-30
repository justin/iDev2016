import UIKit
import Realm
import RealmSwift
import iDevData
import iDevNetwork
import iDevCore
import SafariServices

class PublicationsViewController: UITableViewController {
    var user: iDevData.User?
    var network: NetworkAPI!
    var realm: Realm? {
        didSet {
            configureDataSource()
        }
    }
    
    fileprivate var publicationsDataSource: PublicationsDataSource?

    // MARK: View Lifecycle
    // ====================================
    // View Lifecycle
    // ====================================
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerReusableNib(PublicationTableViewCell.self)
        tableView.dataSource = publicationsDataSource
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let user = user else { return }
        
         _ = network.getPublications(userID: user.id, completionHandler: { (result) in
            switch (result) {
            case .success(_):
                logInfo("Successfully persisted new stuff.")
                break
            case .failure(let error):
                logError("Error downloading publications: \(error)")
                break
            }
         })
    }
}

// MARK: UITableViewDelegate
// ====================================
// UITableViewDelegate
// ====================================
extension PublicationsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let ds = publicationsDataSource else { return }
        
        let pub = ds.publication(atIndex: indexPath.row)
        if let url = pub.url {
            let safari = SFSafariViewController(url: url)
            navigationController?.pushViewController(safari, animated: true)
        }
    }
}

private extension PublicationsViewController {
    func configureDataSource() {
        if let realm = realm {
            publicationsDataSource = PublicationsDataSource(tableView: tableView, realm: realm)
            tableView.dataSource = publicationsDataSource
            tableView.reloadData()
        }
    }
}
