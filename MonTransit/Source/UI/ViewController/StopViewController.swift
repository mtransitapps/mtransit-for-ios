//
//  StopViewController.swift
//  MonTransit
//
//  Created by Thibault on 16-01-19.
//  Copyright © 2016 Thibault. All rights reserved.
//
//

import UIKit
import MapKit
import GoogleMobileAds

let offset_HeaderStop:CGFloat = 67.0 // At this offset the Header stops its transformations
let offset_B_LabelHeader:CGFloat = 95.0 // At this offset the Black label reaches the Header
let distance_W_LabelHeader:CGFloat = 30.0 // The distance between the bottom of the Header and the top of the White Label

class StopViewController: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var scrollView:UIScrollView!
    @IBOutlet var busImage:StopImageView!
    @IBOutlet var header:UIView!
    @IBOutlet var headerLabel:UILabel!
    @IBOutlet var headerMapView:MKMapView!
    @IBOutlet weak var stationCodeLabel: UILabel!
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet var visualEffectView:UIVisualEffectView!
    @IBOutlet var timeListView: UITableView!
    @IBOutlet var heightConstraint:NSLayoutConstraint!
    @IBOutlet var favoriteButton:UIBarButtonItem!
    @IBOutlet weak var alertTextBlock: UITextView!
    @IBOutlet weak var alertSize: NSLayoutConstraint!
    @IBOutlet weak var alertButton: UIButton!
    
    var blurredHeaderImageView:UIImageView?
    
    private var mCompleteStopsList:[GTFSTimeObject]!
    private var mStopsList:[GTFSTimeObject]!
    private var mFavoriteHelper:FavoritesDataProviderHelper!
    private let mPreviousTimeToDisplay = 2
    private let mNextTimeToDisplay = 15
    private var blurView:UIView!
    private var mMapLoaded:Bool = false
    
    var mSelectedStation:StationObject!
    var mSelectedBus:BusObject!
    var mSelectedTrip:TripObject!
    
    private let regionRadius: CLLocationDistance = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        timeListView.delegate = self
        timeListView.dataSource = self
        
        let wServiceDate = ServiceDateDataProvider()
        
        let wStopProvider = StopDataProviderHelper()
        if nil != mSelectedStation{
           
            mCompleteStopsList = []
            //First get previous date of the previsou day
            let wPreviousDate = NSDate().substractDays(1).getDateToInt()
            let wPreviousDateService = wServiceDate.retrieveCurrentServiceByDate(wPreviousDate, iId: AgencyManager.getAgency().getAgencyId())
            let wPreviousDayStopList = wStopProvider.retrieveGtfsTime(wPreviousDateService, iStationCodeId: mSelectedStation.getStationId(), iTripId: mSelectedTrip.getTripId(), iId:AgencyManager.getAgency().getAgencyId(), iDate: wPreviousDate)
            
            // Get current day stop
            let wCurrentDate = NSDate().getDateToInt()
            let wCurrentDateService = wServiceDate.retrieveCurrentServiceByDate(wCurrentDate, iId:AgencyManager.getAgency().getAgencyId())
            let wCurrentDayStopList = wStopProvider.retrieveGtfsTime(wCurrentDateService, iStationCodeId: mSelectedStation.getStationId(), iTripId: mSelectedTrip.getTripId(), iId:AgencyManager.getAgency().getAgencyId())
            
            mCompleteStopsList.appendContentsOf(wPreviousDayStopList)
            mCompleteStopsList.appendContentsOf(wCurrentDayStopList)
            
            self.stationNameLabel.text = mSelectedStation.getStationTitle()
            self.stationCodeLabel.text = mSelectedStation.getStationCode()
            self.headerLabel.text = mSelectedBus.getBusNumber() + " - " + mSelectedStation.getStationTitle()
            
            mStopsList = wStopProvider.filterListByTime(mCompleteStopsList, iPreviousTime: mPreviousTimeToDisplay, iAfterTime: mNextTimeToDisplay)
            
            //set nearest time
            if mPreviousTimeToDisplay < mStopsList.count {
                
                mStopsList[mPreviousTimeToDisplay].isNearest(true)
            }
            else if mNextTimeToDisplay < mStopsList.count{
                
                mStopsList[mNextTimeToDisplay].isNearest(true)
            }
            self.addIAdBanner()
        }
        
        if nil != mSelectedBus {
            
            self.navigationController!.navigationBar.barTintColor = ColorUtils.hexStringToUIColor(mSelectedBus.getBusColor())
            self.busImage.backgroundColor = ColorUtils.hexStringToUIColor(mSelectedBus.getBusColor())
            self.busImage.addBusNumber(mSelectedBus.getBusNumber(), iDirection: mSelectedTrip.getTripDirection())
        }
        heightConstraint.constant = CGFloat(44 * (mStopsList.count + 1))
        
        mFavoriteHelper = FavoritesDataProviderHelper()
        if nil != mFavoriteHelper {
            
            let wFav = FavoriteObject(iId: 1, iRouteId: mSelectedBus.getBusId(), iTripId: mSelectedTrip.getTripId(), iStopId: mSelectedStation.getStationId(), iFolderId: 1, iProviderType: AgencyManager.getAgency().mAgencyType, iAgencyId: AgencyManager.getAgency().getAgencyId())
            
            if mFavoriteHelper.favoriteExist(wFav, iId: AgencyManager.getAgency().getAgencyId())
            {
                favoriteButton.image = UIImage(named: "favorite_remove")
            }
            else
            {
                favoriteButton.image = UIImage(named: "favorite_add")
            }
            
        }
        
        mMapLoaded = false
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if !mMapLoaded {
            
            dispatch_async(dispatch_get_main_queue())
            {
                self.headerMapView = MKMapView(frame: self.header.bounds)
                self.headerMapView?.contentMode = UIViewContentMode.ScaleAspectFill
                self.headerMapView.showsUserLocation = true
                self.header.insertSubview(self.headerMapView, belowSubview: self.headerLabel)
                
                self.centerMapOnLocation(CLLocation(latitude: self.mSelectedStation.getStationLatitude(), longitude: self.mSelectedStation.getStationLongitude()))
                
                self.blurView = UIView(frame: self.headerMapView.bounds)
                self.visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
                self.visualEffectView.frame = self.headerMapView.bounds
                self.blurView.insertSubview(self.visualEffectView, atIndex: 1)
                self.blurView.alpha = 0.0
                
                self.header.insertSubview(self.blurView, belowSubview: self.headerLabel)
                self.header.clipsToBounds = true
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        processAlert()
    }
    
    var adRecieved:Bool = false
    override func adViewDidReceiveAd(bannerView: GADBannerView!) {
        super.adViewDidReceiveAd(bannerView)
        if (!self.adRecieved)
        {
            heightConstraint.constant = CGFloat(44 * (mStopsList.count + 1)) + CGRectGetHeight(bannerView.frame)
            self.adRecieved = true;
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        
        // PULL DOWN -----------------
        
        if offset < 0 {
            
            let headerScaleFactor:CGFloat = -(offset) / header.bounds.height
            let headerSizevariation = ((header.bounds.height * (1.0 + headerScaleFactor)) - header.bounds.height)/2.0
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            
            header.layer.transform = headerTransform
        }
            
            // SCROLL UP/DOWN ------------
            
        else {
            
            // Header -----------
            
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            
            //  ------------ Label
            
            let labelTransform = CATransform3DMakeTranslation(0, max(-distance_W_LabelHeader, offset_B_LabelHeader - offset), 0)
            headerLabel.layer.transform = labelTransform
            
            //  ------------ Blur
            
            blurView?.alpha = min (1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
            
            // Bus Image -----------
            
            let busScaleFactor = (min(offset_HeaderStop, offset)) / busImage.bounds.height / 1.4 // Slow down the animation
            let busSizeVariation = ((busImage.bounds.height * (1.0 + busScaleFactor)) - busImage.bounds.height) / 2.0
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, busSizeVariation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - busScaleFactor, 1.0 - busScaleFactor, 0)
            
            if offset <= offset_HeaderStop {
                
                if busImage.layer.zPosition < header.layer.zPosition{
                    header.layer.zPosition = 0
                }
                
            }else {
                if busImage.layer.zPosition >= header.layer.zPosition{
                    header.layer.zPosition = 2
                }
            }
        }
        
        // Apply Transformations
        
        header.layer.transform = headerTransform
        busImage.layer.transform = avatarTransform
    }
    
    @IBAction func addFavorite() {

        if nil != mFavoriteHelper {
            
            let wFav = FavoriteObject(iId: 1, iRouteId: mSelectedBus.getBusId(), iTripId: mSelectedTrip.getTripId(), iStopId: mSelectedStation.getStationId(), iFolderId: 1, iProviderType: AgencyManager.getAgency().mAgencyType, iAgencyId: AgencyManager.getAgency().getAgencyId())
            
            self.clearAllNotice()
            if mFavoriteHelper.favoriteExist(wFav, iId: AgencyManager.getAgency().getAgencyId())
            {
                mFavoriteHelper.removeFavorites(wFav, iId: AgencyManager.getAgency().getAgencyId())
                favoriteButton.image = UIImage(named: "favorite_add")
                self.noticeError(NSLocalizedString("RemovedKey", comment: "Removed"), autoClear: true, autoClearTime: 1)
            }
            else
            {
                mFavoriteHelper.addFavorites(wFav, iId: AgencyManager.getAgency().getAgencyId())
                favoriteButton.image = UIImage(named: "favorite_remove")
                self.noticeSuccess(NSLocalizedString("AddedKey", comment: "Added"), autoClear: true, autoClearTime: 1)
            }
            
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        headerMapView.setRegion(coordinateRegion, animated: false)
        
        
        let stoplocation:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let anotation = MKPointAnnotation()
        
        anotation.coordinate = stoplocation
        headerMapView.addAnnotation(anotation)

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mStopsList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("StopCell", forIndexPath: indexPath) as! StopTableViewCell
        
        // Configure the cell...
        if mStopsList != nil && indexPath.row <= mStopsList.count
        {
            cell.mTimeBusLabel.text = mStopsList[indexPath.row].getNSDate().getTime()
            cell.mDateBusLabel.text = mStopsList[indexPath.row].getNSDate().getDate()
            cell.isNearest(mStopsList[indexPath.row].isNearest())
        }
        return cell
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "MapSegue") {
            
            mMapLoaded = true
        
            let navVC = segue.destinationViewController as! UINavigationController
            let tableVC = navVC.viewControllers.first as! MapStopViewController
            
            tableVC.mSelectedStation = mSelectedStation
            tableVC.navigationController!.navigationBar.barTintColor = ColorUtils.hexStringToUIColor(mSelectedBus.getBusColor())
        }
        else if (segue.identifier == "HourSegue") {

            mMapLoaded = true
            
            let navVC = segue.destinationViewController as! UINavigationController
            let tableVC = navVC.viewControllers.first as! CompleteHourViewController
            
            tableVC.navigationController!.navigationBar.barTintColor = ColorUtils.hexStringToUIColor(mSelectedBus.getBusColor())
            tableVC.mStopsList = mCompleteStopsList
            tableVC.mStationId = mSelectedStation.getStationId()
            tableVC.mTripId = mSelectedTrip.getTripId()
        }
    }
    
    func processAlert(){

        let wAlerts = AppDelegate().sharedInstance().getJson().retrieveAlertById(mSelectedBus.getBusId(), iDirection: mSelectedTrip.getTripDirection(), iStationId: mSelectedStation.getStationCode())

        var wAlertText = ""
        
        if wAlerts.count > 0 && !wAlerts[0].alert.containsString(AgencyManager.getAgency().getDefaultAlertMessage())
        {
            for wAlert in wAlerts{
                
                wAlertText += wAlert.alert + "\n\n"
            }
            wAlertText = String(wAlertText.characters.dropLast(2))
            alertButton.enabled = true
            alertButton.hidden = false
            
            let wString = wAlertText as NSString
            let wCode = String(mSelectedStation.getStationCode())
            let attributedString = NSMutableAttributedString(string: wString as String)
            let firstAttributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(14)]
            
            
            let wCodeRange = wString.rangeOfString(wCode)
            let wDotIndex = wString.rangeOfString(".")
            
            if wCodeRange.length != 0 && wDotIndex.location > wCodeRange.location{
                let wBoldSation = NSMakeRange(wCodeRange.location, wDotIndex.location - wCodeRange.location)
            
                attributedString.addAttributes(firstAttributes, range: wBoldSation)
            }
            alertTextBlock.text = wAlertText
            alertTextBlock.attributedText = attributedString
        }
        
        self.alertSize.constant = 0

    }
    
    @IBAction func displayAlert(){
    
        if self.alertSize.constant == 0 {
            self.alertTextBlock.sizeToFit()
            self.alertSize.constant = self.alertTextBlock.frame.height
            UIView.animateWithDuration(0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
        else {
            self.alertSize.constant = 0
            UIView.animateWithDuration(0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
    
    }
}