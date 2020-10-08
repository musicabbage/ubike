//
//  LocationViewModel.swift
//  ubike
//
//  Created by cabbage on 2020/10/3.
//  Copyright © 2020 cabbage. All rights reserved.
//

import Foundation
import RxSwift
import MapKit

enum LocationError: Error {
    case systemDisabled, appDisabled, locationError
}

struct LocationViewModel {
    private static let locationDelegate = LocationDelegate()
    
    fileprivate static let locationSubject = PublishSubject<CLLocation>()
    fileprivate static let locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = locationDelegate
        return locationManager
    }()
    
    static let locationSingle = locationSubject.asSingle()
    
    static func refreshCurrentLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            locationSubject.onError(LocationError.systemDisabled)
          return
        }
        
        requestLocationAuthorization(CLLocationManager.authorizationStatus())
    }
    
    fileprivate static func requestLocationAuthorization(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            locationManager.requestLocation()
        }
    }
}

//MARK: delegate object
private class LocationDelegate: NSObject { }
extension LocationDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            LocationViewModel.locationSubject.onError(LocationError.appDisabled)
        default:
            LocationViewModel.requestLocationAuthorization(status)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        LocationViewModel.locationSubject.onError(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            LocationViewModel.locationSubject.onError(LocationError.locationError)
            return
        }
        LocationViewModel.locationSubject.onNext(location)
        LocationViewModel.locationSubject.onCompleted()
    }
}
