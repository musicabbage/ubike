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
    
    private let kAnnotationIdentifier = "annotation"
    private let kClusterIdentifier = "cluster"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        
        _ = UBikeViewModel.spotsDriver.map { (result) -> [MKAnnotation] in
            result.reduce([Spot]()) { (result, spots) -> [Spot] in
                return result + spots.value
            }
            .map { (spot) -> MKAnnotation in
                let annotation = SpotAnnotation(spot)
                return annotation
            }
        }
        .drive(onNext: { [weak self] (annotations) in
            self?.mapview.addAnnotations(annotations)
        })
    }
    
    private func setupMapView() {
        let initialLocation = CLLocation(latitude: 25.03, longitude: 121.3)
        mapview.centerToLocation(initialLocation)
        mapview.delegate = self
    }
    
    //MARK: annotationView
    private class SpotAnnotation: NSObject, MKAnnotation {
        var coordinate: CLLocationCoordinate2D {
            return spot.coordinate ?? CLLocationCoordinate2DMake(0, 0)
        }
        let spot: Spot
        
        init(_ spot: Spot) {
            self.spot = spot
            super.init()
        }
    }
    
    private class SpotAnnotationView: MKMarkerAnnotationView {
        override var annotation: MKAnnotation? {
            didSet {
                
                var availableBikes: Int?
                defer {
                    switch availableBikes {
                    case .some(0):
                        markerTintColor = .lightGray
                    case .some(1..<10):
                        markerTintColor = .orange
                    case .some(10...):
                        markerTintColor = .green
                    default:
                        markerTintColor = .systemPink
                    }
                }
                
                if let spotAnnotation = annotation as? SpotAnnotation {
                    availableBikes = spotAnnotation.spot.sbi
                    glyphText = String(availableBikes!)
                } else if let clusterAnnotation = annotation as? MKClusterAnnotation {
                    availableBikes = clusterAnnotation.memberAnnotations
                        .reduce(0, { (result, annotation) -> Int in
                            guard let spotAnnotation = annotation as? SpotAnnotation else { return result }
                            return result + spotAnnotation.spot.sbi
                        })
                    glyphText = String(availableBikes!)
                } else {
                    glyphText = "?"
                }
            }
        }
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
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: kAnnotationIdentifier)
        
        if annotationView == nil {
            annotationView = SpotAnnotationView(annotation: annotation, reuseIdentifier: kAnnotationIdentifier)
            annotationView?.clusteringIdentifier = kClusterIdentifier
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        return MKClusterAnnotation(memberAnnotations: memberAnnotations)
    }
}

