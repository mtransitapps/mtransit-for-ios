//
//  AppDelegate.swift
//  SidebarMenu
//
//  Created by Simon Ng on 2/2/15.
//  Copyright (c) 2015 Thibault. All rights reserved.
//

import UIKit
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, AlertAgencyDelegate {
    
    var backgroundSessionCompletionHandler : (() -> Void)?
    
    private var mUserLocation:CLLocation!
    private var mLocationManager: CLLocationManager!
    private let mJson = JsonAgencyAlert()
    
    let dispatchingUserPosition = DispatchingValue(CLLocation())
    let dispatchingUserAddress  = DispatchingValue("")
    
    var mPositionSetted: Bool = false
    
    var window: UIWindow?
    
    func sharedInstance() -> AppDelegate{
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    func startLocationManager() {
        
        if CLLocationManager.locationServicesEnabled() {
            
            mLocationManager = CLLocationManager()
            mLocationManager.delegate = self
            mLocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            mLocationManager.requestWhenInUseAuthorization()
            mLocationManager.distanceFilter = 10.0
            mLocationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)  in
            if (error != nil) {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0] as CLPlacemark
                self.displayLocationInfo(pm)
            } else {
                print("Problem with the data received from geocoder")
            }
        })
        
        let wNewPosition = manager.location!
        let wDistance = Int(self.mUserLocation.coordinate.distanceInMetersFrom(CLLocationCoordinate2D(latitude: wNewPosition.coordinate.latitude, longitude: wNewPosition.coordinate.longitude)))
        
        if wDistance > 10{
            mPositionSetted = true

            mUserLocation = manager.location!
            dispatchingUserPosition.value = mUserLocation
        }
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {
        
        dispatchingUserAddress.value = placemark.addressDictionary!["Street"] as? String ?? ""
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("Error while updating location " + error.localizedDescription)
        mPositionSetted = true
        dispatchingUserPosition.value = mUserLocation
    }
    
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager) {
        
    }

    func getUserLocation() -> CLLocation{
        return mUserLocation
    }
  
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //Check if databse created
        // debug delete
        //File.deleteContentsOfFolder(File.getDocumentFilePath())
        parseXmlAgency()
        
        if !File.documentFileExist(NSBundle.mainBundle().releaseVersionNumber!)
        {
            displayLoadingView()
        }
        else
        {
            SQLProvider.sqlProvider.openDatabase()
            displayNearestView()
        }
        
        return true
    }
    
    private func parseXmlAgency()
    {
        var wString = File.open(File.getBundleFilePath("Agencies", iOfType: "xml")!)!
        wString = wString.stringByReplacingOccurrencesOfString("\n", withString: "").stringByReplacingOccurrencesOfString("  ", withString: "")
        let parser=XMLParser(xml: wString, element:"agency")
        parser.parse()
        let agencies = parser.getAgencies()
        AgencyManager.setAgencies(agencies)
        
        if agencies.capacity > 0 {
            AgencyManager.setCurrentAgency((agencies.first?.mAgencyId)!)
        }

    }
    private func displayNearestView(){
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let swViewController: SwiftSWRevealViewController = mainStoryboard.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SwiftSWRevealViewController
        
        self.window?.rootViewController = swViewController
        
        self.window?.makeKeyAndVisible()
    }
    
    private func displayLoadingView(){
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let swViewController: LoadingViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LoadingViewController") as! LoadingViewController
        
        self.window?.rootViewController = swViewController
        
        self.window?.makeKeyAndVisible()
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // retrieve user position
        mUserLocation = CLLocation(latitude: AgencyManager.getAgency().getLatitude(), longitude: AgencyManager.getAgency().getLongitude())
        startLocationManager()
        
        //retrieve alert
        mJson.delegate = self
        mJson.getJsonAlert(AgencyManager.getAgency().getJsonAlertPath())        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func getJson() -> JsonAgencyAlert{
        return mJson
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        let events = event!.allTouches()
        let touch = events!.first
        let location = touch!.locationInView(self.window)
        let statusBarFrame = UIApplication.sharedApplication().statusBarFrame
        if CGRectContainsPoint(statusBarFrame, location) {
            NSNotificationCenter.defaultCenter().postNotificationName("statusBarSelected", object: nil)
        }
    }
    
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }
} 

