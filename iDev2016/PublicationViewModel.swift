import Foundation
import iDevData

struct PublicationViewModel {
    let title: String
    let synposis: String
    
    init(publication: Publication) {
        self.title = publication.title
        self.synposis = publication.synopsis
    }
}
