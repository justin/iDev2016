import UIKit

class PublicationTableViewCell: UITableViewCell, Reusable {
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var synposisLabel: UILabel!
    
    static let nib:UINib = {
        return UINib(nibName: reuseIdentifier, bundle: Bundle.main)
    }()
    
    static var reuseIdentifier: String = {
        return "PublicationTableViewCell"
    }()
    
    var viewModel: PublicationViewModel? {
        didSet {
            updateValues()
        }
    }
}

private extension PublicationTableViewCell {
    func updateValues() {
        if let vm = viewModel {
            titleLabel.text = vm.title
            synposisLabel.text = vm.synposis
        }
    }
}
