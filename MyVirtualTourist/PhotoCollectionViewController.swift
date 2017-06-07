//
//  PhotoCollectionViewController.swift
//  MyVirtualTourist
//
//  Created by Udumala, Mary on 5/12/17.
//  Copyright © 2017 Udumala, Mary. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoCollectionViewController: CoreDataViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource  {
    
    let numberOfPhotosPerCollection = 21
    var annotation = MKPointAnnotation()
    var pin: Pin!
    var latitude: Double!
    var longitude: Double!
    var pinPhotos = [UIImage]()
    
    @IBOutlet weak var smallMapView: MKMapView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMap()
        initializeCollectionView()
        fetchPhotoResultsController()
        let photos = self.fetchedResultsController?.fetchedObjects as! [Photo]
        if photos.count == 0 {
            displayNewDownloadedImages()
        } else {
            print("Loading photos from Core")
        }
    }
    
    
    @IBAction func getNewCollection(_ sender: Any) {
        //delete pin.photos from core data
        fetchPhotoResultsController()
        if let context = self.fetchedResultsController?.managedObjectContext, let photos = fetchedResultsController?.fetchedObjects as? [Photo] {
            for photo in photos {
               context.delete(photo)
                print("Photo Deleted")
            }
        }
        // Save updated pin in Core Data
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.stack.save()
        displayNewDownloadedImages()
    }
}



//Helper functions

extension PhotoCollectionViewController {
    
    func fetchPhotoResultsController() {
        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        // Create a fetchrequest for photos
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fr.sortDescriptors = [NSSortDescriptor(key: "image", ascending: true)]
        
        // load all photos from core data for the selected pin
        let pred = NSPredicate(format: "pin = %@", argumentArray: [self.pin!])
        fr.predicate = pred
        
        // Create FetchedResultsController
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    
    func createNewPhotosInFRC(imagesArray: [UIImage]) {
        for eachImage in imagesArray {
            if let pin = self.pin, let frc = self.fetchedResultsController {
                let newPhoto = Photo(image: eachImage, context: frc.managedObjectContext)
                newPhoto.pin = pin
                print("Just created a new photo: \(newPhoto)")
            }
        }
        // Save updated pin in Core Data
        print("PIN after new download: \(self.pin)")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.stack.save()
    }
    
    func initializeMap() {
        self.smallMapView.delegate = self
        print("PIN: \(self.pin)")
        print("ANNOTATION: \(annotation)")
        
        self.latitude = self.annotation.coordinate.latitude
        self.longitude = self.annotation.coordinate.longitude
        let center = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 100.0, longitudeDelta: 100.0))
        
        performUIUpdatesOnMain {
            self.smallMapView.setRegion(region, animated: true)
            self.smallMapView.addAnnotation(self.annotation)
            self.smallMapView.isUserInteractionEnabled = false
        }
    }
    
    func initializeCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    
    func displayNewDownloadedImages() {
        DownloadImages.sharedInstance().downloadImages(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude) { (imagesData) in
            self.pinPhotos.removeAll()
            if imagesData == nil {
                print("FC is nil")
            } else {
                for eachPhotoData in imagesData! {
                    let newPhotoImage = UIImage(data: eachPhotoData)
                    self.pinPhotos.append(newPhotoImage!)
                }
                performUIUpdatesOnMain {
                    self.createNewPhotosInFRC(imagesArray: self.pinPhotos)
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
}


// MARK - CollectionView Delegate methods

extension PhotoCollectionViewController {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Collection View Triggered")
        return (self.pin.photos?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("at cell for item")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! collectionViewCell
        cell.activityIndicator.startAnimating()
        let orderedPhotos = (self.pin.photos?.allObjects as! [Photo])
        
        let photo = orderedPhotos[(indexPath as NSIndexPath).row]
        if let photoImage = photo.image {
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.hidesWhenStopped = true
            cell.imageCell.image = UIImage(data: photoImage as Data)
            cell.imageCell.alpha = 1.0
        } else {
            cell.imageCell.alpha = 0.5
            cell.activityIndicator.startAnimating()
            //loadPhotoDataForCell(indexPath)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
        //get photo at indexpath
        let orderedPhotos = (self.pin.photos?.allObjects as! [Photo])
        let selectedPhoto = orderedPhotos[(indexPath as NSIndexPath).row]
        
        //delete from pin/context
        fetchPhotoResultsController()
        if let context = self.fetchedResultsController?.managedObjectContext {
            context.delete(selectedPhoto)
        }
        
        // Save updated pin in Core Data
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.stack.save()
        
        self.collectionView.reloadData()
    }

}



