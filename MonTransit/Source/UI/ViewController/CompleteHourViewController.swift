//
//  CompleteHourViewController.swift
//  MonTransit
//
//  Created by Thibault on 16-01-25.
//  Copyright © 2016 Thibault. All rights reserved.
//

import UIKit
import GoogleMobileAds

class CompleteHourViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    var mStopsList:[GTFSTimeObject]!
    var mStationId:Int!
    var mTripId:Int!
    
    @IBOutlet var tableView: UITableView!
    
    private var mSections = [Section]()
    private var mServiceDateHelper:ServiceDateDataProvider!
    private var mStopService:StopDataProviderHelper!
    private var mSelectedDate:NSDate = NSDate()
    
    // custom type to represent table sections
    class Section {
        var mTitle:String!
        var mGtfs: [GTFSTimeObject]!
        
        init(){
            mTitle = ""
            mGtfs = []
        }
        func addFavorites(iTitle:String, iGtfs: GTFSTimeObject) {
            
            self.mTitle = iTitle
            self.mGtfs.append(iGtfs)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barStyle = .Black;
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        mServiceDateHelper = ServiceDateDataProvider()
        mStopService = StopDataProviderHelper()

        retrieveGtfsTime()
        self.addIAdBanner()
    }
    
    var adRecieved:Bool = false
    override func adViewDidReceiveAd(bannerView: GADBannerView!) {
        super.adViewDidReceiveAd(bannerView)
        if (!self.adRecieved)
        {
            var currentRect:CGRect = self.tableView.frame;
            currentRect.size.height -= CGRectGetHeight(bannerView.frame)
            self.tableView.frame = currentRect
            
            self.adRecieved = true;
        }
    }
    
    func retrieveGtfsTime(){
        
        let wServiceDate = ServiceDateDataProvider()
        let wDate = wServiceDate.retrieveCurrentServiceByDate(mSelectedDate.getDateToInt(), iId: AgencyManager.getAgency().getAgencyId())
        
        self.mStopsList.removeAll()
        self.mStopsList = self.mStopService.retrieveGtfsTime(wDate, iStationCodeId: self.mStationId, iTripId: self.mTripId, iId:AgencyManager.getAgency().getAgencyId(), iDate: mSelectedDate.getDateToInt())
        
        self.createSectionGtfs()
        
        self.tableView.reloadData()

        if !mSections.isEmpty{
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
        }
        self.title = mSelectedDate.getDate()
    }
    
    func createSectionGtfs()
    {
        var wPrevisouGtfs:GTFSTimeObject?
        var wPrevisouSection:Section = Section()
        
        mSections.removeAll()
        
        //order the list for section
        
        for wGtfs in mStopsList
        {
            if mSections.count != 0 && wGtfs.getNSDate().getHour() == wPrevisouGtfs!.getNSDate().getHour() {
                
                wPrevisouSection.mGtfs.append(wGtfs)
            }
            else {
                let wSection = Section()
                wSection.addFavorites(String(wGtfs.getNSDate().getHour()), iGtfs: wGtfs)
                mSections.append(wSection)
            }
            
            wPrevisouGtfs = wGtfs
            if mSections.last != nil {
                wPrevisouSection = mSections.last!
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /* IBActions */
    @IBAction func datePickerTapped(sender: AnyObject) {

        let wLimits = mServiceDateHelper.getDatesLimit(AgencyManager.getAgency().getAgencyId())

        let wMin = NSDate.daysBetweenDate(NSDate(), endDate: wLimits.min.getNSDate())
        let wMax = NSDate.daysBetweenDate(NSDate(), endDate: wLimits.max.getNSDate())

        
        DatePickerDialog().show(NSLocalizedString("DatePicker", comment: "Title"),
                                doneButtonTitle: NSLocalizedString("DoneKey", comment: "Done"),
                                cancelButtonTitle: NSLocalizedString("CancelKey", comment: "Cancel"),
                                datePickerMode: .Date, iMin:wMin, iMax:wMax) {
            (date) -> Void in
        
            self.mSelectedDate = date
            self.retrieveGtfsTime()
        }
        
    }
    
    @IBAction func close(){
        
        self.dismissViewControllerAnimated(true, completion: nil)
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
            return mSections[section].mGtfs.count
        }
        return 0
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("StopCell", forIndexPath: indexPath) as! StopTableViewCell

        // Configure the cell...
        let wSection = mSections[indexPath.section]
        let wGtfs = wSection.mGtfs[indexPath.row]
        
        cell.mTimeBusLabel.text = wGtfs.getNSDate().getTime()
        cell.mDateBusLabel.text = wGtfs.getNSDate().getDate()
        cell.isNearest(wGtfs.isNearest())
        return cell
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if !mSections.isEmpty {
            return String(format: "%02d", Int(mSections[section].mTitle)!)  + ":00"
        }
        return ""
    }
}
