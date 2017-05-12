//
//  Photo.swift
//  MyVirtualTourist
//
//  Created by Udumala, Mary on 5/11/17.
//  Copyright © 2017 Udumala, Mary. All rights reserved.
//

import Foundation
import CoreData
import UIKit


public class Photo: NSManagedObject {
    
    convenience init(image: NSData, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.image = image
        } else {
            fatalError("Unable to find entity name")
        }
    }
}
