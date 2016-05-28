//
//  FavoriteTableViewCell.swift
//  MonTransit
//
//  Created by Thibault on 16-01-21.
//  Copyright © 2016 Thibault. All rights reserved.
//


import UIKit

class FavoriteTableViewCell: UITableViewCell {
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func addFavoriteParameter(iTitle:String, iBusNumber:String, iDirection:String, iColor:String, iDistance:String ) {
        
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
    
    
    func setUpNearestComputations(iFavorite:FavoriteObject, iId:Int, iType:SQLProvider.DatabaseType) {
        
        var wFirstHour = 0
        var wSecondHour = 0
        
        // set waiting
        waitWheel.startAnimating()
        self.FirstHourLabel.text = ""
        self.SecondHourLabel.text = ""
        
        let wNeatestOperation = NSBlockOperation
        {
            self.retrieveStationsTime(iFavorite, iId:iId, iType: iType)
            dispatch_async(dispatch_get_main_queue())
            {
                wFirstHour   = (iFavorite.getRelatedGtfs().count > 0 ? iFavorite.getRelatedGtfs()[0].getNSDate().getMinutesDiference(NSDate()) : -1)
                wSecondHour  = (iFavorite.getRelatedGtfs().count > 1 ? iFavorite.getRelatedGtfs()[1].getNSDate().getMinutesDiference(NSDate()) : -1)
                
                self.addTime(wFirstHour, iSecondHour:wSecondHour)
            }
        }
        
        wNeatestOperation.qualityOfService = .Background
        NSOperationQueue().addOperation(wNeatestOperation)
    }
    
    
    private func retrieveStationsTime(iFavorite:FavoriteObject, iId:Int, iType:SQLProvider.DatabaseType)
    {
        let wServiceDate = ServiceDateDataProvider()
        
        let wPreviousDate = NSDate().substractDays(1).getDateToInt()
        let wPreviousDateService = wServiceDate.retrieveCurrentServiceByDate(wPreviousDate, iId: iId)
        let wDateService = wServiceDate.retrieveCurrentService(iId)
        
        let wStopProvider = StopDataProviderHelper()
        
        //get previous day
        var wPreviousDayStopList = wStopProvider.retrieveGtfsTime(wPreviousDateService, iStationCodeId: iFavorite.getRelatedStation().getStationId(), iTripId: iFavorite.getRelatedTrip().getTripId(), iId:iId, iDate: wPreviousDate)
        
        // current day
        let wCurrentGtfs = wStopProvider.retrieveGtfsTime(wDateService, iStationCodeId: iFavorite.getRelatedStation().getStationId(), iTripId: iFavorite.getRelatedTrip().getTripId(), iId: iId)
        
        // append list
        wPreviousDayStopList.appendContentsOf(wCurrentGtfs)
        
        // filter
        let wCompleteList = wStopProvider.filterListByTime(wPreviousDayStopList, iPreviousTime: 0, iAfterTime: 2)
        if wCompleteList.count > 0{
            iFavorite.setRelatedGtfs(wCompleteList)
        }
        else
        {
            iFavorite.setRelatedGtfs([GTFSTimeObject(), GTFSTimeObject()])
        }
        
        iFavorite.setRelatedDatabaseType(iType)
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
            wTimeString = (String(Int(wHour)) + " hour(s)")
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
