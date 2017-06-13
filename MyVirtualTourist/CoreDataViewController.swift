//
//  CoreDataViewController.swift
//  MyVirtualTourist
//
//  Created by Udumala, Mary on 5/24/17.
//  Copyright © 2017 Udumala, Mary. All rights reserved.
//

import UIKit
import CoreData

class CoreDataViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties
    
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, we execute the search and
            fetchedResultsController?.delegate = self
            executeSearch()
        }
    }
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(String(describing: fetchedResultsController))")
            }
        }
    }
    
    
}
