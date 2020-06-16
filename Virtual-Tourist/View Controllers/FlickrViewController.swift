//
//  ViewController.swift
//  Virtual-Tourist
//
//  Created by Dustin Mahone on 1/16/20.
//  Copyright © 2020 Dustin. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class FlickrViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    //MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var editCollectionButton: UIButton!
    
    var pinId: String?
    var pin: Pin!
    
    var fetchedResultsController:NSFetchedResultsController<Photo>!
   
    var photos: [Photo] = []
    let spacing: CGFloat = 8
    var flickrPhotos: FlickrPhotos?
    var dataController: DataController!
    var photoArray: [UIImage] = []
    var selectedPhotosArray: [Int] = []
    
    var page: Int = 1
    var perPage: Int = 21
    var imagesInCollectionView: Int = 0
    var randomNumberPage: Int?
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
                
        mapView.delegate = self
        collectionView.delegate = self
        
        setupMap()
        setButton()
        setupFetchedResultsController()
        fetchMorePhotos()
        setupCollectionLayout()
        
    }
        
    //MARK: - Methods
    func checkForPhotos() {
        
    }
    func fetchMorePhotos() {
        setButton()
        if pin.photos!.count == 0 {
            flickrGeoSearchRedux(lat: pin.latitude, lon: pin.longitude, randomNumberPage: getRandomNumberPage())
        } else {
            let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
            let predicate = NSPredicate(format: "pin == %@", pin)
            fetchRequest.predicate = predicate
            
            if let result = try? dataController.viewContext.fetch(fetchRequest) {
                photos = result
            }
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
    
    func flickrGeoSearchRedux(lat: Double, lon: Double, randomNumberPage: Int) {
        editCollectionButton.isEnabled = false
        
        let endpoint = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(FlickrClient.apiKey)&min_upload_date=2017-01-01+00%3A00%3A00&lat=\(lat)&lon=\(lon)&radius=0.5&per_page=\(perPage)&page=\(randomNumberPage)&format=json&nojsoncallback=1"
        let url = URL(string: endpoint)!
        
        let task = URLSession.shared.dataTask(with: url) {
            data, response, error in
            
            guard let data = data else { return }
            let decoder = JSONDecoder()
            
            if let searchData = try? decoder.decode(FlickrPhotos.self, from: data) {
                self.flickrPhotos = searchData
                self.pin.totalPhotos = (self.flickrPhotos?.photos.total)!
                let imagesFound = Int((self.flickrPhotos?.photos.total)!)
                let pagesOfImages = (self.flickrPhotos?.photos.pages)
                DispatchQueue.main.async {
                    if imagesFound == 0 {
                        self.noImagesLabel.isHidden = false
                        self.collectionView.reloadData()
                    } else {
                        self.noImagesLabel.isHidden = true
                    }
                }
            }
            
            for img in (self.flickrPhotos?.photos.photo)! {
                let url = img.photoUrl
                let id = img.photoId
                
                if let imageData = try? Data(contentsOf: url as URL) {
                    self.addPhoto(data: imageData, id: id)
                    let photoImage = UIImage(data: imageData)
                }
            }
            
            if self.fetchedResultsController.managedObjectContext.hasChanges {
                print("new photos not found")
            } else {
                print("new photos found")
                self.fetchMorePhotos()
            }
            
        }
        task.resume()
        
        pin.firstSearch = false
        editCollectionButton.isEnabled = true
    }
        
    func setupCollectionLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        collectionView.allowsMultipleSelection = true
        collectionView?.collectionViewLayout = layout
    }

    func addPhoto(data: Data, id: String) {
        let photo = Photo(context: dataController.viewContext)
        photo.image = data
        photo.photoId = Double(id)!
        photo.pin = pin
        try? dataController.viewContext.save()
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
        
    func deletePhoto() {
        //get indexPath
        //get managed object from data model
        //delete object and remove from array
        //collectionView deleteItemsAtIndexPaths OR collectionView.reloadData
        
        if let selectedCells = collectionView.indexPathsForSelectedItems {
            let items = selectedPhotosArray.sorted { $0 > $1 }
            for item in items {
                let indexPath = photos[item]
                fetchedResultsController.managedObjectContext.delete(indexPath)
            }
            do {
                try fetchedResultsController.managedObjectContext.save()
                   DispatchQueue.main.async {
                       self.collectionView.reloadData()
                   }
                } catch {
                    showAlert(title: "Data did not save", message: "Please try again")
                }
                
        }
        
        selectedPhotosArray = []
        fetchMorePhotos()
    }
    
    func setupMap() {
        guard pin.pinId != nil else { return }
        let mapLatitude = CLLocationDegrees(pin.latitude)
        let mapLongitude = CLLocationDegrees(pin.longitude)
        let coordinate = CLLocationCoordinate2D(latitude: mapLatitude, longitude: mapLongitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
        
        let center = CLLocationCoordinate2DMake(mapLatitude, mapLongitude)
        mapView.setCenter(center, animated: false)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.16)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.region = region
        mapView.isUserInteractionEnabled = false
    }
    
    func setButton() {
        if selectedPhotosArray.count >= 1 {
            editCollectionButton.titleLabel?.adjustsFontSizeToFitWidth = true
            editCollectionButton.titleLabel?.adjustsFontSizeToFitWidth = false
            DispatchQueue.main.async {
                self.editCollectionButton.setTitle("Remove Selected Photos", for: .normal)
            }
        } else {
            DispatchQueue.main.async {
                self.editCollectionButton.setTitle("New Collection", for: .normal)
            }
        }
    }
    
    func getRandomNumberPage() -> Int {
        let totalPhotosString = pin.totalPhotos! //get the total number of photos
        let totalPhotosInt = Int(totalPhotosString)! //convert total into an Int, currently defaults to 21 in the Pin Entity in core data
        let imagesNeededToFillArray = perPage //determine how many images we want from the search
        let totalPages = totalPhotosInt / imagesNeededToFillArray //determing the total number of pages available
        
        if pin.firstSearch {
            return 1
        } else {
            return Int.random(in: 1 ... totalPages) //generate a random page number to grab pics from
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
            self.editCollectionButton.isEnabled = true
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
        
    @IBAction func editCollectionButtonPressed(_ sender: Any) {
        if selectedPhotosArray.isEmpty {
            selectedPhotosArray = []
            guard photos.count >= 1 else { return }
            let index = photos.count - 1
            for i in 0...index {
                selectedPhotosArray.append(i)
            }
            deletePhoto()
            } else {
            deletePhoto()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseIdentifier", for: indexPath) as! FlickrCell
        
        if photos.count != nil {
                cell.imageView.image = UIImage(named: "cellLoading")
                cell.activityIndicatorView.isHidden = false
                cell.activityIndicatorView.startAnimating()
                if let photoImage = photos[indexPath.row].image {
                    cell.imageView.image = UIImage(data: photoImage)
                    cell.imageView.contentMode = .scaleAspectFill
                    cell.activityIndicatorView.stopAnimating()
                    cell.imageView.alpha = 1.0
            }
        }
            
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedPhotosArray.append(indexPath.row)
        DispatchQueue.main.async {
            self.setButton()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let itemToRemove = indexPath.row
        if let index = selectedPhotosArray.firstIndex(of: itemToRemove) {
            selectedPhotosArray.remove(at: index)
        }
        setButton()
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      
        let numberOfItemsPerRow:CGFloat = 3
        let spacingBetweenCells:CGFloat = 8
        let totalSpacing = (2 * spacing) + ((numberOfItemsPerRow - 1) * spacingBetweenCells)
        
        guard let collection = self.collectionView else { return CGSize(width: 0, height: 0)}
        let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
        
        return CGSize(width: width, height: width)

    }
    
    
}

//MARK: - Extensions
extension FlickrViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinIdentifier = "pinIdentifier"
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdentifier)
        pinView.annotation = annotation
        return pinView
    }
}

extension FlickrViewController: NSFetchedResultsControllerDelegate {
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        
        let sortDescriptor = NSSortDescriptor(key: "photoId", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin)-photos")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
}




