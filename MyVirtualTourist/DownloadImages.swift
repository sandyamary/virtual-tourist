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
    var imagesData = [Data]()
    var imageURLS = [URL]()
    
    func downloadImages(latitude: Double, longitude: Double, completionHandlerForDownload: @escaping (_ result: [URL]?) -> Void) {
    
                
                FlickrClient.sharedInstance().getPhotoCollectionWithPageNumber(photosPerPage: self.numberOfPhotosPerCollection, lat: latitude, lon: longitude) { (arrayOfPhotoDictionaries, error) in
                    
                    self.imagesData.removeAll()
                    for eachPhotoDictionary in arrayOfPhotoDictionaries! {
                        print("DICTIONARY: \(eachPhotoDictionary)")
                        //GUARD: Does our photo have a key url_m
                        guard let imageUrlString = eachPhotoDictionary[FlickrClient.Constants.FlickrResponseKeys.MediumURL] as? String else {
                            print("could not find key 'url_m'")
                            return
                        }
                        
                        //if an image exists at the url, set label and image
                        let imageURL = URL(string: imageUrlString)
                        
                        if let url = imageURL {
                            self.imageURLS.append(url)
                        }
                        
                        
//                        if let imageData = try? Data(contentsOf: imageURL!) {
//                            self.imagesData.append(imageData)
//                        } else {
//                            print("Image does not exist at imageURL")
//                        }
                        
                    }
                    
//                    if self.imagesData.count == 0 {
//                        completionHandlerForDownload(nil)
//                    } else {
//                        completionHandlerForDownload(self.imagesData)
//                    }
                    
                    if self.imageURLS.count == 0 {
                        completionHandlerForDownload(nil)
                    } else {
                        completionHandlerForDownload(self.imageURLS)
                    }
                    
                }
        
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> DownloadImages {
        struct Singleton {
            static var sharedInstance = DownloadImages()
        }
        return Singleton.sharedInstance
    }
    
}


