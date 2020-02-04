//
//  FlickrPhoto.swift
//  Virtual-Tourist
//
//  Created by Dustin Mahone on 1/19/20.
//  Copyright © 2020 Dustin. All rights reserved.
//

import Foundation

struct FlickrPhoto: Codable, Equatable {
    
    let photoId: String
    let farm: Int
    let secret: String
    let server: String
    let title: String
    //let owner: String
    //let isPublic: Int
    //let isFriend: Int
    //let isFamily: Int
    
    enum CodingKeys: String, CodingKey {
        case photoId = "id"
        case farm
        case secret
        case server
        case title
        //case owner
        //case isPublic = "ispublic"
        //case isFriend = "isfriend"
        //case ifFamily = "isfamily"
    }
    
    init (photoId: String, farm: Int, server: String, secret: String, title: String) {
        self.photoId = photoId
        self.farm = farm
        self.server = server
        self.secret = secret
        self.title = title
    }
    
    //currently unused
    var photoUrl: NSURL {
        return NSURL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoId)_\(secret)_m.jpg")!
    }
    
}
