//
//  MapViewController.swift
//  MyVirtualTourist
//
//  Created by Udumala, Mary on 5/10/17.
//  Copyright © 2017 Udumala, Mary. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: CoreDataViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var selectedAnnotation = MKPointAnnotation()
    var selectedPin: Pin!
    var mapPins = [Pin]()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTap(gestureReconizer:)))
        tapGesture.delegate = self
        mapView.addGestureRecognizer(tapGesture)
        
        // Set the title
        title = "Virtual Tourist"
        
        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        
        //Load last user location and zoom level from NSUserDefaults
        mapView.delegate = self
        let latitudeValueOnLoad = UserDefaults.standard.object(forKey: "mapCenterLatitudeValue")
        let longitudeValueOnLoad = UserDefaults.standard.object(forKey: "mapCenterLongitudeValue")
        let spanLatitudeValueOnLoad = UserDefaults.standard.object(forKey: "mapSpanLatitudeDelta")
        let spanLongitudeValueOnLoad = UserDefaults.standard.object(forKey: "mapSpanLongitudeDelta")
        
        if let latitudeValueOnLoad = latitudeValueOnLoad, let longitudeValueOnLoad = longitudeValueOnLoad, let spanLatitudeValueOnLoad = spanLatitudeValueOnLoad, let spanLongitudeValueOnLoad = spanLongitudeValueOnLoad {
            mapView.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitudeValueOnLoad as! CLLocationDegrees, longitude: longitudeValueOnLoad as! CLLocationDegrees), span: MKCoordinateSpan(latitudeDelta: spanLatitudeValueOnLoad as! CLLocationDegrees, longitudeDelta: spanLongitudeValueOnLoad as! CLLocationDegrees))
        }
        
        // Create a fetchrequest for pins
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: false),
                              NSSortDescriptor(key: "longitude", ascending: false)]
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        // load all pins from core data on viewdidload
        mapPins = fetchedResultsController?.fetchedObjects as! [Pin]
        print(mapPins)
        var annotations = [MKPointAnnotation]()
        for eachPin in mapPins {
            
            let lat = CLLocationDegrees(eachPin.latitude)
            let long = CLLocationDegrees(eachPin.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
}


extension MapViewController {
    
    func handleTap(gestureReconizer: UILongPressGestureRecognizer) {
        let location = gestureReconizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        // create new pin in managedObjectContext
        let newPin = Pin(latitude: coordinate.latitude, longitude: coordinate.longitude, context: fetchedResultsController!.managedObjectContext)
        print("Just created a new pin: \(newPin)")
        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        stack.save()
        
        // Add annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        selectedAnnotation = annotation
        selectedPin = newPin
    }
}


extension MapViewController: MKMapViewDelegate {
    
    //save last user selected region and zoom level to NSUserDefaults
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UserDefaults.standard.set(mapView.region.center.latitude, forKey: "mapCenterLatitudeValue")
        UserDefaults.standard.set(mapView.region.center.longitude, forKey: "mapCenterLongitudeValue")
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: "mapSpanLatitudeDelta")
        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey: "mapSpanLongitudeDelta")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "pin") {
            
            let PhotosVC = segue.destination as! PhotoCollectionViewController
            PhotosVC.annotation = self.selectedAnnotation
            PhotosVC.pin = self.selectedPin            
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedAnnotation = view.annotation as! MKPointAnnotation
        for eachPin in mapPins {
            if eachPin.latitude == Float(selectedAnnotation.coordinate.latitude), eachPin.longitude == Float(selectedAnnotation.coordinate.longitude) {
                selectedPin = eachPin
                print("Found the selected Pin")
            }
        }
        performSegue(withIdentifier: "pin", sender: view)
    }
}
