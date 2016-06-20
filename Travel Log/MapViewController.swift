//
//  MapViewController.swift
//  Travel Log
//
//  Created by Sérgio Gonçalves on 10/06/16.
//  Copyright © 2016 Sérgio Gonçalves. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {
    var diaryEntriesViewController :DiaryEntriesViewController?
    
    @IBOutlet weak var mvMapa: MKMapView!
    var locationManager = CLLocationManager()
    var annotations = [DiaryEntry]()
    var currentDiary : DiaryEntry?
    var selectedAnnotation:MKAnnotation? = nil
    @IBOutlet weak var segment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        diaryEntriesViewController = self.tabBarController?.viewControllers![0] as? DiaryEntriesViewController
        
        segment.tintColor = UIColor(red: 255.0/255.0, green: 140/255.0, blue: 0/255.0, alpha: 1.0)
    }
    
    func addMarkersToMap(){
        if mvMapa.annotations.count > 0 {
            self.mvMapa.removeAnnotations(mvMapa.annotations)
        }
        annotations = (diaryEntriesViewController?.diaryEntries)!
        mvMapa.addAnnotations(annotations)
        if annotations.count > 0 {
            let regiao = mostraMarkers(annotations)
            mvMapa.setRegion(regiao, animated: true)
        }
        
    }
    
    @IBAction func segmentedControlAction(sender: UISegmentedControl!) {

        switch (sender.selectedSegmentIndex) {
            case 0:
                mvMapa.mapType = .Standard
            case 1:
                mvMapa.mapType = .Satellite
            default:
                mvMapa.mapType = .Hybrid
        }
    }
    
    func mostraMarkers(markers: [MKAnnotation]) -> MKCoordinateRegion {
        var regiao: MKCoordinateRegion
        
        switch markers.count {
        case 1:
            let marker = markers[markers.count - 1]
            regiao = MKCoordinateRegionMakeWithDistance(marker.coordinate, 1000, 1000)
            
        default:
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            
            for marker in markers {
                topLeftCoord.latitude = max(topLeftCoord.latitude, marker.coordinate.latitude)
                topLeftCoord.longitude = min(topLeftCoord.longitude, marker.coordinate.longitude)
                bottomRightCoord.latitude = min(bottomRightCoord.latitude, marker.coordinate.latitude)
                bottomRightCoord.longitude = max(bottomRightCoord.longitude, marker.coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2D(
                latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2,
                longitude: topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
            
            let extraSpace = 1.3
            let span = MKCoordinateSpan(
                latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace,
                longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)
            
            regiao = MKCoordinateRegion(center: center, span: span)
        }
        return mvMapa.regionThatFits(regiao)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "sigaToViewDiary" {
            let navVC = segue.destinationViewController as! UINavigationController
            let diaryVC = navVC.viewControllers[0] as! DiaryEntryDetailsViewController
            let button = sender as! UIButton
            let de = annotations[button.tag]
            diaryVC.diaryEntry = de
            diaryVC.senderMap = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mostrarTooltip(sender : UIButton){
        performSegueWithIdentifier("sigaToViewDiary", sender: sender)
    }
    
    @IBAction func unwindToMap(segue: UIStoryboardSegue) {

    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("Annotation selected")
        
        if let annotation = view.annotation {
            print("annotation title: \(annotation.title)");
            selectedAnnotation = annotation
        }
    }
    
    func getDirections(){
        if let selectedAnnotation = selectedAnnotation {
            let placemark = MKPlacemark(coordinate: selectedAnnotation.coordinate, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = selectedAnnotation.title!
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMapsWithLaunchOptions(launchOptions)
        }
    }
}


extension MapViewController: MKMapViewDelegate {
    func mapView(mapa: MKMapView, viewForAnnotation tooltipDetalhesLocal: MKAnnotation) -> MKAnnotationView? {
        guard tooltipDetalhesLocal is DiaryEntry else {
            return nil
        }
        
        let identifier = "DiaryEntry"
        var tooltipView = mapa.dequeueReusableAnnotationViewWithIdentifier(identifier) as! MKPinAnnotationView!
        if tooltipView == nil {
            tooltipView = MKPinAnnotationView(annotation: tooltipDetalhesLocal, reuseIdentifier: identifier)
            
            tooltipView.enabled = true
            tooltipView.canShowCallout = true
            tooltipView.animatesDrop = false
            
            let smallSquare = CGSize(width: 30, height: 30)
            let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
            button.setBackgroundImage(UIImage(named: "car"), forState: .Normal)
            button.addTarget(self, action: #selector(MapViewController.getDirections), forControlEvents: .TouchUpInside)
            tooltipView.leftCalloutAccessoryView = button
            
            let btnDetalhesPonto = UIButton(type: .DetailDisclosure)
            btnDetalhesPonto.addTarget(self, action: #selector(MapViewController.mostrarTooltip(_:)), forControlEvents: .TouchUpInside)
            tooltipView.rightCalloutAccessoryView = btnDetalhesPonto
        } else {
            tooltipView.annotation = tooltipDetalhesLocal
        }
        
        let button = tooltipView.rightCalloutAccessoryView as! UIButton
        if let index = annotations.indexOf(tooltipDetalhesLocal as! DiaryEntry) {
            button.tag = index
        }
        
        return tooltipView
    }
}
