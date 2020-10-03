//
//  UBikeViewModel.swift
//  ubike
//
//  Created by cabbage on 2020/9/22.
//  Copyright © 2020 cabbage. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class UBikeViewModel {
    private static let API = "https://tcgbusfs.blob.core.windows.net/blobyoubike/YouBikeTP.gz"
    private static let allSpots = BehaviorRelay<[String: [Spot]]>(value: [:])
    
    static let spotsDriver = UBikeViewModel.allSpots.share(replay: 1, scope: .whileConnected).asDriver(onErrorJustReturn: [:])
    
    static func fetch() {
        let url = URL(string: UBikeViewModel.API)!
        let request = URLRequest(url: url)
        _ = URLSession.shared.rx.data(request: request)
            .map({ (data) -> [String: Spot] in
                do {
                    let spots = try JSONDecoder().decode(Result<[String: Spot]>.self, from: data)
                    return spots.value
                } catch {
                    print(error)
                    throw error
                }
            })
            .map({ (spots) -> [String: [Spot]] in
                let spotsArray = spots.reduce([Spot](), { (result, spotInfo) -> [Spot] in
                    var result = result
                    result.append(spotInfo.value)
                    return result
                })
                return Dictionary(grouping: spotsArray, by: { $0.sarea })
            })
            .subscribe(onNext: { (spots) in
                self.allSpots.accept(spots)
            })
    }
    
    //MARK: private
    
}
