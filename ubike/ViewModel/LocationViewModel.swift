//
//  LocationViewModel.swift
//  ubike
//
//  Created by cabbage on 2020/10/3.
//  Copyright © 2020 cabbage. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import MapKit

enum LocationError: Error {
    case systemDisabled, appDisabled, locationError, unknown
}

enum LocationStatus: Equatable {
    case NotAuthorized
    case Loading
    case Normal(CLLocation)
    case Error(LocationError)
}

struct LocationViewModel {
    private static let locationDelegate = LocationDelegate()
    
    fileprivate static let locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = locationDelegate
        return locationManager
    }()
    
    static let status = statusSubject.observeOn(MainScheduler.instance)
    fileprivate static let statusSubject = PublishRelay<LocationStatus>()
    
    static func refreshCurrentLocation() {
        
        guard CLLocationManager.locationServicesEnabled() else {
            //系統層關閉
            statusSubject.accept(.Error(.systemDisabled))
            return
        }
        
        let authStatus = CLLocationManager.authorizationStatus()
        switch authStatus {
        case .notDetermined:
            //未授權
            statusSubject.accept(.NotAuthorized)
        case .denied, .restricted:
            //拒絕
            statusSubject.accept(.Error(.appDisabled))
        case .authorizedAlways, .authorizedWhenInUse:
            //更新位置
            requestLocationAuthorization(CLLocationManager.authorizationStatus())
        default:
            statusSubject.accept(.Error(.unknown))
        }
    }
    
    fileprivate static func requestLocationAuthorization(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            statusSubject.accept(.Loading)
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
            LocationViewModel.statusSubject.accept(.Error(.appDisabled))
        default:
            LocationViewModel.requestLocationAuthorization(status)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        LocationViewModel.statusSubject.accept(.Error(.locationError))
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            LocationViewModel.statusSubject.accept(.Error(.locationError))
            return
        }
        LocationViewModel.statusSubject.accept(.Normal(location))
    }
}
