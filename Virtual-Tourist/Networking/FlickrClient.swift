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

    static let apiKey = "6e0190cf5f6c546030d7c4216dca30f9"
    static var latitude = "0.00"
    static var longitude = "0.00"
    
    //static let photoQuantity = "21"
    //static let pages = "1"
    
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
        
    class func flickrDownload(page: Int) {
        
    }
    
}

