//
//  Colors.swift
//  ubike
//
//  Created by cabbage on 2020/10/4.
//  Copyright © 2020 cabbage. All rights reserved.
//

import UIKit

extension UIColor {
    static func alert() -> UIColor {
        return UIColor.init(named: "alert")!
    }
    
    static func alertBackground() -> UIColor {
        return UIColor.init(named: "alertBg")!
    }
    
    static func dark() -> UIColor {
        return UIColor.init(named: "dark")!
    }
    
    static func darkBackground() -> UIColor {
        return UIColor.init(named: "darkBg")!
    }
    
    static func green() -> UIColor {
        return UIColor.init(named: "green")!
    }
    
    static func light() -> UIColor {
        return UIColor.init(named: "light")!
    }
    
    static func lightBackground() -> UIColor {
        return UIColor.init(named: "lightBg")!
    }
    
    static func orange() -> UIColor {
        return UIColor.init(named: "orange")!
    }
    
    static func text() -> UIColor {
        return UIColor.init(named: "text")!
    }
    
    static func textPurple() -> UIColor {
        return UIColor.init(named: "textPurple")!
    }
}

extension UIColor {
    static func availableBikesColor(availableCount: Int) -> (text: UIColor, background: UIColor) {
        switch availableCount {
        case 0:
            return (.lightGray, .light())
        case 1..<10:
            return (.textPurple(), .orange())
        case 10...:
            return (.white, .green())
        default:
            return (.white, .alert())
        }
    }
}
