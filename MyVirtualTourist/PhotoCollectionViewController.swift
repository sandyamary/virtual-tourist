//
//  PhotoCollectionViewController.swift
//  MyVirtualTourist
//
//  Created by Udumala, Mary on 5/12/17.
//  Copyright © 2017 Udumala, Mary. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PhotoCollectionViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let numberOfPhotosPerCollection = 15
    var images = [UIImage]()
    var annotation = MKPointAnnotation()
    var latitude: Double!
    var longitude: Double!
    
    @IBOutlet weak var smallMapView: MKMapView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // MARK: - LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FlickrClient.sharedInstance().getPhotoCollection(lat: self.latitude, lon: self.longitude) { (numOfPages, error) in
            
            if error != nil {
                print("There was an error in service call: \(String(describing: error))")
            } else {
                print(numOfPages!)
                
                FlickrClient.sharedInstance().getPhotoCollectionWithPageNumber(photosPerPage: self.numberOfPhotosPerCollection, lat: self.latitude, lon: self.longitude) { (arrayOfPhotoDictionaries, error) in
                    
                    for eachPhotoDictionary in arrayOfPhotoDictionaries! {
                        print("DICTIONARY: \(eachPhotoDictionary)")
                        //GUARD: Does our photo have a key url_m
                        guard let imageUrlString = eachPhotoDictionary[FlickrClient.Constants.FlickrResponseKeys.MediumURL] as? String else {
                            print("could not find key 'url_m'")
                            return
                        }
                        
                        //if an image exists at the url, set label and image
                        let imageURL = URL(string: imageUrlString)
                        if let imageData = try? Data(contentsOf: imageURL!) {
                            self.images.append(UIImage(data: imageData)!)
                            print("Total Images: \(self.images.count)")
                        } else {
                            print("Image does not exist at imageURL")
                        }
                        
                    }
                    
                }
                
            }
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.smallMapView.delegate = self
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
         
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
    }
    
    @IBAction func getNewCollection(_ sender: Any) {
    }
    
    
}


extension PhotoCollectionViewController {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(self.images.count)
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("at cell for item")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! collectionViewCell
        let photo = images[(indexPath as NSIndexPath).row]
        cell.imageCell.image = photo
        return cell
    }
    
}
