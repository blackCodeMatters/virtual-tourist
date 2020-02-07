//
//  FlickrClient.swift
//  Virtual-Tourist
//
//  Created by Dustin Mahone on 1/19/20.
//  Copyright © 2020 Dustin. All rights reserved.
//

import Foundation
import UIKit

class FlickrClient {
    
    struct searchValues {
        static var latitude = "0.00"
        static var longitude = "0.00"
        static var radius = "0.5" //in km
        static let photoQuantity = "21"
        static var pages = 1
    }
    
    static let apiKey = "e589ec9492a8809e36ccac1731758872"
    static var latitude = "0.00"
    static var longitude = "0.00"
    
    //static let photoQuantity = "21"
    //static let pages = "1"
    
    var dataController: DataController!
    
    enum Endpoints {
        static let base = "https://api.flickr.com/services/rest"
        static let method = "/?method=flickr.photos.search"
        static let api = "&api_key=\(FlickrClient.apiKey)"
        static let minUploadDate = "&min_upload_date=2017-01-01+00%3A00%3A00"
        static let lat = "&lat=\(FlickrClient.latitude)"
        static let lon = "&lon=\(FlickrClient.longitude)"
        static let radius = "&radius=\(FlickrClient.searchValues.radius)"
        static let perPage = "&per_page=\(FlickrClient.searchValues.photoQuantity)"
        static let page = "&page=\(FlickrClient.searchValues.pages)"
        static let format = "&format=json&nojsoncallback=1"
        
        case geoSearch
        
        var stringValue: String {
            switch self {
            case .geoSearch: return Endpoints.base + Endpoints.method + Endpoints.api + Endpoints.minUploadDate + Endpoints.lat + Endpoints.lon + Endpoints.radius + Endpoints.perPage + Endpoints.page + Endpoints.format
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
        
    }
    
    //load photos to core data outside of viewcontroller
    /*
    class func flickrDownload(completion: @escaping (FlickrResults, Error?) -> Void) {
        let request = URLRequest(url: Endpoints.geoSearch.url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
          if error != nil { // Handle error...
              return
          }
            let decoder = JSONDecoder()
            let responseObject = try! decoder.decode(FlickrPhotos.self, from: data!)
            completion(responseObject.photos, nil)
        }
        task.resume()
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
        
    }*/
    
}
