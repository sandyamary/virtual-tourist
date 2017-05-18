//
//  FlickrConvenience.swift
//  MyVirtualTourist
//
//  Created by Udumala, Mary on 5/15/17.
//  Copyright © 2017 Udumala, Mary. All rights reserved.
//

import UIKit
import Foundation

// MARK: - FlickrClient (Convenient Resource Methods)

extension FlickrClient {
    
    
    func getPhotoCollection(lat: Float?, lon: Float?, completionHandlerForPhotos: @escaping (_ numOfPages: Int?, _ error: NSError?) -> Void) {
        
        let _ = taskForGETMethod(lat: lat, lon: lon, parameters: [String:String?]()) { (results, error) in
            
            if let error = error {
                print("getPhotoCollection Error: \(error)")
                completionHandlerForPhotos(nil, error)
            } else {
                
                if let photosDictionary = results?[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject] {
                    let numOfPages = photosDictionary["pages"] as? Int
                    completionHandlerForPhotos(numOfPages, nil)
                } else {
                    completionHandlerForPhotos(nil, NSError(domain: "getPhotoCollection parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getPhotoCollection"]))
                }
            }
        }
    }
    
    
    func getPhotoCollectionWithPageNumber(photosPerPage: Int, lat: Float?, lon: Float?, completionHandlerForPhotos: @escaping (_ result: [[String: AnyObject]]?, _ error: NSError?) -> Void) {
        
        getPhotoCollection(lat: lat, lon: lon) { (numOfPages, error) in
            if error != nil {
                print("Error in First call")
            } else {
                
                //get a random oage from results
                if numOfPages == 0 {
                    print("randomPage: ZERO PAGES")
                    return
                } else {
                    let maxPages = min(numOfPages!, 40)
                    let randomPage = Int(arc4random_uniform(UInt32(maxPages)))
                    print("randomPage: \(randomPage)")
                    
                    //Specify parameters
                    var parameters = [String:String?]()
                    parameters[FlickrClient.Constants.FlickrParameterKeys.Page] = "\(randomPage)"
                    parameters[FlickrClient.Constants.FlickrParameterKeys.PhotosPerPage] = "\(photosPerPage)"
                    
                    let _ = self.taskForGETMethod(lat: lat, lon: lon, parameters: parameters) { (results, error) in
                        
                        if let error = error {
                            print("getPhotoCollection Error: \(error)")
                            completionHandlerForPhotos(nil, error)
                        } else {
                            
                            if let photosDictionary = results?[Constants.FlickrResponseKeys.Photos] as? [String: AnyObject] {
                                let arrayOfPhotoDictionaries = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]]
                                completionHandlerForPhotos(arrayOfPhotoDictionaries, nil)
                            } else {
                                completionHandlerForPhotos(nil, NSError(domain: "getPhotoCollectionWithPageNumber parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getPhotoCollectionWithPageNumber"]))
                            }
                        }
                    }
                }
                
            }
            
            
        }
        
    }
    
    
}
