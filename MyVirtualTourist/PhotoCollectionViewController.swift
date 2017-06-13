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
    
    var annotation = MKPointAnnotation()
    var pin: Pin!
    var latitude: Double!
    var longitude: Double!
    var pinPhotoURLS = [URL?]()
    var isNewDownload = true
    
    @IBOutlet weak var smallMapView: MKMapView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet weak var noImagesLabel: UILabel!
    
    @IBOutlet weak var newCollectionButton: UIButton!
    
    @IBOutlet weak var removePhotosButton: UIButton!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        noImagesLabel.text = "Found 0 images for Location"
        noImagesLabel.isHidden = true
        removePhotosButton.isHidden = true
        initializeMap()
        initializeCollectionView()
        fetchPhotoResultsController()
        let photos = self.fetchedResultsController?.fetchedObjects as! [Photo]
        if photos.count == 0 {
            newCollectionButton.isEnabled = false
            noImagesLabel.isHidden = true
            downloadedImages()
        } else {
            isNewDownload = false
            let pinPhotosArray = (self.pin.photos?.allObjects as! [Photo])
            for eachPinPhoto in pinPhotosArray {
                self.pinPhotoURLS.append(URL(string: eachPinPhoto.imageURL!))
            }
        }
    }
    
    @IBAction func removePhotos(_ sender: Any) {
        let orderedPhotos = (self.pin.photos?.allObjects as! [Photo])
        let selectedPhotos = self.collectionView.indexPathsForSelectedItems
        
        for index in selectedPhotos! {
            //delete from pin/context
            fetchPhotoResultsController()
            if let context = self.fetchedResultsController?.managedObjectContext {
                let selectedPhoto = orderedPhotos[(index as NSIndexPath).row]
                context.delete(selectedPhoto)
            }
            
            // Save updated pin in Core Data
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.stack.save()
            
            isNewDownload = false
            removePhotosButton.isHidden = true
            newCollectionButton.isHidden = false
            self.collectionView.reloadData()
        }
    }
    
    
    @IBAction func getNewCollection(_ sender: Any) {
        //delete pin.photos from core data
        self.noImagesLabel.isHidden = true
        self.newCollectionButton.isEnabled = false
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
        print("Updated PIN: \(self.pin)")
        downloadedImages()
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
    
    
    func createNewPhotoInFRC(imageURL: URL, completionHandlerForDownload: @escaping (_ result: UIImage?) -> Void) {        
        var image = UIImage(named:"PlaceholderImage")
        
        if let pin = self.pin, let frc = self.fetchedResultsController {
            //convert URL to image
            if let imageData = try? Data(contentsOf: imageURL) {
                image = UIImage(data: imageData)
                let newPhoto = Photo(image: image!, imageURL: imageURL.absoluteString, context: frc.managedObjectContext)
                newPhoto.pin = pin
                completionHandlerForDownload(image)
            } else {
                completionHandlerForDownload(nil)
            }
        }
        
        // Save updated pin in Core Data
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.stack.save()
        
    }
    
    func initializeMap() {
        self.smallMapView.delegate = self
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
    
    
    func downloadedImages() {
        DownloadImages.sharedInstance().downloadImages(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude) { (imageUrls, errorMessage) in
            
            if errorMessage != nil {
                performUIUpdatesOnMain {
                    self.noImagesLabel.isHidden = false
                    self.newCollectionButton.isEnabled = true
                }
            } else {
                self.pinPhotoURLS.removeAll()
                self.noImagesLabel.isHidden = true
                if let imageUrls = imageUrls {
                    for eachPhotoUrl in imageUrls {
                        self.pinPhotoURLS.append(eachPhotoUrl)
                    }
                }
                performUIUpdatesOnMain {
                    self.isNewDownload = true
                    self.collectionView.reloadData()
                }
            }
        }
    }
}


// MARK - CollectionView Delegate methods

extension PhotoCollectionViewController {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isNewDownload {
            return (self.pinPhotoURLS.count)
        } else {
            return (self.pin.photos?.count)!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! collectionViewCell
        cell.imageCell.image = UIImage(named: "PlaceholderImage")
        cell.activityIndicator.startAnimating()
        
        if !isNewDownload {
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.hidesWhenStopped = true
            let pinPhotosArray = (self.pin.photos?.allObjects as! [Photo])
            let photo = pinPhotosArray[(indexPath as NSIndexPath).row]
            cell.imageCell.image = UIImage(data: photo.image! as Data)
            self.newCollectionButton.isEnabled = true
            
        } else {
            performUIUpdatesOnMain {
                let photoURL = self.pinPhotoURLS[(indexPath as NSIndexPath).row]
                if let url = photoURL {
                    self.createNewPhotoInFRC(imageURL: url) { (image) in
                        if let photoImage = image {
                                cell.activityIndicator.stopAnimating()
                                cell.activityIndicator.hidesWhenStopped = true
                                cell.imageCell.image = photoImage
                                self.newCollectionButton.isEnabled = true
                        } else {
                            cell.activityIndicator.startAnimating()
                            self.collectionView.reloadItems(at: [indexPath])
                        }
                    }
                    
                }
           }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.allowsMultipleSelection = true
        if !isEditing {
            isEditing = true
            newCollectionButton.isHidden = true
            removePhotosButton.isHidden = false
        }
        let cell = collectionView.cellForItem(at: indexPath) as! collectionViewCell
        
        cell.isHighlighted = true
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! collectionViewCell
        cell.isHighlighted = false
        let selectedPhotos = collectionView.indexPathsForSelectedItems
        if (selectedPhotos?.count)! < 1 {
            newCollectionButton.isHidden = false
            removePhotosButton.isHidden = true
            isEditing = false
        }
    }
    
}



