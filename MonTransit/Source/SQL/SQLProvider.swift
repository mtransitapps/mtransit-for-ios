//
//  SQLProvider.swift
//  SidebarMenu
//
//  Created by Thibault on 15-12-16.
//  Copyright © 2015 Thibault. All rights reserved.
//

import UIKit
import SQLite

@objc protocol DatabaseyDelegate {
    
    optional func databaseCreated()
}

final class SQLProvider {
    
    enum DatabaseType : Int{
        
        case eBus = 0
        case eSubway = 1
        case eTrain = 2
    }
    
    var delegate: DatabaseyDelegate?
    private var mMainDatabase = [Connection]()
    private var mFavoritesDatabase = [Connection]()
    private var mGtfsDatabase = [Connection]()
    
    static let sqlProvider = SQLProvider()
    
    private init() {
        
    }
    
    func openDatabase()
    {
        if !File.documentFileExist(NSBundle.mainBundle().releaseVersionNumber!)
        {
            print("start: " + String(NSDate().getGtfsFormatTime()))
            var wSuccess:Bool = true
            
            for wAgency in AgencyManager.getAgencies(){
                
                File.deleteContentsOfFolder(File.getDocumentFilePath() + wAgency.mMainDatabaseFolder)
                File.deleteContentsOfFolder(File.getDocumentFilePath() + wAgency.mGtfsDatabaseFolder)
                
                wSuccess = wSuccess && self.createMainDatabase(wAgency)
            }
            
            if wSuccess{
                File.save(File.getDocumentFilePath() + "/" + NSBundle.mainBundle().releaseVersionNumber!, content: "")
                self.delegate?.databaseCreated?()
            }
            
            print("STOPS: " + String(NSDate().getGtfsFormatTime()))
        }
        else
        {
            for wAgency in AgencyManager.getAgencies(){
                openMainDatabase(wAgency)
            }
        }
        
        // Favorites and Gtfs
        for wAgency in AgencyManager.getAgencies(){
            openFavoriteDatabase(wAgency)
            openGtfsDatabase(wAgency)
        }
    }
    
    private func openMainDatabase(iAgency:AgencyProtocol)
    {
        let wPath = File.getDocumentFilePath()
        let wDbExist = File.documentFileExist(iAgency.getMainDatabasePath())
        
        if  wDbExist == true
        {
            mMainDatabase.append(try! Connection("\(wPath)/" + iAgency.getMainDatabasePath()))
        }
    }
    
    private func createMainDatabase(iAgency:AgencyProtocol) -> Bool
    {
        let wPath = File.getDocumentFilePath()
        let wDbExist = File.documentFileExist(iAgency.getMainDatabasePath())
        
        if  wDbExist == true
        {
            File.delete("\(wPath)/" + iAgency.getMainDatabasePath())
        }
        File.createDirectory(iAgency.mMainDatabaseFolder)
        mMainDatabase.append(try! Connection("\(wPath)/" + iAgency.getMainDatabasePath()))
        
        createDatabase(iAgency.getAgencyId())
        return populateDatabase(iAgency, iSqlConnection: mainDatabase(iAgency.getAgencyId()))
    }
    
    private func openFavoriteDatabase(iAgency:AgencyProtocol)
    {
        let wPath = File.getDocumentFilePath()
        let wFavExist = File.documentFileExist(iAgency.getFavoritesDatabasePath())
        
        File.createDirectory(iAgency.mFavoritesDatabaseFolder)
        mFavoritesDatabase.append(try! Connection("\(wPath)/" + iAgency.getFavoritesDatabasePath()))
        
        if  wFavExist == false
        {
            createFavoritesDatabase(iAgency.getAgencyId())
        }
    }
    
    private func openGtfsDatabase(iAgency:AgencyProtocol)
    {
        let wPath = File.getDocumentFilePath()
        let wFavExist = File.documentFileExist(iAgency.getGtfsDatabasePath())
        
        File.createDirectory(iAgency.mGtfsDatabaseFolder)
        mGtfsDatabase.append(try! Connection("\(wPath)/" + iAgency.getGtfsDatabasePath()))
        
        if  wFavExist == false
        {
            createGtfssDatabase(iAgency.getAgencyId())
        }
    }
    
