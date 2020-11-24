//
//  TableViewController.swift
//  ubike
//
//  Created by cabbage on 2020/9/22.
//  Copyright © 2020 cabbage. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa

class TableViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    
    private let selectStopRelay = PublishRelay<Stop?>()
    lazy var selectStopDriver = selectStopRelay.asDriver(onErrorJustReturn: nil)
    
    private let routeStopRelay = PublishRelay<Stop>()
    lazy var routeStopSignal = routeStopRelay.asSignal()
    
    private let locationRelay = BehaviorRelay<CLLocation?>(value: nil)

    private let kCellIdentifier = "spotCell"
    private let bag = DisposeBag()
    
    private var sections: [String] = [String]()
    private var stops: [String: [Stop]]?
    
    init(input:(Signal<CLLocation?>)) {
        
        super.init(nibName: nil, bundle: nil)
        input
            .compactMap { $0 }
            .emit(to: locationRelay)
            .disposed(by: bag)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviews()
        bindSubviews()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    //MARK: private
    private func setupSubviews() {
        tableView.tableFooterView = UIView()
        tableView.register(StopTableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
        tableView.separatorInset = .init(top: 0, left: 3, bottom: 0, right: 3)
    }
    
    private func bindSubviews() {
        UBikeViewModel.stopsDriver
        .do(onNext: { [weak self] (result) in
            guard self?.sections.count == 0 else { return }
            self?.sections = Array(result.keys)
        })
        .drive(onNext: { [weak self] (result) in
            self?.stops = result
            self?.tableView.reloadData()
        })
        .disposed(by: bag)
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
        
        locationRelay
            .asDriver()
            .drive(onNext: { [weak self] location in
                self?.tableView.reloadData()
            })
            .disposed(by: bag)
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let spots = stops?[sections[section]] else { return 0 }
        
        return spots.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath)
        guard let stops = stops?[sections[indexPath.section]] else { return cell }
        guard let stopCell = cell as? StopTableViewCell else { return cell }
        
        let stop = stops[indexPath.row]
        stopCell.configure(stop, enableRoute: locationRelay.value != nil)
        stopCell.routeSignal
            .compactMap({ [weak self] cell -> Stop? in
                guard let cell = cell, let index = self?.tableView.indexPath(for: cell),
                      index.section < self?.sections.count ?? 0 else { return nil }
                
                guard let section = self?.sections[index.section],
                      let stopsInSection = self?.stops?[section],
                      index.row < stopsInSection.count else { return nil }
                
                return stopsInSection[index.row]
            })
            .emit(to: routeStopRelay)
            .disposed(by: stopCell.reuseBag)
        
        return stopCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let spots = stops?[sections[indexPath.section]] else { return }
        selectStopRelay.accept(spots[indexPath.row])
    }
}

