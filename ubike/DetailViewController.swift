//
//  DetailViewController.swift
//  ubike
//
//  Created by cabbage on 2020/9/22.
//  Copyright © 2020 cabbage. All rights reserved.
//

import UIKit
import SnapKit
import MapKit
import RxCocoa
import RxSwift

class DetailViewController: UIViewController {
    
    lazy var navigateSignal = navigateRelay.asSignal()
    private let navigateRelay = PublishRelay<Stop>()
    
    private let locationDriver: Driver<CLLocation?>
    
    private let bag = DisposeBag()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .darkText
        label.numberOfLines = 0
        return label
    }()
    
    private let capacityLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .light)
        label.numberOfLines = 0
        label.textColor = .text()
        return label
    }()
    
    private let navigationButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.setImage(UIImage(systemName: "arrow.up.right.diamond.fill"), for: .normal)
        button.setTitle(NSLocalizedString("navigation", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.titleEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: 0)
        button.contentEdgeInsets = .init(top: 5, left: 0, bottom: 5, right: 0)
        return button
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.imageView?.tintColor = .lightBackground()
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = button.imageView?.tintColor.cgColor
        return button
    }()
    
    private var userLocation: CLLocation? = nil
    private let stop: Stop
    
    init(input: (locationSignal: Signal<CLLocation?>, stop: Stop)) {
        stop = input.stop
        locationDriver = input.locationSignal.asDriver(onErrorJustReturn: nil)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        bindSubviews()
    }

    //MARK: private
    private func setupSubviews() {
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(capacityLabel)
        view.addSubview(addressLabel)
        view.addSubview(navigationButton)
        view.addSubview(favoriteButton)
        
        func setupConstraints() {
            titleLabel.snp.makeConstraints { (make) in
                make.top.left.equalToSuperview().offset(12)
                make.right.lessThanOrEqualTo(favoriteButton.snp.left).offset(-12)
            }
            
            capacityLabel.snp.makeConstraints { (make) in
                make.left.equalTo(titleLabel)
                make.top.equalTo(titleLabel.snp.bottom).offset(6)
            }
            
            addressLabel.snp.makeConstraints { (make) in
                make.left.equalTo(titleLabel)
                make.top.equalTo(capacityLabel.snp.bottom).offset(10)
                make.bottom.lessThanOrEqualTo(navigationButton.snp.top).offset(-8)
                make.right.lessThanOrEqualTo(favoriteButton.snp.left).offset(-12)
            }
            
            favoriteButton.snp.makeConstraints { (make) in
                make.right.equalTo(navigationButton)
                make.bottom.lessThanOrEqualTo(navigationButton.snp.top).offset(-12)
                make.width.height.equalTo(36)
            }
            
            navigationButton.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(12)
                make.right.bottom.equalToSuperview().offset(-12)
            }
        }
        
        func configure(stop: Stop) {
            titleLabel.text = stop.sna
            addressLabel.text = stop.ar
            
            var textAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14, weight: .regular),
                                                                 .foregroundColor: UIColor.text()]
            let capacityAtt = NSMutableAttributedString(string: " / \(String(stop.tot))", attributes: textAttributes)
            
            textAttributes[.foregroundColor] = UIColor.green()
            capacityAtt.insert(.init(string: String(stop.sbi), attributes: textAttributes), at: 0)
            capacityLabel.attributedText = capacityAtt
        }
        
        setupConstraints()
        updateNavigationButton(enabled: userLocation != nil)
        configure(stop: stop)
    }
    
    private func bindSubviews() {
        navigationButton.rx.tap
            .map({ [unowned self] in
                return self.stop
            })
            .bind(to: self.navigateRelay)
            .disposed(by: bag)
        
        locationDriver
            .drive(onNext: { [weak self] location in
                self?.userLocation = location
                self?.updateNavigationButton(enabled: location != nil)
            })
            .disposed(by: bag)
    }
    
    private func updateNavigationButton(enabled: Bool) {
        navigationButton.isEnabled = enabled
        if enabled {
            navigationButton.backgroundColor = .green()
            navigationButton.imageView?.tintColor = .text()
            navigationButton.setTitleColor(.text(), for: .normal)
        } else {
            navigationButton.backgroundColor = .lightGray
            navigationButton.imageView?.tintColor = .gray
            navigationButton.setTitleColor(.gray, for: .normal)
        }
    }
}

