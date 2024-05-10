//___FILEHEADER___

import UIKit
import DDPresenter

class ___FILEBASENAME___: UICollectionFlowPageViewController {

    let section = UICollectionViewFlowSectionPresenter()

    override func presenterDidLoad() {
        super.presenterDidLoad()
        
        // Do any additional setup after loading the presenter.
        
        // Register services.
        // register(service: TraceService.self) {
        //      TraceServiceImpl()
        // }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        presenter.collectionViewPresenter.setSections([section])
        
        // requestData { [weak self] list in
        //     guard let self else { return }
        //
        //     self.section.items = list.map {
        //         CellPresenter($0)
        //     }
        // }
    }

}
