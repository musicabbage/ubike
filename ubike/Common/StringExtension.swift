//
//  StringExtension.swift
//  ubike
//
//  Created by cabbage on 2020/10/22.
//  Copyright © 2020 cabbage. All rights reserved.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
