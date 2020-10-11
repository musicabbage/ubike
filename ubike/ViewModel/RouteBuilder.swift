//
//  RouteBuilder.swift
//  ubike
//
//  Created by cabbage on 2020/10/6.
//  Copyright © 2020 cabbage. All rights reserved.
//

import Foundation
import RxSwift
import MapKit

enum RouteBuilder {
    
    enum RouteError: Error {
        case emptyResponse
    }
    
    static func buildRoute(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) -> Single<[MKRoute]> {
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        
        let directions = MKDirections.init(request: request)
        let observable = Observable<[MKRoute]>.create { (observer) -> Disposable in
            
            directions.calculate { (response: MKDirections.Response?, error: Error?) in
                if let error = error {
                    observer.onError(error)
                } else if let response = response {
                    observer.onNext(response.routes)
                    observer.onCompleted()
                } else {
                    observer.onError(RouteError.emptyResponse)
                }
            }
            
            return Disposables.create()
        }
        
        return observable.asSingle()
    }
}
