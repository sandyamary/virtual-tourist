//
//  Photo+CoreDataProperties.swift
//  MyVirtualTourist
//
//  Created by Udumala, Mary on 5/11/17.
//  Copyright © 2017 Udumala, Mary. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var image: NSData?
    @NSManaged public var pin: Pin?

}
