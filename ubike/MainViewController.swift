//
//  MainViewController.swift
//  ubike
//
//  Created by cabbage on 2020/9/26.
//  Copyright © 2020 cabbage. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

class MainViewController: UIViewController {
    
    private let viewModel = UBikeViewModel()
    private let bag = DisposeBag()
    
    private let mapContainer = UIView()
    private let mapViewController: MapViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let mapViewController = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        return mapViewController
    }()
    
    private let tableContainer = UIView()
    private let tableViewController: TableViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let tableViewController = storyboard.instantiateViewController(withIdentifier: "TableViewController") as! TableViewController
        return tableViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubViewControllers()
        
        UBikeViewModel.fetch()            
    }
    
    private func setupSubViewControllers() {
        self.addChild(mapViewController)
        view.addSubview(mapViewController.view)
        mapViewController.didMove(toParent: self)
        mapViewController.view.snp.makeConstraints({ $0.top.bottom.left.right.equalToSuperview() })
        
        let dismissButton = UIButton(type: .custom)
        dismissButton.backgroundColor = .white
        dismissButton.setTitleColor(.systemBlue, for: .normal)
        dismissButton.setTitle("↓", for: .normal)
        dismissButton.setTitle("↑", for: .selected)
        dismissButton.addTarget(self, action: #selector(dismissTable(_:)), for: .touchUpInside)
        tableContainer.addSubview(dismissButton)
        dismissButton.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        view.addSubview(tableContainer)
        addChild(tableViewController)
        tableContainer.addSubview(tableViewController.view)
        tableViewController.didMove(toParent: self)
        tableContainer.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.6)
        }
        tableViewController.view.snp.makeConstraints { (make) in
            make.top.equalTo(dismissButton.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
 
    @objc private func dismissTable(_ sender: UIButton) {
        let toDismiss = !sender.isSelected
        
        tableContainer.snp.updateConstraints({
            $0.bottom.equalTo(toDismiss ? tableViewController.view.frame.height : 0)
        })
        UIView.animate(withDuration: 0.3, animations: {
            self.tableContainer.superview?.layoutIfNeeded()
        })
        sender.isSelected  = toDismiss
    }
}
