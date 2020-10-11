//
//  MapViewController.swift
//  ubike
//
//  Created by cabbage on 2020/9/22.
//  Copyright © 2020 cabbage. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapview: MKMapView!
    let routeRelay = PublishRelay<Stop>()
    
    private let kAnnotationIdentifier = "annotation"
    private let kClusterIdentifier = "cluster"
    
    private let kDefaultLocation = CLLocation(latitude: 25.03, longitude: 121.3)
    private let locationManager = CLLocationManager()
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocationViewModel.refreshCurrentLocation()
        setupMapView()
        
        
        UBikeViewModel.stopsDriver
            .map { (result) -> [MKAnnotation] in
                result.reduce([Stop]()) { (result, spots) -> [Stop] in
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
            .disposed(by: bag)
        
        LocationViewModel.locationSingle
            .subscribe(onSuccess: { [weak self] (location) in
                self?.mapview.centerToLocation(location, regionRadius: 500)
                }, onError: { (error) in
                        
            })
            .disposed(by: bag)
        
        let viewModel = MapViewModel(input: (userLocation: LocationViewModel.locationSingle
                                                .map{ $0.coordinate }
                                                .asObservable(),
                                             routeDestination: routeRelay
                                                .map{ $0.coordinate }
                                                .asObservable()))
        bindSubviews(viewModel)
    }
    
    private func setupMapView() {
        mapview.centerToLocation(kDefaultLocation)
        mapview.showsUserLocation = true
        mapview.delegate = self
    }
    
    private func bindSubviews(_ viewModel: MapViewModel) {
        viewModel.routeDriver
            .drive(onNext: { [weak self] (route: [MKRoute]) in
                guard let route = route.first else { return }
                self?.drawRoute(route)
            })
            .disposed(by: bag)
    }
    
    //MARK: public
    
    //MARK: private
    private func drawRoute(_ route: MKRoute) {
        mapview.addOverlay(route.polyline) 
        mapview.setVisibleMapRect(
          mapview.visibleMapRect.union(
            route.polyline.boundingMapRect
          ),
          edgePadding: UIEdgeInsets(
            top: 0,
            left: 8,
            bottom: 8,
            right: 8
          ),
          animated: true
        )
    }
    
    //MARK: annotationView
    private class SpotAnnotation: NSObject, MKAnnotation {
        var coordinate: CLLocationCoordinate2D {
            return stop.coordinate ?? CLLocationCoordinate2DMake(0, 0)
        }
        let stop: Stop
        
        init(_ stop: Stop) {
            self.stop = stop
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
                        markerTintColor = .light()
                        glyphTintColor = .lightGray
                    case .some(1..<10):
                        markerTintColor = .orange()
                        glyphTintColor = .textPurple()
                    case .some(10...):
                        markerTintColor = .green()
                        glyphTintColor = .white
                    default:
                        markerTintColor = .alert()
                        glyphTintColor = .white
                    }
                }
                
                if let spotAnnotation = annotation as? SpotAnnotation {
                    availableBikes = spotAnnotation.stop.sbi
                    glyphText = String(availableBikes!)
                } else if let clusterAnnotation = annotation as? MKClusterAnnotation {
                    availableBikes = clusterAnnotation.memberAnnotations
                        .reduce(0, { (result, annotation) -> Int in
                            guard let spotAnnotation = annotation as? SpotAnnotation else { return result }
                            return result + spotAnnotation.stop.sbi
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
        
        var annotationView: MKAnnotationView?
        if let _ = annotation as? MKClusterAnnotation {
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: kClusterIdentifier)
            if annotationView == nil {
                annotationView = SpotAnnotationView(annotation: annotation, reuseIdentifier: kClusterIdentifier)
            }
        } else if let _ = annotation as? SpotAnnotation {
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: kAnnotationIdentifier)
            if annotationView == nil {
                annotationView = SpotAnnotationView(annotation: annotation, reuseIdentifier: kAnnotationIdentifier)
            }
            annotationView?.clusteringIdentifier = kClusterIdentifier
        } else {
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "unknown")
        }
            
        annotationView?.annotation = annotation
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        return MKClusterAnnotation(memberAnnotations: memberAnnotations)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .alertBackground()
        renderer.lineWidth = 3
        return renderer
    }
}

