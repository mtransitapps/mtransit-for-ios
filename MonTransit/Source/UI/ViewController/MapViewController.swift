//
//  MapViewController.swift
//  SidebarMenu
//
//

import UIKit
import MapKit
import FBAnnotationClusteringSwift

class MapViewController: UIViewController {
    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    private var mPositionUpdated:Bool = false
    private let regionRadius: CLLocationDistance = 1000
    private let clusteringManager = FBClusteringManager()
    private let mStationProvider = StationDataProviderHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .Black;
        
        clusteringManager.delegate = self
        mapView.delegate = self
        
        mPositionUpdated = false
        
        if revealViewController() != nil && menuButton != nil {
            
            //revealViewController().delegate = self
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        let wLocation = AppDelegate().sharedInstance().getUserLocation()
        self.centerMapOnLocation(wLocation)
        
        self.pleaseWait()
        processStations()
        
        self.addIAdBanner()
        self.navigationController!.navigationBar.barTintColor = ColorUtils.hexStringToUIColor("212121")
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        //clusteringManager.removeAnnotations()
        //clusteringManager.delegate = nil
       // mapView.delegate = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centerMapOnLocation(location: CLLocation, iAnimated:Bool = false) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: iAnimated)
    }
    
    func displayStation(iList:[StationObject], iAgencyId:Int, iType:SQLProvider.DatabaseType)
    {
        var wArrayAnnotation:[FBCustomAnnotation] = []
        
        for wStation in iList {
            
            let wPinLocation = FBCustomAnnotation()
            wPinLocation.coordinate = CLLocationCoordinate2D(latitude: wStation.getStationLatitude(), longitude: wStation.getStationLongitude())
            wPinLocation.station = wStation
            wPinLocation.type = iType
            wPinLocation.agencyId = iAgencyId
            wPinLocation.title = wStation.getStationTitle()
            wPinLocation.subtitle = String(wStation.getStationId())
            wArrayAnnotation.append(wPinLocation)
        }
        
        clusteringManager.addAnnotations(wArrayAnnotation)

    }
    
    func processStations()
    {
        dispatch_async(dispatch_get_main_queue(), {
            
            for wAgency in AgencyManager.getAgencies()
            {
                self.displayStation(self.mStationProvider.retrieveAllStations(wAgency.mAgencyId), iAgencyId:wAgency.getAgencyId(), iType: wAgency.mAgencyType)
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.clearAllNotice()
                self.centerMapOnLocation(AppDelegate().sharedInstance().getUserLocation())

            })

        })
    }
    
    func displayGtfsPAge(iNearest:NearestObject)
    {
        
    }

    @IBAction func centerToUser(){
        
        centerMapOnLocation(AppDelegate().sharedInstance().getUserLocation(), iAnimated:true)
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        if !view.annotation!.isKindOfClass(FBAnnotationCluster)
        {
            let wPinLocation = view.annotation as! FBCustomAnnotation
            let wNearestList = mStationProvider.retrieveStationsByStopCode(wPinLocation.station, iId: wPinLocation.agencyId, iType: wPinLocation.type)
            wPinLocation.nearest = wNearestList
            var wBuses = ""
            for wNearest in wNearestList
            {
                if wNearest.getRelatedBus().getBusNumber() != ""{
                    wBuses += wNearest.getRelatedBus().getBusNumber() + " / "
                }
            }
            wPinLocation.subtitle = String(wBuses.characters.dropLast(2))
        }
    }
    var popViewController : PopUpViewControllerSwift!
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,calloutAccessoryControlTapped control: UIControl) {
        
        let wPinLocation = view.annotation as! FBCustomAnnotation
    
        let bundle = NSBundle(forClass: PopUpViewControllerSwift.self)
        if UIScreen.mainScreen().bounds.size.width > 320 {
            if UIScreen.mainScreen().scale == 3 {
                self.popViewController = PopUpViewControllerSwift(nibName: "PopUpViewController_iPhone6Plus", bundle: bundle)
                self.popViewController.title = "This is a popup view"
                self.popViewController.showInView(self, iNearestList: wPinLocation.nearest, animated: true)
            } else {
                self.popViewController = PopUpViewControllerSwift(nibName: "PopUpViewController_iPhone6", bundle: bundle)
                self.popViewController.title = "This is a popup view"
                self.popViewController.showInView(self, iNearestList: wPinLocation.nearest,animated: true)
            }
        } else {
            self.popViewController = PopUpViewControllerSwift(nibName: "PopUpViewController", bundle: bundle)
            self.popViewController.title = "This is a popup view"
            self.popViewController.showInView(self, iNearestList: wPinLocation.nearest,animated: true)
        }
    }
}

extension MapViewController : FBClusteringManagerDelegate {
    
    func cellSizeFactorForCoordinator(coordinator:FBClusteringManager) -> CGFloat{
        return 10.0
    }
    
}

extension MapViewController : MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        
        NSOperationQueue().addOperationWithBlock({
            
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            
            let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
            
            let scale:Double = mapBoundsWidth / mapRectWidth
            
            let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
            
            self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mapView)
            
        })
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        var reuseId = ""
        
        if annotation.isKindOfClass(FBAnnotationCluster) {
            
            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, options: nil)
            return clusterView
            
        }
        else if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        else {
            
            reuseId = "Pin"
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
            if pinView == nil{
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            }
            pinView!.enabled = true
            pinView!.canShowCallout = true
            
            let detailButton: UIButton = UIButton(type: UIButtonType.DetailDisclosure)
            pinView!.rightCalloutAccessoryView = detailButton
            
            return pinView
        }
        
    }
}

