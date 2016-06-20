//
//  SelectLocationViewController.swift
//  Travel Log
//
//  Created by Sérgio Gonçalves on 11/06/16.
//  Copyright © 2016 Sérgio Gonçalves. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class SelectLocationViewController: UIViewController {
    
    @IBOutlet weak var uiButtonSave: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    var selectedPin:MKPlacemark? = nil
    var resultSearchController:UISearchController? = nil
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
        
        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self

    }
    
    @IBAction func save(){
        if mapView.annotations.count == 2 {
            performSegueWithIdentifier("unwindToAddDiaryEntrySave", sender: self)
        } else {
            let alertController = UIAlertController(title: "Error", message: "Please select a location using long press in map on the desired location", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Understood", style: .Default, handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func reverseGeocode(locationCoord : CLLocationCoordinate2D) -> CLPlacemark? {
        let location = CLLocation(latitude: locationCoord.latitude, longitude: locationCoord.longitude)
        var place : CLPlacemark? = nil
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            print(location)
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                place = placemarks![0] 
                print(place!.locality)
                
                self.mapView.removeAnnotations(self.mapView.annotations)
                let annotation = MKPointAnnotation()
                self.mapView.addAnnotation(annotation)
                annotation.coordinate = locationCoord
                
                //let annotation = self.mapView.annotations.first
                annotation.title = place!.name
                if let city = place!.locality,
                    let state = place!.administrativeArea {
                    annotation.subtitle = "\(city) \(state)"
                }
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
        
        return place
    }

    
    @IBAction func addMarker(sender: AnyObject) {
        let location = sender.locationInView(self.mapView)
        let locationCoord = self.mapView.convertPoint(location, toCoordinateFromView: self.mapView)

        reverseGeocode(locationCoord)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }
    
    func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMapsWithLaunchOptions(launchOptions)
        }
    }
    
}


extension SelectLocationViewController : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch CLLocationManager.authorizationStatus() {
            case .AuthorizedAlways:
                locationManager.requestLocation()
            case .NotDetermined:
                manager.requestWhenInUseAuthorization()
            case .AuthorizedWhenInUse, .Restricted, .Denied:
                let alertController = UIAlertController(
                    title: "Background Location Access Disabled",
                    message: "Please open this app's settings and set location access ",
                    preferredStyle: .Alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                    if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                        UIApplication.sharedApplication().openURL(url)
                    }
                }
                alertController.addAction(openAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: \(error)")
    }
}

extension SelectLocationViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}

extension SelectLocationViewController : MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.canShowCallout = true
        return pinView
    }
}