//
//  TableViewController.swift
//  ubike
//
//  Created by cabbage on 2020/9/22.
//  Copyright © 2020 cabbage. All rights reserved.
//

import UIKit
import RxSwift

class TableViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
//    var objects = [Any]()

    private let bag = DisposeBag()
    
    private var sections: [String] = [String]()
    private var spots: [String: [Spot]]?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        UBikeViewModel.spotsDriver
            .do(onNext: { [weak self] (result) in
                self?.sections = Array(result.keys)
            })
            .drive(onNext: { [weak self] (result) in
                self?.spots = result
                self?.tableView.reloadData()
            })
            .disposed(by: bag)
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

//    func refresh(spots: [String : [Spot]]) {
//        sections = Array(spots.keys)
//        self.spots = spots
//        tableView.reloadData()
//    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
//            if let indexPath = tableView.indexPathForSelectedRow {
//                let object = objects[indexPath.row] as! NSDate
//                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
//                controller.detailItem = object
//                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
//                controller.navigationItem.leftItemsSupplementBackButton = true
//                detailViewController = controller
//            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let spots = spots?[sections[section]] else { return 0 }
        
        return spots.count
//        let sectionName = sections[section]
        //let spots = spots[sectionName].c
//        return spots[sectionName]!.count//spots[sectio]!.count
//        return spots[].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //let object = objects[indexPath.row] as! NSDate
//        let spot =
//        cell.textLabel!.text = object.description
//        return cell
        guard let spots = spots?[sections[indexPath.section]] else { return cell }
        
        let spot = spots[indexPath.row]
        cell.textLabel?.text = "\(spot.sna)  剩餘\(spot.sbi)台"
        return cell
    }

}

