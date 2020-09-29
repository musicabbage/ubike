//
//  MapViewController.swift
//  ubike
//
//  Created by cabbage on 2020/9/22.
//  Copyright © 2020 cabbage. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapview: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
    }
    
    private func setupMapView() {
        let initialLocation = CLLocation(latitude: 25.03, longitude: 121.3)
        mapview.centerToLocation(initialLocation)
    }
    
    
}

private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    
}

