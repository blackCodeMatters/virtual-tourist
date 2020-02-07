//
//  MapViewController.swift
//  Virtual-Tourist
//
//  Created by Dustin Mahone on 1/16/20.
//  Copyright © 2020 Dustin. All rights reserved.
//

import Foundation
import MapKit
import CoreData

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

    var init_latitude: CLLocationDegrees = 0.0
    var init_longitude: CLLocationDegrees = 0.0
    var init_latitude_span: CLLocationDistance = 0.05
    var init_longitude_span: CLLocationDistance = 0.08
    
    var dataController: DataController!
    var mapPins: [Pin] = []
    var selectedPin: Pin?
    
    //for fetching photo data on pin drop
    var flickrPhotos: FlickrPhotos?
        
    //MARK: - Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        
        mapView.delegate = self
        setDisplay()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerMap()
        setupGestures()
        fetchPins()
    }
    
    //MARK: - Methods
    func centerMap() {
        if defaults.double(forKey: "initLat") == 0.0 {
            init_latitude = 28.374656
            init_longitude = -81.549415
            init_latitude_span = 0.05
            init_longitude_span = 0.08
        } else {
            init_latitude = defaults.double(forKey: "initLat")
            init_longitude = defaults.double(forKey: "initLon")
            init_latitude_span = defaults.double(forKey: "initLatSpan")
            init_longitude_span = defaults.double(forKey: "initLonSpan")
        }
        
        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(init_latitude, init_longitude)
        mapView.setCenter(center, animated: false)
        let span = MKCoordinateSpan(latitudeDelta: init_latitude_span, longitudeDelta: init_longitude_span)
        let coordinateRegion = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(coordinateRegion, animated: false)
    }
    
    func setDisplay() {
        tapGestureRecognizer.isEnabled = isAddingPins
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
        
        if longPressGestureRecognizer.state == .began {
            let location = sender.location(in: mapView)
            let coordinate: CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)
            let newPin = MKPointAnnotation()
            let pinId = UUID().uuidString
            newPin.coordinate = coordinate
            addPin(pinId: pinId, latitude: coordinate.latitude, longitude: coordinate.longitude)
            fetchPins()
        }
    }
    
    func addPin(pinId: String, latitude: Double, longitude: Double) {
        let pin = Pin(context: dataController.viewContext)
        pin.pinId = pinId
        pin.latitude = latitude
        pin.longitude = longitude
        pin.firstSearch = true
        try? dataController.viewContext.save()
        addPinSearchData(latitude: latitude, longitude: longitude)
    }
    
    
    func addPinSearchData(latitude: Double, longitude: Double) {
        let endpoint = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(FlickrClient.apiKey)&lat=\(latitude)&lon=\(longitude)&format=json&nojsoncallback=1"
        let url = URL(string: endpoint)!
        //var totalPhotos: String = ""
        
        let task = URLSession.shared.dataTask(with: url) {
            data, response, error in
            guard let data = data else { return }
            
            let decoder = JSONDecoder()
            
            if let searchData = try? decoder.decode(FlickrPhotos.self, from: data) {
                //print(searchData)
                self.flickrPhotos = searchData
                //print(self.flickrPhotos)
                //let totalPhotos = (self.flickrPhotos?.photos.total)!
                //print("total photos is \(totalPhotos)")
            }
        }
        
        let pin = Pin(context: dataController.viewContext)
        //pin.totalPhotos = totalPhotos
        try? dataController.viewContext.save()
    }
    
    fileprivate func fetchPins() {
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            mapPins = result
        }
        
        for pin in mapPins {
            let latitude = CLLocationDegrees(pin.latitude)
            let longitude = CLLocationDegrees(pin.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            self.mapView.addAnnotation(annotation)
        }
    }
    
    //MARK: - Move this into Map Delegate?
  /*  @objc private func recognizeTapPress(_ sender: UITapGestureRecognizer) {
        // Do not generate pins many times during long press.
        if sender.state != UIGestureRecognizer.State.began {
            return
        }
    }*/
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let viewController = segue.destination as? FlickrViewController else { return }
        //viewController.pinId = selectedPin!.pinId //appears not necessary
        viewController.pin = selectedPin
        viewController.dataController = dataController
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
        let longitude = mapView.centerCoordinate.longitude
        let latitude_span = mapView.region.span.latitudeDelta
        let longitude_span = mapView.region.span.longitudeDelta
        defaults.set(latitude, forKey: "initLat")
        defaults.set(longitude, forKey: "initLon")
        defaults.set(latitude_span, forKey: "initLatSpan")
        defaults.set(longitude_span, forKey: "initLonSpan")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {
            return
        }
        let coordinate = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        
        for selectedPin in mapPins {
            self.selectedPin = selectedPin
            if selectedPin.latitude == coordinate.latitude && selectedPin.longitude == coordinate.longitude {
                if isAddingPins {
                    performSegue(withIdentifier: "pinId", sender: self)
                } else {
                    dataController.viewContext.delete(selectedPin)
                    try? dataController.viewContext.save()
                    //need to add error handling above
                    fetchPins()
                }
            }
        }
        mapView.deselectAnnotation(view.annotation, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinIdentifier = "pinIdentifier"
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdentifier)
        pinView.annotation = annotation
        return pinView
    }
}