    private func createGtfssDatabase(iId:Int)
    {
        // create table
        try! gtfsDatabase(iId).run(Table("gtfs").create
            { t in
                t.column(Expression<Int64>("_id"), primaryKey: .Autoincrement)
                t.column(Expression<String>("service_id"))
                t.column(Expression<Int64>("stop_id"))
                t.column(Expression<Int64>("trip_id"))
                t.column(Expression<Int64>("gtfs_time"))
            })
    }
    
    private func createFavoritesDatabase(iId:Int)
    {
        // create table
        try! favoriteDatabase(iId).run(Table("favorite").create
        { t in
            t.column(Expression<Int64>("_id"), primaryKey: .Autoincrement)
            t.column(Expression<Int64>("route_id"))
            t.column(Expression<Int64>("trip_id"))
            t.column(Expression<Int64>("stop_id"))
            t.column(Expression<Int64>("folder_id"))
        })
    }
    
    private func createDatabase(iId:Int)
    {
        // create table route
        try! mainDatabase(iId).run(Table("route").create
        { t in
            t.column(Expression<Int64>("_id"), primaryKey: true)
            t.column(Expression<String>("short_name"))
            t.column(Expression<String>("long_name"))
            t.column(Expression<String>("color"))
        })
        
        // create table stop
        try! mainDatabase(iId).run(Table("stop").create
        { t in
            t.column(Expression<Int64>("_id"), primaryKey: true)
            t.column(Expression<String>("code"))
            t.column(Expression<String>("name"))
            t.column(Expression<Double>("lat"))
            t.column(Expression<Double>("lng"))
        })
        
        // create table trip
        try! mainDatabase(iId).run(Table("trip").create
        { t in
            t.column(Expression<Int64>("_id"), primaryKey: true)
            t.column(Expression<Int64>("headsign_type"))
            t.column(Expression<String>("headsign_value"))
            t.column(Expression<Int64>("route_id"))
        })
        
        // create table trip stop
        try! mainDatabase(iId).run(Table("trip_stops").create
        { t in
            t.column(Expression<Int64>("_id"), primaryKey: .Autoincrement)
            t.column(Expression<Int64>("trip_id"))
            t.column(Expression<Int64>("stop_id"))
            t.column(Expression<Int64>("stop_sequence"))
            t.column(Expression<Int64>("decent_only"))
        })
        
        // create table trip stop
        try! mainDatabase(iId).run(Table("service_dates").create
        { t in
            t.column(Expression<String>("service_id"))
            t.column(Expression<Int64>("date"))
        })
    }
    
    private func populateDatabase(iAgency:AgencyProtocol, iSqlConnection:Connection) -> Bool
    {
        var wSuccess:Bool = false

        // route table
        let wBusDataProviderHelper = BusDataProviderHelper()
        wSuccess = wBusDataProviderHelper.createRoutes(iAgency, iSqlCOnnection: iSqlConnection)
        
        let wStationDataProvider = StationDataProviderHelper()
        wSuccess = wSuccess && wStationDataProvider.createStops(iAgency, iSqlCOnnection: iSqlConnection)
        wSuccess = wSuccess && wStationDataProvider.createTripStops(iAgency, iSqlCOnnection: iSqlConnection)
        
        
        let wTripDataProvider = TripDataProviderHelper()
        wSuccess = wSuccess && wTripDataProvider.createTrips(iAgency, iSqlCOnnection: iSqlConnection)
        
        let wServiceDateProvicer = ServiceDateDataProvider()
        wSuccess = wSuccess && wServiceDateProvicer.createServiceDate(iAgency, iSqlCOnnection: iSqlConnection)
        
        return wSuccess
    }
    
    func mainDatabase(iId:Int) -> Connection!
    {
        return mMainDatabase[iId]
    }
    
    func favoriteDatabase(iId:Int) -> Connection!
    {
        return mFavoritesDatabase[iId]
    }
    
    func gtfsDatabase(iId:Int) -> Connection!
    {
        return mGtfsDatabase[iId]
    }
}