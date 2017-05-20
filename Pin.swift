//
//  Pin.swift
//  MyVirtualTourist
//
//  Created by Udumala, Mary on 5/11/17.
//  Copyright © 2017 Udumala, Mary. All rights reserved.
//

import Foundation
import CoreData


public class Pin: NSManagedObject {
    
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = Float(latitude)
            self.longitude = Float(longitude)
        } else {
            fatalError("Unable to find entity name")
        }
    }
}
