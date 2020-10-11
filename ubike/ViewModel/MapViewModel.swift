//
//  MapViewModel.swift
//  ubike
//
//  Created by cabbage on 2020/10/11.
//  Copyright © 2020 cabbage. All rights reserved.
//

import Foundation
import MapKit
import RxSwift
import RxCocoa

class MapViewModel {
    
    let routeDriver: Driver<[MKRoute]>
    
    init(input: (userLocation: Observable<CLLocationCoordinate2D?>,
                 routeDestination: Observable<CLLocationCoordinate2D?>)) {
        
        routeDriver = Observable.combineLatest(input.userLocation, input.routeDestination)
            .compactMap { ($0, $1) as? (CLLocationCoordinate2D, CLLocationCoordinate2D) }
            .flatMap({ (start, destination) -> Single<[MKRoute]> in
                return RouteBuilder.buildRoute(source: start, destination: destination)
            })
            .asDriver(onErrorJustReturn: [])
    }
}
