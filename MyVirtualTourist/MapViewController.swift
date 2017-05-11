//
//  MapViewController.swift
//  MyVirtualTourist
//
//  Created by Udumala, Mary on 5/10/17.
//  Copyright © 2017 Udumala, Mary. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load last user location and zoom level for the map
        mapView.delegate = self
        let latitudeValueOnLoad = UserDefaults.standard.object(forKey: "mapCenterLatitudeValue")
        let longitudeValueOnLoad = UserDefaults.standard.object(forKey: "mapCenterLongitudeValue")
        let spanLatitudeValueOnLoad = UserDefaults.standard.object(forKey: "mapSpanLatitudeDelta")
        let spanLongitudeValueOnLoad = UserDefaults.standard.object(forKey: "mapSpanLongitudeDelta")
        
        if let latitudeValueOnLoad = latitudeValueOnLoad, let longitudeValueOnLoad = longitudeValueOnLoad, let spanLatitudeValueOnLoad = spanLatitudeValueOnLoad, let spanLongitudeValueOnLoad = spanLongitudeValueOnLoad {
            mapView.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitudeValueOnLoad as! CLLocationDegrees, longitude: longitudeValueOnLoad as! CLLocationDegrees), span: MKCoordinateSpan(latitudeDelta: spanLatitudeValueOnLoad as! CLLocationDegrees, longitudeDelta: spanLongitudeValueOnLoad as! CLLocationDegrees))
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UserDefaults.standard.set(mapView.region.center.latitude, forKey: "mapCenterLatitudeValue")
        UserDefaults.standard.set(mapView.region.center.longitude, forKey: "mapCenterLongitudeValue")
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: "mapSpanLatitudeDelta")
        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey: "mapSpanLongitudeDelta")        
    }
}
