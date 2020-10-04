//
//  SpotTableViewCell.swift
//  ubike
//
//  Created by cabbage on 2020/10/4.
//  Copyright © 2020 cabbage. All rights reserved.
//

import UIKit
import SnapKit

class SpotTableViewCell: UITableViewCell {
    
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
        contentView.addSubview(spotTitleLabel)
        spotTitleLabel.snp.makeConstraints { (make) in
            make.leadingMargin.topMargin.equalToSuperview().offset(3)
            make.trailing.lessThanOrEqualToSuperview().offset(-3)
        }
        contentView.addSubview(capacityLabel)
        capacityLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(spotTitleLabel)
            make.trailing.lessThanOrEqualToSuperview().offset(-3)
            make.top.equalTo(spotTitleLabel.snp.bottom).offset(3)
        }
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.leading.greaterThanOrEqualTo(capacityLabel.snp_trailingMargin)
            make.centerY.equalTo(capacityLabel)
            make.trailing.equalToSuperview().offset(-3)
        }
        contentView.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(spotTitleLabel)
            make.top.equalTo(capacityLabel.snp.bottom).offset(3)
            make.trailing.lessThanOrEqualToSuperview().offset(-3)
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
    
    func configure(_ spot: Spot) {
        spotTitleLabel.text = spot.sna
        addressLabel.text = spot.ar
        if let updateTime = spot.mday {
            timeLabel.text = updateTime.description
        }
        
        var textAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14, weight: .regular),
                                                             .foregroundColor: UIColor.text()]
        let capacityAtt = NSMutableAttributedString(string: " / \(String(spot.tot))", attributes: textAttributes)
        
        textAttributes[.foregroundColor] = UIColor.green()
        capacityAtt.insert(.init(string: String(spot.sbi), attributes: textAttributes), at: 0)        
        capacityLabel.attributedText = capacityAtt
    }

    
}
