//
//  FlickrResults.swift
//  Virtual-Tourist
//
//  Created by Dustin Mahone on 1/19/20.
//  Copyright © 2020 Dustin. All rights reserved.
//

import Foundation

struct FlickrResults: Decodable, Equatable {
    
    let page: Int
    let pages: Int
    let perPage: Int
    let total: String
    let photo: [FlickrPhoto]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case total
        case photo
    }
}
