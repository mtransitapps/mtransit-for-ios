//
//  NearestStationViewCell.swift
//  MonTransit
//
//  Created by Thibault on 16-01-21.
//  Copyright © 2016 Thibault. All rights reserved.
//


import UIKit

class NearestStationViewCell: UITableViewCell {
    
    @IBOutlet weak var stationTitleLabel:UILabel!
    @IBOutlet weak var directionLabel:UILabel!
    @IBOutlet weak var busColor:UILabel!
    @IBOutlet weak var metroImage:UIImageView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var FirstHourLabel: UILabel!
    @IBOutlet weak var SecondHourLabel: UILabel!
    @IBOutlet weak var waitWheel: UIActivityIndicatorView!
    @IBOutlet weak var mAlertImage: UIImageView!

    private let mOperationQueue = NSOperationQueue()
    var mNearest:NearestObject!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func stopCurrentOperation() {
        mOperationQueue.cancelAllOperations()
        
        waitWheel.startAnimating()
        self.FirstHourLabel.text = ""
        self.SecondHourLabel.text = ""
    }
    
    func addNearestarameter(iTitle:String, iBusNumber:String, iDirection:String, iColor:String, iDistance:String ) {
        
        waitWheel.startAnimating()
        
        distanceLabel.text = iDistance
        directionLabel.text = iDirection
        stationTitleLabel.text = iTitle
        view.backgroundColor =  ColorUtils.hexStringToUIColor(iColor)
        
        if iBusNumber == ""
        {
            self.metroImage.image = UIImage(named: "subway_icn")
            busColor.text = ""
        }
        else
        {
            self.metroImage.image = UIImage()
            busColor.text = iBusNumber
        }
    }
    
    func addTime(iHour:Int, iSecondHour:Int){
        
        let wHourText = self.displayTime(iHour)
        self.FirstHourLabel.text = wHourText
        
        let wSecondHourText = self.displayTime(iSecondHour)
        self.SecondHourLabel.text = wSecondHourText
        
        if wHourText != ""{
            waitWheel.stopAnimating()
        }
    }

    
    func setUpNearestComputations(iNearest:NearestObject, iId:Int) {
        
        // set waiting
        waitWheel.startAnimating()
        
        self.mNearest = iNearest
        
        var wFirstHour = 0
        var wSecondHour = 0
        
        self.FirstHourLabel.text = ""
        self.SecondHourLabel.text = ""
        
        let wNeatestOperation = NSBlockOperation
        {
            self.retrieveStationsTime(iNearest, iId:iId)
            dispatch_async(dispatch_get_main_queue())
            {
                wFirstHour   = (iNearest.getRelatedGtfs().count > 0 ? iNearest.getRelatedGtfs()[0].getNSDate().getMinutesDiference(NSDate()) : -1)
                wSecondHour  = (iNearest.getRelatedGtfs().count > 1 ? iNearest.getRelatedGtfs()[1].getNSDate().getMinutesDiference(NSDate()) : -1)
                
                self.addTime(wFirstHour, iSecondHour:wSecondHour)
            }
        }
        
        wNeatestOperation.qualityOfService = .Background
        mOperationQueue.addOperation(wNeatestOperation)
    }
    
    
    private func retrieveStationsTime(iNearest:NearestObject, iId:Int)
    {
        let wServiceDate = ServiceDateDataProvider()
        
        let wPreviousDate = NSDate().substractDays(1).getDateToInt()
        let wPreviousDateService = wServiceDate.retrieveCurrentServiceByDate(wPreviousDate, iId: iId)
        let wDateService = wServiceDate.retrieveCurrentService(iId)
        
        let wStopProvider = StopDataProviderHelper()
        
        //get previous day
        var wPreviousDayStopList = wStopProvider.retrieveGtfsTime(wPreviousDateService, iStationCodeId: iNearest.getRelatedStation().getStationId(), iTripId: iNearest.getRelatedTrip().getTripId(), iId:iId, iDate: wPreviousDate)
        
        // current day
        let wCurrentGtfs = wStopProvider.retrieveGtfsTime(wDateService, iStationCodeId: iNearest.getRelatedStation().getStationId(), iTripId: iNearest.getRelatedTrip().getTripId(), iId: iId)
        
        // append list
        wPreviousDayStopList.appendContentsOf(wCurrentGtfs)
        
        // filter
        let wCompleteList = wStopProvider.filterListByTime(wPreviousDayStopList, iPreviousTime: 0, iAfterTime: 2)
        if wCompleteList.count > 0{
            iNearest.setRelatedGtfs(wCompleteList)
        }
        else
        {
            iNearest.setRelatedGtfs([GTFSTimeObject(), GTFSTimeObject()])
        }        
    }
    
    private func displayTime(iTime:Int) -> String{
        
        let wMin = iTime
        var wTimeString = ""
        
        if wMin < 0{
            wTimeString = "Tomorrow"
        }
        else if wMin == 0 {
            wTimeString = "Now"
        }
        else if wMin > 60{
            let wHour = ceil(Double(wMin / 60))
            if wHour > 1 {wTimeString = (String(Int(wHour)) + " hours")}
            else {wTimeString = (String(Int(wHour)) + " hour")}
        }
        else {
            wTimeString = String(wMin) + " min"
        }
        return wTimeString
    }
    
    func setAlert(iAlert:Bool)
    {
        if iAlert {
            mAlertImage.hidden = false
        }
        else{
            mAlertImage.hidden = true
        }
    }
}
