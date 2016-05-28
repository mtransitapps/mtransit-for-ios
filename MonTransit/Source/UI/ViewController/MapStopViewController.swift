//
//  MapStopViewController.swift
//
//

import UIKit
import MapKit

class MapStopViewController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var mSelectedStation:StationObject!
    
    private let regionRadius: CLLocationDistance = 2000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .Black;
        self.mapView.delegate = self
        let initialLocation = displayStation()
        centerMapOnLocation(initialLocation)
        
        getDirections()
        self.addIAdBanner()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func displayStation() -> CLLocation
    {
        var inititalLocation = CLLocation()
        if mSelectedStation != nil
        {
            let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: mSelectedStation.getStationLatitude(), longitude: mSelectedStation.getStationLongitude())
            let anotation = MKPointAnnotation()
        
            anotation.coordinate = location
            anotation.title = mSelectedStation.getStationTitle()
            anotation.subtitle = mSelectedStation.getStationCode()
            mapView.addAnnotation(anotation)
            
            inititalLocation = CLLocation(latitude: mSelectedStation.getStationLatitude(), longitude: mSelectedStation.getStationLongitude())
        }
        else
        {
            // set initial location in Montreal
            inititalLocation = CLLocation(latitude: 45.5588869, longitude: -73.5525975)
        }
        return inititalLocation
    }
    
    @IBAction func close(){
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func getDirections() {
        let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: mSelectedStation.getStationLatitude(), longitude: mSelectedStation.getStationLongitude())
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem.mapItemForCurrentLocation()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: location, addressDictionary: nil))
        request.requestsAlternateRoutes = false
        request.transportType = .Walking
        
        let directions = MKDirections(request: request)

        
        directions.calculateDirectionsWithCompletionHandler { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = self.navigationController!.navigationBar.barTintColor
        renderer.lineWidth = 5.0
        return renderer
    }
}
