//
//  FavoritesViewController.swift
//  MonTransit
//
//  Created by Thibault on 16-01-20.
//  Copyright © 2016 Thibault. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import GoogleMobileAds

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var menuButton:UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bannerConstraint: NSLayoutConstraint!
    private var mSelectedFavorite:FavoriteObject!
    private var mRefreshControl:UIRefreshControl!
    private let mOperationQueue = NSOperationQueue()
    private var mRefreshTimer = NSTimer()
    
    var mBusProvider:BusDataProviderHelper!
    var mTripProvider:TripDataProviderHelper!
    var mStopProvider:StationDataProviderHelper!
    var mFavoritesProvider:FavoritesDataProviderHelper!
    
    var mSections:[Section] = []
    
    // custom type to represent table sections
    class Section {
        var type:SQLProvider.DatabaseType!
        var title:String!
        var favorites: [FavoriteObject] = []
        
        func addFavorites(iTitle:String, iFav: [FavoriteObject], iType:SQLProvider.DatabaseType) {
            
            self.type = iType
            self.title = iTitle
            self.favorites = iFav
        }
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .Black;
        
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
       
        pullToRefresh()
        self.addIAdBanner()
        
        mBusProvider = BusDataProviderHelper()
        mTripProvider = TripDataProviderHelper()
        mStopProvider = StationDataProviderHelper()
        mFavoritesProvider = FavoritesDataProviderHelper()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.barTintColor = ColorUtils.hexStringToUIColor("212121")
        
        retrieveFavorites()
        mRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(45, target:self, selector: #selector(FavoritesViewController.updateTimer), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        mOperationQueue.cancelAllOperations()
                
        self.clearAllNotice()
        mRefreshTimer.invalidate()
    }
    
    var adRecieved:Bool = false
    override func adViewDidReceiveAd(bannerView: GADBannerView!) {
        super.adViewDidReceiveAd(bannerView)
        if (!self.adRecieved)
        {
            bannerConstraint.constant = -CGRectGetHeight(bannerView.frame)
            self.adRecieved = true;
        }
    }
    
    func retrieveFavorites()
    {
        mSections.removeAll()
        self.pleaseWait()
        
        let wFavoritesOperation = NSBlockOperation
        {
            for wAgency in AgencyManager.getAgencies(){
                
                // get favorites
                let iId = wAgency.mAgencyId
                var wListOfFav = self.mFavoritesProvider.retrieveFavorites(iId, iType: wAgency.mAgencyType)
                wListOfFav = self.processFavorites(wListOfFav, iId: iId)
                
                let wSection = Section()
                wSection.addFavorites(wAgency.mAgencyName, iFav: wListOfFav, iType: wAgency.mAgencyType)
                self.mSections.append(wSection)
            }
            
            dispatch_async(dispatch_get_main_queue())
            {
                self.tableView.reloadData()
                self.clearAllNotice()
            }
        }
        
        wFavoritesOperation.qualityOfService = .Background
        mOperationQueue.addOperation(wFavoritesOperation)
    }
    
    func processFavorites(iListOfFav:[FavoriteObject], iId:Int) -> [FavoriteObject]
    {
        for wFav in iListOfFav {
        
            wFav.setRelatedBus(mBusProvider.retrieveRouteById(wFav.getRouteId(), iId:iId))
            wFav.setRelatedTrip(mTripProvider.retrieveTripById(wFav.getTripId(), iId:iId))
            wFav.setRelatedStation(mStopProvider.retrieveStationById(wFav.getStopId(), iTripId:wFav.getTripId(), iId:iId))
        }
        
        return iListOfFav
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        
        if !mSections.isEmpty{
            return mSections.count
        }
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        if !mSections.isEmpty{
            return mSections[section].favorites.count
        }
        return 0
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("favoriteCell", forIndexPath: indexPath) as! FavoriteTableViewCell
        
        if mSections.count > 0
        {
            if nil != mSections[indexPath.section].favorites[indexPath.row].getRelatedBus() {
                
                let wFav = mSections[indexPath.section].favorites[indexPath.row]
                cell.addFavoriteParameter(wFav.getRelatedStation().getStationTitle(), iBusNumber: wFav.getRelatedBus().getBusNumber(), iDirection: wFav.getRelatedTrip().getTripDirection(), iColor: wFav.getRelatedBus().getBusColor(), iDistance: wFav.getRelatedStation().distanceToUser(AppDelegate().sharedInstance().getUserLocation()))
                
                cell.setAlert(AppDelegate().sharedInstance().getJson().retrieveAlertByContainStationId(wFav.getRelatedBus().getBusId(), iDirection: wFav.getRelatedTrip().getTripDirection(), iStationId: wFav.getRelatedStation().getStationCode()))
                
                if wFav.getRelatedGtfs() == nil {
                    cell.setUpNearestComputations(wFav,iId: wFav.getAgencyId(), iType: mSections[indexPath.section].type)
                }
                else{
                    
                    let wMin       = (wFav.getRelatedGtfs().count > 0 ? wFav.getRelatedGtfs()[0].getNSDate().getMinutesDiference(NSDate()) : -1)
                    let wSecondMin = (wFav.getRelatedGtfs().count > 1 ? wFav.getRelatedGtfs()[1].getNSDate().getMinutesDiference(NSDate()) : -1)
                    
                    cell.addTime(wMin, iSecondHour: wSecondMin)
                }
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if !mSections.isEmpty && mSections[section].favorites.count != 0 {
            return mSections[section].title
        }
        return ""
    }
    
    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            // Delete the row from the data source
            let wSelectedFavorite = mSections[indexPath.section].favorites[indexPath.row]
            
            mFavoritesProvider.removeFavorites(wSelectedFavorite, iId: wSelectedFavorite.getAgencyId())
            mSections[indexPath.section].favorites.removeAtIndex(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            self.tableView.reloadData()

        }
    }
    


    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Get Cell Label
        let indexPath = tableView.indexPathForSelectedRow;
        mSelectedFavorite = mSections[indexPath!.section].favorites[indexPath!.row]
        
        performSegueWithIdentifier("StopIdentifier", sender: self)
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        if mSections.isEmpty || mSections.count == 0 ||
            (indexPath.section <= mSections.count && indexPath.row <= mSections[indexPath.section].favorites.count && mSections[indexPath.section].favorites[indexPath.row].getRelatedGtfs() == nil)
        {
            return nil
        }
        return indexPath
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "StopIdentifier") {
            
            // initialize new view controller and cast it as your view controller
            let viewController = segue.destinationViewController as! StopViewController
            
            if nil != mSelectedFavorite {
                
                viewController.mSelectedStation = mSelectedFavorite.getRelatedStation()
                viewController.mSelectedBus = mSelectedFavorite.getRelatedBus()
                viewController.mSelectedTrip = mSelectedFavorite.getRelatedTrip()
                
                AgencyManager.setCurrentAgency(mSelectedFavorite.getAgencyId())
            }
        }
    }

    @IBAction func doEdit(sender: AnyObject) {
        
        if (self.tableView.editing) {
            
            self.tableView.setEditing(false, animated: true)
        } else {
            
            self.tableView.setEditing(true, animated: true)
        }
    }
    
    /*
    TIMER
    */
    
    func updateTimer() {
        
        if revealViewController() != nil &&
            revealViewController().frontViewPosition == FrontViewPosition.Left {
            
            self.retrieveFavorites()
        }
    }
    
    /*
    PULL TO REFRESH
    */
    func pullToRefresh(){
        
        self.mRefreshControl = UIRefreshControl()
        self.mRefreshControl.attributedTitle = NSAttributedString(string: "")
        self.mRefreshControl.addTarget(self, action: #selector(FavoritesViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(mRefreshControl)
    }
    
    func refresh(sender:AnyObject)
    {
        self.retrieveFavorites()
        self.mRefreshControl.endRefreshing()
    }

}
