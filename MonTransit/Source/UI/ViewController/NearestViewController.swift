//
//  NearestViewController.swift
//  MonTransit
//
//  Created by Thibault on 16-01-27.
//  Copyright © 2016 Thibault. All rights reserved.
//

import UIKit
import MapKit
import GoogleMobileAds

class NearestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var menuButton:UIBarButtonItem!

    @IBOutlet weak var marginBannerConstraint: NSLayoutConstraint!
    private var mSelectedNearest:NearestObject!
    private var mRefreshControl:UIRefreshControl!
    private let mOperationQueue = NSOperationQueue()
    private var mLocationManager: CLLocationManager!
    private var mSections:[Section] = []
    private let mMaxDistanceToDisplay = 550
    private var mUserLocation:CLLocation!
    private var positionChangeHandler:EventHandler!
    private var addressChangeHandler:EventHandler!
    private var mRefreshTimer = NSTimer()
    private var mPositionSetted:Bool = false
    
    // custom type to represent table sections
    class Section {
        var type:SQLProvider.DatabaseType!
        var title:String!
        var nearest: [NearestObject] = []
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        if revealViewController() != nil {
            
            revealViewController().delegate = self
            revealViewController().rearViewRevealWidth = 180
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().draggableBorderWidth = 100
            
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        self.addIAdBanner()
        
        self.pleaseWait()
        pullToRefresh()
    }
    
    var adRecieved:Bool = false
    override func adViewDidReceiveAd(bannerView: GADBannerView!) {
        super.adViewDidReceiveAd(bannerView)
        if (!self.adRecieved)
        {
            marginBannerConstraint.constant = -CGRectGetHeight(bannerView.frame)
            self.adRecieved = true;
        }
    }

    override func viewWillAppear(animated: Bool) {
        
        let wTitle = AppDelegate().sharedInstance().dispatchingUserAddress.value
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barStyle = .Black
        
        self.mUserLocation = AppDelegate().sharedInstance().getUserLocation()
        if wTitle != "" {
            self.title = wTitle
        }
        
        self.navigationController!.navigationBar.barTintColor = ColorUtils.hexStringToUIColor("212121")
        
        
        positionChangeHandler = EventHandler(function: {
            (event: Event) in
            
            self.mUserLocation =  AppDelegate().sharedInstance().dispatchingUserPosition.value
            
            if !self.mPositionSetted{
                self.setUpComputations()
                self.mPositionSetted = true
            }
        })
        AppDelegate().sharedInstance().dispatchingUserPosition.addEventListener(.change, handler: positionChangeHandler)
        
        addressChangeHandler = EventHandler(function: {
            (event: Event) in
            
            self.title = AppDelegate().sharedInstance().dispatchingUserAddress.value
        })
        
        AppDelegate().sharedInstance().dispatchingUserAddress.addEventListener(.change, handler: addressChangeHandler)
        
        if AppDelegate().sharedInstance().mPositionSetted{
            self.setUpComputations()
            mPositionSetted = true
        }
        
        mRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(30, target:self, selector: #selector(NearestViewController.updateTimer), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        mOperationQueue.cancelAllOperations()
        
        AppDelegate().sharedInstance().dispatchingUserPosition.removeEventListener(.change, handler: positionChangeHandler)
        AppDelegate().sharedInstance().dispatchingUserPosition.removeEventListener(.change, handler: addressChangeHandler)
        
        self.clearAllNotice()
        mRefreshTimer.invalidate()
    }
    
    private func setUpComputations() {
        
        self.mOperationQueue.cancelAllOperations()

        mSections.removeAll()
        
        let wNeatestOperation = NSBlockOperation
        {
            self.retrieveNearestStations(AgencyManager.getAgencies())
            
            dispatch_async(dispatch_get_main_queue())
            {
                self.tableView.reloadData()
            }
        }
        
        wNeatestOperation.qualityOfService = .Background
        mOperationQueue.addOperation(wNeatestOperation)
    }
    
    func retrieveNearestStations(iAgencies:[Agency]){
    
        for wAgency in iAgencies {
            
            let wId = wAgency.mAgencyId
            let wStationProvider = StationDataProviderHelper()
            var wNearestStations = wStationProvider.retrieveClosestStations(mUserLocation.coordinate.latitude, iLongitude: mUserLocation.coordinate.longitude, iDistance: Double(mMaxDistanceToDisplay), iId: wId, iType: wAgency.mAgencyType)
            
            wNearestStations = self.orderByDistance(wNearestStations, iDistanceLimit: mMaxDistanceToDisplay)
            
            let wSection = Section()
            wSection.type = wAgency.mAgencyType
            wSection.title = wAgency.mAgencyName
            wSection.nearest = wNearestStations
            self.mSections.append(wSection)
        }
        
        self.clearAllNotice()
    }
    
    func orderByDistance(iNearestStations:[NearestObject], iDistanceLimit:Int) -> [NearestObject]
    {
        let wLocation = AppDelegate().sharedInstance().getUserLocation()

        let wOrderList = iNearestStations.sort { $0.getRelatedStation().distanceToUserInMeter(wLocation) < $1.getRelatedStation().distanceToUserInMeter(wLocation)}

        //remove item < Distance
        var wFilterDistanceList = [NearestObject]()
        for wNearest in wOrderList{
            if wNearest.getRelatedStation().distanceToUserInMeter(wLocation) < iDistanceLimit{
                wFilterDistanceList.append(wNearest)
            }
        }
        return wFilterDistanceList
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        if !mSections.isEmpty{
            return mSections.count
        }
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if !mSections.isEmpty{
            return mSections[section].nearest.count
        }
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("nearestCell", forIndexPath: indexPath) as! NearestStationViewCell
        
        if mSections.count > 0
        {
            let wSection = mSections[indexPath.section]
            let wNearest = wSection.nearest[indexPath.row]
            
            cell.addNearestarameter(wNearest.getRelatedStation().getStationTitle(), iBusNumber: wNearest.getRelatedBus().getBusNumber(), iDirection: wNearest.getRelatedTrip().getTripDirection(), iColor: wNearest.getRelatedBus().getBusColor(), iDistance: wNearest.getRelatedStation().distanceToUser(AppDelegate().sharedInstance().getUserLocation()))
            
            cell.setAlert(AppDelegate().sharedInstance().getJson().retrieveAlertByContainStationId(wNearest.getRelatedBus().getBusId(), iDirection: wNearest.getRelatedTrip().getTripDirection(), iStationId: wNearest.getRelatedStation().getStationCode()))
            
            if (cell.mNearest != nil &&
            wNearest.getRelatedStation().getStationId() != cell.mNearest.getRelatedStation().getStationId())
            {
                cell.stopCurrentOperation()
            }
            if  wNearest.getRelatedGtfs() == nil
            {
                cell.setUpNearestComputations(wNearest,iId: wNearest.getAgencyId())
            }
            else{

                let wMin       = (wNearest.getRelatedGtfs().count > 0 ? wNearest.getRelatedGtfs()[0].getNSDate().getMinutesDiference(NSDate()) : -1)
                let wSecondMin = (wNearest.getRelatedGtfs().count > 1 ? wNearest.getRelatedGtfs()[1].getNSDate().getMinutesDiference(NSDate()) : -1)
                
                cell.addTime(wMin, iSecondHour: wSecondMin)
            }
        }
    
        return cell
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if !mSections.isEmpty && mSections[section].nearest.count != 0 {
            return mSections[section].title
        }
        return ""
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Get Cell Label
        let indexPath = tableView.indexPathForSelectedRow;
        
        if !mSections.isEmpty && mSections.count > 0 && indexPath!.section <= mSections.count && indexPath!.row <= mSections[indexPath!.section].nearest.count
        {
            mSelectedNearest = mSections[indexPath!.section].nearest[indexPath!.row]
            performSegueWithIdentifier("GtfsSegue", sender: self)
        }
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        if mSections.isEmpty || mSections.count == 0 ||
            (indexPath.section <= mSections.count && indexPath.row <= mSections[indexPath.section].nearest.count && (mSections[indexPath.section].nearest[indexPath.row].getRelatedStation() == nil) ||
                (mSections[indexPath.section].nearest[indexPath.row].getRelatedBus() == nil)     ||
                (mSections[indexPath.section].nearest[indexPath.row].getRelatedTrip() == nil))
        {
            return nil
        }
        return indexPath

    }

    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "GtfsSegue") {
            
            // initialize new view controller and cast it as your view controller
            
            if mSelectedNearest != nil {
                let viewController = segue.destinationViewController as! StopViewController
                viewController.mSelectedStation = mSelectedNearest.getRelatedStation()
                viewController.mSelectedBus = mSelectedNearest.getRelatedBus()
                viewController.mSelectedTrip = mSelectedNearest.getRelatedTrip()
                
                AgencyManager.setCurrentAgency(mSelectedNearest.getAgencyId())
            }
        }
        
    }
    
/*
    TIMER
*/
    
    func updateTimer() {
        
        self.setUpComputations()
    }
/*
    PULL TO REFRESH
*/
    func pullToRefresh(){
        
        self.mRefreshControl = UIRefreshControl()
        self.mRefreshControl.attributedTitle = NSAttributedString(string: "")
        self.mRefreshControl.addTarget(self, action: #selector(NearestViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(mRefreshControl)
    }
    
    func refresh(sender:AnyObject)
    {
        self.setUpComputations()
        self.mRefreshControl.endRefreshing()
    }
}
