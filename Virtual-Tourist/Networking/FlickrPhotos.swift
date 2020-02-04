//
//  FlickrPhotos.swift
//  Virtual-Tourist
//
//  Created by Dustin Mahone on 1/19/20.
//  Copyright © 2020 Dustin. All rights reserved.
//

import Foundation

struct FlickrPhotos: Decodable {
    let photos: FlickrResults
    let stat: String
}
