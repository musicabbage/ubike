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
    
    //容內等間時新更料資、址地、量數位空、量數輛車前目站場、格車停總站場、稱名站場
    private let spotTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .darkText
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
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .text()
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        
        let controlsContainer = UIView()
        contentView.addSubview(controlsContainer)
        controlsContainer.snp.makeConstraints { (make) in
            make.top.trailing.bottom.equalToSuperview()
            make.width.equalTo(75)
        }
        let favoriteButton = UIButton.init(type: .custom)
        //favorite/favorite_border
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        favoriteButton.imageView?.tintColor = .lightBackground()
//        favoriteButton.layer.borderWidth = 1
//        favoriteButton.layer.borderColor = UIColor.green.cgColor
        controlsContainer.addSubview(favoriteButton)
        favoriteButton.snp.makeConstraints { (make) in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(30)
        }
        let routeButton = UIButton.init(type: .custom)
        //purchased.circle.fill
        routeButton.setImage(UIImage(systemName: "purchased.circle.fill"), for: .normal)
        routeButton.imageView?.tintColor = .lightBackground()
//        routeButton.layer.borderWidth = 1
//        routeButton.layer.borderColor = UIColor.green.cgColor
        controlsContainer.addSubview(routeButton)
        routeButton.snp.makeConstraints { (make) in
            make.width.height.centerX.equalTo(favoriteButton)
            make.top.equalTo(favoriteButton.snp.bottom)
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
            make.centerY.equalTo(capacityLabel)
            make.trailing.lessThanOrEqualTo(controlsContainer.snp.leading).offset(-3)
        }
        contentView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(spotTitleLabel)
            make.top.equalTo(capacityLabel.snp.bottom).offset(3)
            make.trailing.lessThanOrEqualTo(controlsContainer.snp.leading).offset(-3)
            make.bottomMargin.equalToSuperview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        spotTitleLabel.text = nil
        capacityLabel.text = nil
        addressLabel.text = nil
        timeLabel.text = nil
    }
    
    func configure(_ stop: Stop) {
        spotTitleLabel.text = stop.sna
        addressLabel.text = stop.ar
        if let updateTime = stop.mday {
            timeLabel.text = updateTime.description
        }
        
        var textAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14, weight: .regular),
                                                             .foregroundColor: UIColor.text()]
        let capacityAtt = NSMutableAttributedString(string: " / \(String(stop.tot))", attributes: textAttributes)
        
        textAttributes[.foregroundColor] = UIColor.green()
        capacityAtt.insert(.init(string: String(stop.sbi), attributes: textAttributes), at: 0)        
        capacityLabel.attributedText = capacityAtt
    }

    
}
