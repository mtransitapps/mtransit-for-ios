//
//  StmBusAgency.swift
//  MonTransit
//
//  Created by Thibault on 16-01-21.
//  Copyright © 2016 Thibault. All rights reserved.
//

import UIKit

class Agency:NSObject, AgencyProtocol {
    
    var mDisplayIAds = true
    
    // Agency ID
    var mAgencyId:Int = 1
    
    // Agency Name
    var mAgencyName:String = "Bus"
    
    // Agency Type
    var mAgencyType:SQLProvider.DatabaseType = .eBus
    
    // Zip Data
    var mZipDataFile = "StmData"
    var mArchive:ZipLoader!
    
    // Database Folder
    var mMainDatabaseFolder = "mainDatabase"
    var mFavoritesDatabaseFolder = "favoritesDatabase"
    var mGtfsDatabaseFolder = "gtfsDatabase"
    
    // Agency Database
    var mMainDatabase = "ca_montreal_stm_bus.db"
    var mFavoritesDatabase =  "ca_montreal_stm_bus_favorites.db"
    var mGtfsDatabase = "ca_montreal_stm_bus_gtfs.db"
    // DB file
    var mGtfsRoute = "gtfs_rts_routes"
    var mGtfsStop  = "gtfs_rts_stops"
    var mGtfsTrip = "gtfs_rts_trips"
    var mGtfsTripStop = "gtfs_rts_trip_stops"
    var mGtfsServiceDate = "gtfs_schedule_service_dates"
    
    
    // Agency Default Color
    var mAgencyDefaultColor = "009EE0"
    
    // Agency file format
    var mStopScheduleRaw = "gtfs_schedule_stop_"
    var mStopScheduleFolder = "ca_montreal_bus_gtfs"
    
    var mJsonAlertEn = "https://www.stm.info/en/ajax/etats-du-service"
    var mJsonAlertFr = "https://www.stm.info/fr/ajax/etats-du-service"
    
    // Location
    var mLatitude = 45.5088400
    var mLongitude = -73.5878100
    
    // Alert
    var mAlertMessageFr = "Service normal du métro"
    var mAlertMessageEn = "Normal métro service"
    
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
