//
//  InsetLabel.swift
//  ubike
//
//  Created by cabbage on 2020/10/24.
//  Copyright © 2020 cabbage. All rights reserved.
//

import UIKit

class InsetLabel: UILabel {

    var insets: UIEdgeInsets = .zero
    
    override func drawText(in rect: CGRect) {
            super.drawText(in: rect.inset(by: insets))
        }
        
        override var intrinsicContentSize: CGSize {
            let size = super.intrinsicContentSize
            return CGSize(width: size.width + insets.left + insets.right,
                          height: size.height + insets.top + insets.bottom)
        }
}
