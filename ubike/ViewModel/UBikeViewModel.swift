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
    private static let allStops = BehaviorRelay<[String: [Stop]]>(value: [:])
    
    static let stopsDriver = UBikeViewModel.allStops.share(replay: 1, scope: .whileConnected).asDriver(onErrorJustReturn: [:])
    
    static func fetch() {
        let url = URL(string: UBikeViewModel.API)!
        let request = URLRequest(url: url)
        _ = URLSession.shared.rx.data(request: request)
            .map({ (data) -> [String: Stop] in
                do {
                    let stops = try JSONDecoder().decode(Result<[String: Stop]>.self, from: data)
                    return stops.value
                } catch {
                    print(error)
                    throw error
                }
            })
            .map({ (stops) -> [String: [Stop]] in
                let stopsArray = stops.reduce([Stop](), { (result, stopInfo) -> [Stop] in
                    var result = result
                    result.append(stopInfo.value)
                    return result
                })
                return Dictionary(grouping: stopsArray, by: { $0.sarea })
            })
            .subscribe(onNext: { (stops) in
                self.allStops.accept(stops)
            })
    }
    
    //MARK: private
    
}
