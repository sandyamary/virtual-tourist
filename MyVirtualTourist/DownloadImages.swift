//
//  DownloadImages.swift
//  MyVirtualTourist
//
//  Created by Udumala, Mary on 5/20/17.
//  Copyright © 2017 Udumala, Mary. All rights reserved.
//


import Foundation
import UIKit

class DownloadImages: NSObject {
    
    let numberOfPhotosPerCollection = 21
    var latitude: Double!
    var longitude: Double!
    var images = [UIImage]()
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func downloadImages() -> [UIImage] {
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
                        } else {
                            print("Image does not exist at imageURL")
                        }
                        
                    }
                    
                }
                
            }
        }
        return images
    }
}


