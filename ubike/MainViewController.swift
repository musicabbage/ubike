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
import GradientLoadingBar

class MainViewController: UIViewController {
    
    private let kTableHeight = UIScreen.main.bounds.height * 0.6
    private let viewModel = UBikeViewModel()
    private let bag = DisposeBag()
    
    private let mapContainer = UIView()
    private let mapViewController: MapViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let mapViewController = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        return mapViewController
    }()
    
    private let loadingBar: GradientActivityIndicatorView = {
        let bar = GradientActivityIndicatorView()
        bar.gradientColors = [.green(), .green(), .green(), .light()]
        return bar
    }()
    
    private let tableContainer = UIView()
    private let dismissButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitle("↓", for: .selected)
        button.setTitle("↑", for: .normal)
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
        UBikeViewModel.stopsDriver
            .asObservable()
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.tableContainer.superview?.layoutIfNeeded()
                self.dismissTable(self.dismissButton)
            })
            .disposed(by: bag)
        
        
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let refreshButton = UIButton(type: .custom)
        refreshButton.setImage(UIImage.init(systemName: "arrow.clockwise.circle.fill"), for: .normal)
        refreshButton.contentVerticalAlignment = .fill
        refreshButton.contentHorizontalAlignment = .fill
        refreshButton.imageEdgeInsets = .init(top: -3, left: -3, bottom: -3, right: -3)
        refreshButton.imageView?.contentMode = .scaleAspectFit
        refreshButton.tintColor = .alert()
        let refreshItem = UIBarButtonItem(customView: refreshButton)
        navigationItem.rightBarButtonItem = refreshItem
        refreshButton.rx.tap
            .subscribe(onNext: { _ in
                UBikeViewModel.fetch()
            })
            .disposed(by: bag)
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.addSubview(loadingBar)
            loadingBar.translatesAutoresizingMaskIntoConstraints = false
            loadingBar.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(navigationBar.snp.bottom)
                make.height.equalTo(2)
            }
        }
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
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(kTableHeight)
        }
        tableViewController.view.snp.makeConstraints { (make) in
            make.top.equalTo(dismissButton.snp.bottom)
            make.height.equalTo(kTableHeight)
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
        
        LocationViewModel.refreshCurrentLocation()
        LocationViewModel.status
            .catchError({ error -> Observable<LocationStatus> in
                return .just(.NotAuthorized)
            })
            .subscribe(onNext: { [weak self] (status: LocationStatus) in
                switch status {
                case .Loading:
                    self?.loadingBar.fadeIn()
                case .Normal:
                    self?.loadingBar.fadeOut()
                default:
                    self?.loadingBar.fadeOut()
                }
            }, onError: { [weak self] error in
                self?.loadingBar.fadeOut()
                let error = (error as? LocationError) ?? LocationError.unknown
                switch error {
                case .appDisabled, .systemDisabled:
                    self?.showAlert(error: error)
                default:
                    break
                }
            })
            .disposed(by: bag)
    }
    
    private func showStopInfo(_ stop: Stop) {
        if dismissButton.isSelected {
            dismissTable(dismissButton)
        }
        
        if self.detailBag != nil {
            self.detailBag = nil
        }
        
        let detailBag = DisposeBag()
        
        let container = UIView()
        container.backgroundColor = .white
        container.addCornerAndShadow()
        view.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
        }
        detailContainerView = container
        
        let locationSignal = LocationViewModel.status
            .map { status -> CLLocation? in
                guard case let .Normal(location) = status else {
                    return nil
                }
                return location
            }
            .asSignal(onErrorJustReturn: nil)
        
        let detailViewController = DetailViewController(input: (locationSignal, stop))
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
            .disposed(by: detailBag)
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
        
        detailViewController.navigateSignal
            .emit(to: self.mapViewController.routeRelay)
            .disposed(by: detailBag)
        
        self.detailBag = detailBag
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
        let toDismiss = sender.isSelected
        sender.isSelected = !toDismiss
        
        tableContainer.snp.updateConstraints({
            $0.bottom.equalToSuperview().offset(toDismiss ? kTableHeight : 0)
        })
        UIView.animate(withDuration: 0.3, animations: {
            self.tableContainer.superview?.layoutIfNeeded()
        })
    }
}

//MARK: - location alert
extension MainViewController {
    func showAlert(error: LocationError) {
        
        let checkAuth = (error == .appDisabled)
        let message = checkAuth ? "need_location_authorization".localized() : "get_location_failed".localized()
        
        let alert = UIAlertController(title: "notice".localized(),
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(.init(title: "confirm".localized(), style: .cancel, handler: nil))
        if checkAuth {
            alert.addAction(.init(title: "go_setting".localized(), style: .default, handler: { _ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
        }
        present(alert, animated: true, completion: nil)
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
