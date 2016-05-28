//
//  StationsViewController.swift
//  SidebarMenu
//
//  Created by Thibault on 15-12-17.
//

import UIKit
import CoreLocation
import MapKit
import GoogleMobileAds

class StationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var mSelectedStation:StationObject!
    
    @IBOutlet weak var tableView: UITableView!
    
    var mStationsList:[StationObject]!
    var mSelectedBus:BusObject!
    
    var mSelectedTrip:TripObject!
    var mCurrentDistanceInMeter:Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        mCurrentDistanceInMeter = 0
        
        let wStationProvider = StationDataProviderHelper()
        mStationsList = wStationProvider.retrieveStations(mSelectedTrip.getTripId(), iId:AgencyManager.getAgency().getAgencyId())
        
        NSNotificationCenter.defaultCenter().addObserverForName("statusBarSelected", object: nil, queue: nil) { event in
            
            // scroll to top of a table view
            self.tableView!.setContentOffset(CGPointZero, animated: true)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var wPosition = UITableViewScrollPosition.Top
        let wLocation = AppDelegate().sharedInstance().getUserLocation()
        
        //find the nearest stop
        var wIndex = retrieveClosestStation (wLocation)
        // decal two element
        
        if wIndex == 0{
            wIndex = 0
        }
        else if wIndex == mStationsList.count || wIndex == (mStationsList.count - 1)
        {
            wIndex = mStationsList.count - 1
            wPosition = UITableViewScrollPosition.Bottom
        }
        else
        {
            wIndex = (wIndex - 1)
        }
        
        let lastIndex = NSIndexPath(forRow:  wIndex, inSection: 0)
        self.tableView.scrollToRowAtIndexPath(lastIndex, atScrollPosition: wPosition, animated: false)
        self.tableView.reloadData()
    }
    
    func retrieveClosestStation (iLocation:CLLocation) -> Int
    {
        var wIndex = 0
        var wDistanteTo:Double = 0.0
        var wCurrentDistance:Double = 0.0
        
        var wNearestStation:StationObject!
        
        for wStation in mStationsList
        {
            wCurrentDistance = iLocation.coordinate.distanceInMetersFrom(CLLocationCoordinate2D(latitude: wStation.getStationLatitude(), longitude: wStation.getStationLongitude()))
            if wCurrentDistance < wDistanteTo || wDistanteTo == 0
            {
                wDistanteTo = wCurrentDistance
                wNearestStation = wStation
            }
            
        }
        wNearestStation.setStationNearest()
      
        for wStation in mStationsList
        {
            if wStation.getStationNearest(){
                break
            }
            else{
                wIndex += 1
            }
        }

        return wIndex
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mStationsList.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("StationCell", forIndexPath: indexPath) as! StationTableViewCell
        var wCurrentStation:StationObject!
        
        // Configure the cell...
        if mStationsList != nil && indexPath.row <= mStationsList.count
        {
            wCurrentStation = mStationsList[indexPath.row]
            
            cell.mStationTitleLabel.text = wCurrentStation.getStationTitle()
            cell.mStationDistance.text = wCurrentStation.distanceToUser(AppDelegate().sharedInstance().getUserLocation())
            cell.isNearest(wCurrentStation.getStationNearest())
            cell.setAlert(AppDelegate().sharedInstance().getJson().retrieveAlertByContainStationId(mSelectedBus.getBusId(), iDirection: mSelectedTrip.getTripDirection(), iStationId: wCurrentStation.getStationCode()))
        }
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Get Cell Label
        let indexPath = tableView.indexPathForSelectedRow;
        
        if mStationsList != nil && indexPath!.row <= mStationsList.count
        {
            mSelectedStation = mStationsList[(indexPath?.row )!]
        }
      
        performSegueWithIdentifier("GtfsSegue", sender: self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "GtfsSegue") {
            
            // initialize new view controller and cast it as your view controller
            let viewController = segue.destinationViewController as! StopViewController
            viewController.mSelectedStation = mSelectedStation
            viewController.mSelectedBus = mSelectedBus
            viewController.mSelectedTrip = mSelectedTrip
        }
        
    }
}
