//
//  AgencyManager.swift
//  MonTransit
//
//  Created by Thibault on 16-02-08.
//  Copyright © 2016 Thibault. All rights reserved.
//

import UIKit

protocol AgencyProtocol {
    
    // iAds
    var mDisplayIAds:Bool {get set}
    
    // Agency ID
    var mAgencyId:Int {get set}
    // Agency Name
    var mAgencyName:String {get set}
    
    // Agency Type
    var mAgencyType:SQLProvider.DatabaseType {get set}
    
    // Zip Data
    var mZipDataFile: String {get set}
    var mArchive:ZipLoader! {get}

    // Database Folder
    var mMainDatabaseFolder: String {get set}
    var mFavoritesDatabaseFolder: String {get set}
    var mGtfsDatabaseFolder: String {get set}
    
    // Agency Database
     var mMainDatabase: String {get set}
     var mFavoritesDatabase:String {get set}
     var mGtfsDatabase:String  {get set}
    // DB file
     var mGtfsRoute:String {get set}
     var mGtfsStop:String {get set}
     var mGtfsTrip:String {get set}
     var mGtfsTripStop:String {get set}
     var mGtfsServiceDate:String {get set}


    // Agency Default Color
     var mAgencyDefaultColor:String {get set}

    // Agency file format
     var mStopScheduleRaw:String {get set}
     var mStopScheduleFolder:String {get set}
    
    // JSON Alert
     var mJsonAlertEn:String {get set}
     var mJsonAlertFr:String {get set}

    // Location
     var mLatitude: Double{get set}
     var mLongitude: Double{get set}

    // Alert
     var mAlertMessageFr: String {get set}
     var mAlertMessageEn: String {get set}

     func setZipData ()
     func getZipData () -> ZipLoader
     func setZipDataFile(iFile:String) 
     func getZipDataFile () -> String
     func getAgencyId() -> Int
     func getMainDatabasePath() -> String
     func getFavoritesDatabasePath() -> String
     func getGtfsDatabasePath() -> String
     func getAgencyDefaultColor () -> String
     func getStopScheduleRawfileFormat () -> String
     func getMainFilePath() -> String
     func getLatitude() -> Double
     func getLongitude() -> Double
     func getJsonAlertPath() -> String
     func getDefaultAlertMessage() -> String
}
