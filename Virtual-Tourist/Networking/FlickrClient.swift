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
    
    static let apiKey = "d43b31fa3e38275545ccd38a2250edb5" //temp key from : https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=d43b31fa3e38275545ccd38a2250edb5&lat=24.555263&lon=-81.8041&radius=5&per_page=&page=&format=rest&api_sig=2c7bf738cb2f53fcab7e11eb2db581a7
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
