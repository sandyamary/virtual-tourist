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
    
    
    func downloadImages(latitude: Double, longitude: Double, completionHandlerForDownload: @escaping (_ result: [URL]?, _ errorString: String?) -> Void) {
        
        FlickrClient.sharedInstance().getPhotoCollectionWithPageNumber(photosPerPage: self.numberOfPhotosPerCollection, lat: latitude, lon: longitude) { (arrayOfPhotoDictionaries, error) in
            
            if error != nil {
                completionHandlerForDownload(nil, "Flickr GET call failed")
            } else {
                
                if arrayOfPhotoDictionaries?.count == 0 {
                    completionHandlerForDownload(nil, "Images retured by flickr is 0")
                } else {
                    var imageURLS = [URL]()
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
                            imageURLS.append(url)
                        }                        
                    }
                    
                    if imageURLS.count == 0 {
                        completionHandlerForDownload(nil, "Images retured by flickr is 0")
                    } else {
                        completionHandlerForDownload(imageURLS, nil)
                    }
                    
                }
                
                
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


