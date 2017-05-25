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
    
    @IBOutlet weak var smallMapView: MKMapView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // MARK: - LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("PIN: \(pin)")
        print("ANNOTATION: \(annotation)")
        
        self.smallMapView.delegate = self
        
        
        let width = UIScreen.main.bounds.width
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.itemSize = CGSize(width: width / 5, height: width / 5)
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        collectionView!.collectionViewLayout = flowLayout
        
        self.latitude = self.annotation.coordinate.latitude
        self.longitude = self.annotation.coordinate.longitude
        
        let center = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 100.0, longitudeDelta: 100.0))
        
        performUIUpdatesOnMain {
            print(self.annotation)
            self.smallMapView.setRegion(region, animated: true)
            self.smallMapView.addAnnotation(self.annotation)
            
        }
        
        DownloadImages.sharedInstance().downloadImages(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude) { (imagesData) in
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            print("network calls successful")
        }
        
        
        
        /*
         DownloadImages.sharedInstance().downloadImages(latitude: selectedAnnotation.coordinate.latitude, longitude: selectedAnnotation.coordinate.longitude) { (imagesData) in
         
         print("imagesData: \(imagesData!.count)")
         let PhotosVC = segue.destination as! PhotoCollectionViewController
         if imagesData == nil {
         print("FC is nil")
         PhotosVC.fetchedResultsController = nil
         } else {
         for eachPhotoData in imagesData! {
         //print("PHOTO NUMBER: \(count)")
         let newPhotoImage = UIImage(data: eachPhotoData)
         
         if let pin = self.selectedPin {
         let newPhoto = Photo(image: newPhotoImage!, context: self.fetchedResultsController!.managedObjectContext)
         newPhoto.pin = pin
         print("Just created a new photo: \(newPhoto)")
         }
         }
         
         //PhotosVC.annotation = self.selectedAnnotation
         // Create a fetchrequest for photos
         let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
         fr.sortDescriptors = [NSSortDescriptor(key: "image", ascending: true)]
         
         // load all photos from core data for the selected pin
         let pred = NSPredicate(format: "pin = %@", argumentArray: [self.selectedPin!])
         fr.predicate = pred
         
         // Create FetchedResultsController
         let fc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext:self.fetchedResultsController!.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
         
         print(self.mapPins)
         
         // Inject it into the PhotosVC
         PhotosVC.fetchedResultsController = fc
         }
         
         }
 
 
 */
    }
    
    @IBAction func getNewCollection(_ sender: Any) {
        
    }
    
}


extension PhotoCollectionViewController {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 21
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("at cell for item")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! collectionViewCell
        
        performUIUpdatesOnMain {
            let photo = self.fetchedResultsController?.object(at: indexPath) as! Photo
            cell.imageCell.image = UIImage(data: photo.image! as Data)
        }
        return cell
    }
}



