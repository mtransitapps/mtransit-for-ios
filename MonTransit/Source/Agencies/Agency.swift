//
//  StmBusAgency.swift
//  MonTransit
//
//  Created by Thibault on 16-01-21.
//  Copyright © 2016 Thibault. All rights reserved.
//

import UIKit

class Agency:NSObject {
    
    var mDisplayIAds = true
    
    // Agency ID
    var mAgencyId:Int = 1
    var mAgencyUniqueId: String = ""
    
    // Agency Name
    var mAgencyName:String = ""
    
    // Agency Type
    var mAgencyType:SQLProvider.DatabaseType = .eBus
    
    // Zip Data
    var mZipDataFile = ""
    var mArchive:ZipLoader!
    
    // Database Folder
    var mMainDatabaseFolder = ""
    var mFavoritesDatabaseFolder = ""
    var mGtfsDatabaseFolder = ""
    
    // Agency Database
    var mMainDatabase = ""
    var mFavoritesDatabase =  ""
    var mGtfsDatabase = ""
    // DB file
    var mGtfsRoute = ""
    var mGtfsStop  = ""
    var mGtfsTrip = ""
    var mGtfsTripStop = ""
    var mGtfsServiceDate = ""
    
    
    // Agency Default Color
    var mAgencyDefaultColor = ""
    
    // Agency file format
    var mStopScheduleRaw = ""
    var mStopScheduleFolder = ""
    
    var mJsonAlertEn = ""
    var mJsonAlertFr = ""
    
    // Location
    var mLatitude = 45.5088400
    var mLongitude = -73.5878100
    
    // Alert
    var mAlertMessageFr = ""
    var mAlertMessageEn = ""
    
    func getAgencyId() -> Int{
        return mAgencyId
    }
    
    func setZipData () {

        mArchive = ZipLoader(iZipFilePath: getZipDataFile())
    }
    func getZipData () -> ZipLoader{
        
       return mArchive
    }
    
    func setZipDataFile(iFile:String) {
        
        mZipDataFile = iFile
    }
    
    func getZipDataFile () -> String {
        
        return mZipDataFile
    }
    
    func closeZipData(){
     
        mArchive = nil
    }
    
    func getMainDatabasePath() -> String{

        return mMainDatabaseFolder + "/" + mMainDatabase
    }
    
    func getFavoritesDatabasePath() -> String {
    
        return mFavoritesDatabaseFolder + "/" + mFavoritesDatabase
    }
    
    func getGtfsDatabasePath() -> String {
        
        return mGtfsDatabaseFolder + "/" + mGtfsDatabase
    }
    
     func getAgencyDefaultColor () -> String {
        
        return mAgencyDefaultColor
    }
    
     func getStopScheduleRawfileFormat () -> String {
        
        return mStopScheduleRaw
    }
    
     func getMainFilePath() -> String {
        
        return mStopScheduleFolder
    }
    
     func getLatitude() -> Double {
        
        return mLatitude
    }
    
     func getLongitude() -> Double {
        
        return mLongitude
    }
    
     func getJsonAlertPath() -> String {

        let wLangId = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode)!
        return (wLangId as! String == "fr" ? mJsonAlertFr : mJsonAlertEn)
    }
    
     func getDefaultAlertMessage() -> String{
        
        let wLangId = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode)!
        return (wLangId as! String == "fr" ? mAlertMessageFr : mAlertMessageEn)
    }
    
    
}
