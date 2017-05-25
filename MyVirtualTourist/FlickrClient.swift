//
//  FlickrClient.swift
//  MyVirtualTourist
//
//  Created by Udumala, Mary on 5/15/17.
//  Copyright © 2017 Udumala, Mary. All rights reserved.
//

import Foundation

// MARK: - ParseClient: NSObject

class FlickrClient : NSObject {
    
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
    
    var objectID: String? = nil
    
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    // MARK: GET
    
    func taskForGETMethod(lat: Double?, lon: Double?, parameters: [String: String?], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        var searchParameters = parameters
        
        if let latitude = lat, let longitude = lon {
            searchParameters[FlickrClient.Constants.FlickrParameterKeys.latitude] = "\(latitude)"
            searchParameters[FlickrClient.Constants.FlickrParameterKeys.longitude] = "\(longitude)"
        }
        
        searchParameters[FlickrClient.Constants.FlickrParameterKeys.APIKey] = FlickrClient.Constants.FlickrParameterValues.APIKey
        searchParameters[FlickrClient.Constants.FlickrParameterKeys.SafeSearch] = FlickrClient.Constants.FlickrParameterValues.UseSafeSearch
        searchParameters[FlickrClient.Constants.FlickrParameterKeys.Extras] = FlickrClient.Constants.FlickrParameterValues.MediumURL
        searchParameters[Constants.FlickrParameterKeys.Method] = FlickrClient.Constants.FlickrParameterValues.SearchMethod
        searchParameters[FlickrClient.Constants.FlickrParameterKeys.Format] = FlickrClient.Constants.FlickrParameterValues.ResponseFormat
        searchParameters[FlickrClient.Constants.FlickrParameterKeys.NoJSONCallback] = FlickrClient.Constants.FlickrParameterValues.DisableJSONCallback     
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: flickrURLFromParameters(searchParameters))
        
        print("REQUESTTTT: \(request)")
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        /* 7. Start the request */
        task.resume()
        return task
}
    
    // given raw JSON, return a usable Foundation object
    func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // create a URL from parameters
    private func flickrURLFromParameters(_ parameters: [String: String?]) -> URL {
        
        var components = URLComponents()
        components.scheme = FlickrClient.Constants.Flickr.APIScheme
        components.host = FlickrClient.Constants.Flickr.APIHost
        components.path = FlickrClient.Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            if let value = value {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            //print("queryItem: \(queryItem)")
            components.queryItems!.append(queryItem)
            }
        }
        
        return components.url!
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }

}
