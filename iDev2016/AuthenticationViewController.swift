import UIKit
import iDevData
import iDevNetwork
import Realm
import RealmSwift

class AuthenticationViewController: UIViewController, SegueHandlerType {
    enum SegueIdentifier: String {
        case showPublications = "ShowPublicationsSegue"
    }

    @IBOutlet fileprivate var tokenTextField: UITextField!
    @IBOutlet fileprivate var authenticateButton: UIButton!
    
    var realm: Realm?
    var network: NetworkAPI!
    
    // MARK: View Lifecycle
    // ====================================
    // View Lifecycle
    // ====================================
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: UIStoryboardSegue
    // ====================================
    // UIStoryboardSegue
    // ====================================
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifierForSegue(segue: segue) {
        case .showPublications:
            showPublications(segue: segue)
            break
        }
    }
}

// MARK: Actions
// ====================================
// Actions
// ====================================
extension AuthenticationViewController {
    @IBAction func authenticate(fromSender sender: AnyObject) {
        guard let token = tokenTextField.text else { return }
        
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = true
        config.networkServiceType = .default
        let session = URLSession(configuration: config)
    
        network = NetworkAPI(accessToken: token, session: session)
        
        /**
         If you hold onto a copy of this operation, you can listen to its status changes and update a pull-to-refresh or activity indicator on screen for your user.
        */
        _ = network.getProfile() { (result) in
            switch (result) {
            case .success(_):
                self.showPublications()
                break
            case .failure(let error):
                print(error)
                break
            }
        }

    }
}

private extension AuthenticationViewController {
    func showPublications() {
        DispatchQueue.main.async {
            self.performSegueWithIdentifier(segueIdentifier: .showPublications, sender: nil)
        }
        
    }
    
    func showPublications(segue: UIStoryboardSegue) {
        if let vc = segue.destination as? PublicationsViewController,
            let realm = realm,
            let user =  realm.objects(User.self).first {
            vc.user = user
            vc.network = network
            vc.realm = realm
        }
    }

}
