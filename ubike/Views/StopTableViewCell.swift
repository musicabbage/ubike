//
//  StopTableViewCell.swift
//  ubike
//
//  Created by cabbage on 2020/10/4.
//  Copyright © 2020 cabbage. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class StopTableViewCell: UITableViewCell {
    
    var favoriteSignal: Signal<UITableViewCell?>!
    var routeSignal: Signal<UITableViewCell?>!
    
    var reuseBag = DisposeBag()
    private let bag = DisposeBag()
    
    //容內等間時新更料資、址地、量數位空、量數輛車前目站場、格車停總站場、稱名站場
    private let spotTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .text()
        return label
    }()
    
    private let capacityLabel: UILabel = {
        let label = InsetLabel()
        label.insets = .init(top: 1, left: 3, bottom: 1, right: 3)
        label.layer.cornerRadius = 3
        label.layer.backgroundColor = UIColor.lightBackground().cgColor
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .light)
        label.numberOfLines = 0
        label.textColor = .text()
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .light)
        label.textColor = .text()
        return label
    }()
    
    private let routeButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(systemName: "arrow.up.right.diamond.fill"), for: .normal)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        backgroundColor = .clear
        selectionStyle = .none
        let controlsContainer = UIView()
        contentView.addSubview(controlsContainer)
        controlsContainer.snp.makeConstraints { (make) in
            make.top.trailing.bottom.equalToSuperview()
            make.width.equalTo(75)
        }
        let favoriteButton = UIButton.init(type: .custom)
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        favoriteButton.imageView?.tintColor = .lightBackground()
        controlsContainer.addSubview(favoriteButton)
        favoriteButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        updateRouteButton(routeButton, enabled: false)
        
        controlsContainer.addSubview(routeButton)
        routeButton.snp.makeConstraints { (make) in
            make.width.height.centerX.equalTo(favoriteButton)
            make.top.equalTo(favoriteButton.snp.bottom)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        favoriteSignal = favoriteButton.rx.tap.map({ [weak self] _ -> UITableViewCell? in
            return self
        }).asSignal(onErrorJustReturn: nil)
        
        routeSignal = routeButton.rx.tap.map({ [weak self] _ -> UITableViewCell? in
            return self
        }).asSignal(onErrorJustReturn: nil)
        
        contentView.addSubview(spotTitleLabel)
        spotTitleLabel.snp.makeConstraints { (make) in
            make.leadingMargin.topMargin.equalToSuperview().offset(3)
            make.trailing.lessThanOrEqualTo(controlsContainer.snp.leading).offset(-3)
        }
        contentView.addSubview(capacityLabel)
        capacityLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(spotTitleLabel)
            make.trailing.lessThanOrEqualTo(controlsContainer).offset(-3)
            make.top.equalTo(spotTitleLabel.snp.bottom).offset(3)
        }
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.leading.greaterThanOrEqualTo(capacityLabel.snp_trailingMargin)
            make.top.equalTo(capacityLabel)
            make.trailing.lessThanOrEqualTo(controlsContainer.snp.leading).offset(-3)
        }
        contentView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(spotTitleLabel)
            make.top.equalTo(capacityLabel.snp.bottom).offset(7)
            make.trailing.lessThanOrEqualTo(controlsContainer.snp.leading).offset(-3)
            make.bottomMargin.equalToSuperview().offset(-3)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        spotTitleLabel.text = nil
        capacityLabel.text = nil
        addressLabel.text = nil
        timeLabel.text = nil
        
        reuseBag = DisposeBag()
    }
    
    func configure(_ stop: Stop, enableRoute isEnable: Bool) {
        updateRouteButton(routeButton, enabled: isEnable)
        spotTitleLabel.text = stop.sna
        addressLabel.text = stop.ar
        if let updateTime = stop.mday {
            let interval = Int((updateTime.timeIntervalSinceNow * -1).rounded(.toNearestOrAwayFromZero))
            if interval >= 180 {
                let min = Int((Float(interval) / 60.0).rounded(.towardZero))
                if min > 60 {
                    timeLabel.text = nil
                } else {
                    timeLabel.text = "\(min)\("min".localized()) \("last_update".localized())"
                }
            } else {
                timeLabel.text = "\(interval)\("sec".localized()) \("last_update".localized())"
            }
        }
        
        let capacityColor = UIColor.availableBikesColor(availableCount: stop.sbi)
        var textAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 10, weight: .regular),
                                                             .foregroundColor: UIColor.gray]
        let capacityAtt = NSMutableAttributedString(string: " / \(String(stop.tot))", attributes: textAttributes)
        
        textAttributes[.foregroundColor] = capacityColor.text
        textAttributes[.font] = UIFont.systemFont(ofSize: 10, weight: .semibold)
        capacityAtt.insert(.init(string: String(stop.sbi), attributes: textAttributes), at: 0)        
        capacityLabel.attributedText = capacityAtt
        capacityLabel.layer.backgroundColor = capacityColor.background.withAlphaComponent(0.65).cgColor
    }

    private func updateRouteButton(_ button: UIButton, enabled: Bool) {
        button.isEnabled = enabled
        if enabled {
            button.imageView?.tintColor = .lightBackground()
            return
        }
        
        button.imageView?.tintColor = .lightGray
    }
}
