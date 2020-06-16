//
//  DataController.swift
//  Virtual-Tourist
//
//  Created by Dustin Mahone on 1/20/20.
//  Copyright © 2020 Dustin. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    //create persistent container
    let persistentContainer: NSPersistentContainer
    
    //convenience property to access context, viewContext associated with main queue
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    //initializer to configure persistent container
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    //load persistent store
    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
        completion?()
        }
    }
}
