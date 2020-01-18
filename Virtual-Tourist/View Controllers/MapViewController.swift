//
//  MapViewController.swift
//  Virtual-Tourist
//
//  Created by Dustin Mahone on 1/16/20.
//  Copyright © 2020 Dustin. All rights reserved.
//

import Foundation
import MapKit

class MapViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var navButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pinDeleteButton: UIButton!
    @IBOutlet weak var pinDeleteButtonHeight: NSLayoutConstraint!
    
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    
    //MARK: - Variables and Constants
    let defaults = UserDefaults.standard
    var isAddingPins = true
    var pins: [String:MKPointAnnotation] = [:]
    
    var init_latitude: CLLocationDegrees = 28.419529
    var init_longitude: CLLocationDegrees = -81.581197
    var init_latitude_span: CLLocationDistance = 0.05
    var init_longitude_span: CLLocationDistance = 0.08
    
    //MARK: - Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        mapView.delegate = self
        
        setDisplay()
        
        print(init_latitude)
        print(init_longitude)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerMap()
        setupGestures()
    }
    
    func viewWillDisappear() {
        
    }
    
    
    //MARK: - Methods
    func centerMap() {
        init_latitude = defaults.double(forKey: "initLat")
        init_longitude = defaults.double(forKey: "initLon")
        init_latitude_span = defaults.double(forKey: "initLatSpan")
        init_longitude_span = defaults.double(forKey: "initLonSpan")
        
        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(init_latitude, init_longitude)
        mapView.setCenter(center, animated: false)
        let span = MKCoordinateSpan(latitudeDelta: init_latitude_span, longitudeDelta: init_longitude_span)
        let coordinateRegion = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(coordinateRegion, animated: false)
    }
    
    func setDisplay() {
        tapGestureRecognizer.isEnabled = !isAddingPins
        longPressGestureRecognizer.isEnabled = isAddingPins
        
        pinDeleteButton.isHidden = isAddingPins
        
        if isAddingPins {
            navButton.title = "Edit"
            self.pinDeleteButtonHeight.constant = 0
        } else {
            navButton.title = "Done"
            self.pinDeleteButtonHeight.constant = 40
            //change after adding functionality
            pinDeleteButton.isEnabled = false
        }
    }
    
    func setupGestures() {
        let longPress = longPressGestureRecognizer
        longPress?.minimumPressDuration = 0.3
        longPress?.numberOfTapsRequired = 0
        longPress?.addTarget(self, action: #selector(longPressGesture))
    }
    
    @objc func longPressGesture(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: mapView)
        let coordinate: CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)
        let newPin = MKPointAnnotation()
        newPin.coordinate = coordinate
        mapView.addAnnotation(newPin)
        /*if longPressGestureRecognizer.state == .ended {
            self.mapView.addAnnotation(newPin)
                } else {
                    print("something else")
            } */
    }
        
    //MARK: - Actions
    @IBAction func navButtonPressed(_ sender: Any) {
        isAddingPins = !isAddingPins
        setDisplay()
    }
}

//MARK: - Extensions
extension MapViewController: MKMapViewDelegate {
    func mapView(_: MKMapView, regionDidChangeAnimated: Bool) {
        //persist center of map and zoom level
        let latitude = mapView.centerCoordinate.latitude
        //init_latitude = latitude //necessary?
        let longitude = mapView.centerCoordinate.longitude
        //init_longitude = longitude //necessary?
        let latitude_span = mapView.region.span.latitudeDelta
        //init_latitude_span = latitude_span
        let longitude_span = mapView.region.span.longitudeDelta
        //init_longitude_span = longitude_span
        defaults.set(latitude, forKey: "initLat")
        defaults.set(longitude, forKey: "initLon")
        defaults.set(latitude_span, forKey: "initLatSpan")
        defaults.set(longitude_span, forKey: "initLonSpan")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let pinId = UUID().uuidString
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinId)
        pinView.animatesDrop = false //needed?
        pinView.annotation = annotation
        print("map view annotation")
        return pinView
    }
}
