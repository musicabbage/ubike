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
    private let dismissButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("↓", for: .normal)
        button.setTitle("↑", for: .selected)
        return button
    }()
    private let tableViewController: TableViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let tableViewController = storyboard.instantiateViewController(withIdentifier: "TableViewController") as! TableViewController
        return tableViewController
    }()
    
    private var detailBag: DisposeBag?
    private var detailContainerView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubViewControllers()
        bindSubviews()
        
        UBikeViewModel.fetch()            
    }
    
    private func setupSubViewControllers() {
        self.addChild(mapViewController)
        view.addSubview(mapViewController.view)
        mapViewController.didMove(toParent: self)
        mapViewController.view.snp.makeConstraints({ $0.top.bottom.left.right.equalToSuperview() })
        
        dismissButton.addTarget(self, action: #selector(dismissTable(_:)), for: .touchUpInside)
        tableContainer.addSubview(dismissButton)
        dismissButton.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        view.addSubview(tableContainer)
        addChild(tableViewController)
        tableContainer.addSubview(tableViewController.view)
        tableContainer.backgroundColor = .white
        tableContainer.addCornerAndShadow()
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
    
    private func bindSubviews() {
        tableViewController.selectStopDriver
            .drive(onNext: { [weak self] (stop) in
                guard let stop = stop, let center = stop.coordinate else { return }
                self?.mapViewController.mapview.setCenter(center, animated: true)
                if let button = self?.dismissButton, button.isSelected == false {
                    self?.dismissTable(button)
                }
            })
            .disposed(by: bag)
        
        tableViewController.routeStopSignal
            .compactMap { $0 }
            .emit(to: mapViewController.routeRelay)
            .disposed(by: bag)
        
        mapViewController.selectStopSignal
            .emit(onNext: { [weak self] stop in
                self?.showStopInfo(stop)
            })
            .disposed(by: bag)
        
    }
    
    private func showStopInfo(_ stop: Stop) {
        if !dismissButton.isSelected {
            dismissTable(dismissButton)
        }
        
        detailBag = DisposeBag()
        
        let container = UIView()
        container.backgroundColor = .white
        container.addCornerAndShadow()
        view.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
        }
        detailContainerView = container
        
        let detailViewController = DetailViewController(stop: stop)
        showStopViewController(detailViewController, isShow: true)
        
        let dismissButton = UIButton(type: .custom)
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.imageView?.tintColor = .text()
        dismissButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] in
                self?.detailBag = nil
            }, onDisposed: { [weak self] in
                self?.showStopViewController(detailViewController, isShow: false)
            })
            .disposed(by: detailBag!)
        container.addSubview(dismissButton)
        
        dismissButton.snp.makeConstraints { (make) in
            make.right.top.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 44, height: 36))
        }
        detailViewController.view.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(dismissButton.snp.bottom).offset(-18)
        }
    }
    
    private func showStopViewController(_ viewController: UIViewController, isShow: Bool) {
        guard let container = detailContainerView else { return }
        
        if isShow {
            container.addSubview(viewController.view)
            viewController.didMove(toParent: self)
            
            container.transform = .init(translationX: 0, y: 100)
            UIView.animate(withDuration: 0.3) {
                container.transform = .init(translationX: 0, y: 0)
            }
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            container.transform = .init(translationX: 0, y: 150)
        } completion: { _ in
            viewController.willMove(toParent: nil)
            viewController.removeFromParent()
            container.removeFromSuperview()
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

extension UIView {
    func addCornerAndShadow() {
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.masksToBounds = false
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = 12
    }
}
