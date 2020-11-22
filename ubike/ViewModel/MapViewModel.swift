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
    private let kDefaultLocation = CLLocation(latitude: 25.03, longitude: 121.3)
    
    let mapCenterDriver: Driver<CLLocationCoordinate2D>
    let routeDriver: Driver<[MKRoute]>
    
    private let userLocation: Signal<CLLocationCoordinate2D> = .empty()
    
    init(input: (userLocation: Observable<CLLocationCoordinate2D?>,
                 routeDestination: Observable<CLLocationCoordinate2D?>)) {
        mapCenterDriver = input.userLocation
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: kDefaultLocation.coordinate)
        
        let userLocation = input.userLocation.asSignal(onErrorRecover: { error -> Signal<CLLocationCoordinate2D?> in
            return Signal<CLLocationCoordinate2D?>.of(nil)
        })
        .asObservable()
        
        routeDriver = Observable.combineLatest(userLocation, input.routeDestination)
            .compactMap { ($0, $1) as? (CLLocationCoordinate2D, CLLocationCoordinate2D) }
            .flatMap({ (start, destination) -> Single<[MKRoute]> in
                return RouteBuilder.buildRoute(source: start, destination: destination)
            })
            .asDriver(onErrorJustReturn: [])
    }
}
