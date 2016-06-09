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
    private var mMainDatabase = [Connection!]()
    private var mFavoritesDatabase = [Connection!]()
    private var mGtfsDatabase = [Connection!]()
    
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
                
                File.delete(File.getDocumentFilePath() + wAgency.getMainDatabasePath())
                File.delete(File.getDocumentFilePath() + wAgency.getGtfsDatabasePath())
                
                File.createDirectory(wAgency.mMainDatabaseFolder)
                File.createDirectory(wAgency.mFavoritesDatabaseFolder)
                File.createDirectory(wAgency.mGtfsDatabaseFolder)

                wSuccess = createMainDatabase(wAgency)
                wSuccess = wSuccess && createGtfssDatabase(wAgency)
                
                if !File.documentFileExist(wAgency.getFavoritesDatabasePath()) {
                    wSuccess = wSuccess && createFavoritesDatabase(wAgency)
                }
                else {
                    openFavoriteDatabase(wAgency)
                }
            }
            
            if wSuccess{
                File.save(File.getDocumentFilePath() + NSBundle.mainBundle().releaseVersionNumber!, content: "")
                self.delegate?.databaseCreated?()
            }
            
            print("STOPS: " + String(NSDate().getGtfsFormatTime()))
        }
        else
        {
            for wAgency in AgencyManager.getAgencies(){
                openMainDatabase(wAgency)
                openGtfsDatabase(wAgency)
                openFavoriteDatabase(wAgency)
            }
        }
    }
    
    private func openMainDatabase(iAgency:Agency)
    {
        let wPath = File.getDocumentFilePath()
        let wDbExist = File.documentFileExist(iAgency.getMainDatabasePath())
        
        if  wDbExist
        {
            mMainDatabase.insert(try! Connection("\(wPath)/" + iAgency.getMainDatabasePath()), atIndex: iAgency.getAgencyId())
        }
    }
    
    private func openFavoriteDatabase(iAgency:Agency)
    {
        let wPath = File.getDocumentFilePath()
        let wDbExist = File.documentFileExist(iAgency.getFavoritesDatabasePath())
        
        if  wDbExist
        {
            mFavoritesDatabase.append(try! Connection("\(wPath)/" + iAgency.getFavoritesDatabasePath()))
        }
    }
    
    private func openGtfsDatabase(iAgency:Agency)
    {
        let wPath = File.getDocumentFilePath()
        let wDbExist = File.documentFileExist(iAgency.getGtfsDatabasePath())
        
        if  wDbExist
        {
            mGtfsDatabase.append(try! Connection("\(wPath)/" + iAgency.getGtfsDatabasePath()))
        }
    }
    
    private func createMainDatabase(iAgency:Agency) -> Bool
    {
       let wConnection = try! Connection(File.getDocumentFilePath() + iAgency.getMainDatabasePath())
        
        // create table route
        try! wConnection.run(Table("route").create
        { t in
            t.column(Expression<Int64>("_id"), primaryKey: true)
            t.column(Expression<String>("short_name"))
            t.column(Expression<String>("long_name"))
            t.column(Expression<String>("color"))
        })
        
        // create table stop
        try! wConnection.run(Table("stop").create
        { t in
            t.column(Expression<Int64>("_id"), primaryKey: true)
            t.column(Expression<String>("code"))
            t.column(Expression<String>("name"))
            t.column(Expression<Double>("lat"))
            t.column(Expression<Double>("lng"))
        })
        
        // create table trip
        try! wConnection.run(Table("trip").create
        { t in
            t.column(Expression<Int64>("_id"), primaryKey: true)
            t.column(Expression<Int64>("headsign_type"))
            t.column(Expression<String>("headsign_value"))
            t.column(Expression<Int64>("route_id"))
        })
        
        // create table trip stop
        try! wConnection.run(Table("trip_stops").create
        { t in
            t.column(Expression<Int64>("_id"), primaryKey: .Autoincrement)
            t.column(Expression<Int64>("trip_id"))
            t.column(Expression<Int64>("stop_id"))
            t.column(Expression<Int64>("stop_sequence"))
            t.column(Expression<Int64>("decent_only"))
        })
        
        // create table trip stop
        try! wConnection.run(Table("service_dates").create
        { t in
            t.column(Expression<String>("service_id"))
            t.column(Expression<Int64>("date"))
        })
        
        mMainDatabase.append(wConnection)
        return populateDatabase(iAgency, iSqlConnection: wConnection)
    }
    
    private func createGtfssDatabase(iAgency:Agency) -> Bool
    {
        let wConnection = try! Connection(File.getDocumentFilePath() + iAgency.getGtfsDatabasePath())
        
        // create table
        try! wConnection.run(Table("gtfs").create
            { t in
                t.column(Expression<Int64>("_id"), primaryKey: .Autoincrement)
                t.column(Expression<String>("service_id"))
                t.column(Expression<Int64>("stop_id"))
                t.column(Expression<Int64>("trip_id"))
                t.column(Expression<Int64>("gtfs_time"))
            })
        
        mGtfsDatabase.append(wConnection)
        
        return true
    }
    
    private func createFavoritesDatabase(iAgency:Agency) -> Bool
    {
        let wConnection = try! Connection(File.getDocumentFilePath() + iAgency.getFavoritesDatabasePath())
        
        // create table
        try! wConnection.run(Table("favorite").create
            { t in
                t.column(Expression<Int64>("_id"), primaryKey: .Autoincrement)
                t.column(Expression<Int64>("route_id"))
                t.column(Expression<Int64>("trip_id"))
                t.column(Expression<Int64>("stop_id"))
                t.column(Expression<Int64>("folder_id"))
            })
        
        mFavoritesDatabase.append(wConnection)
        
        return true
    }
    
    private func populateDatabase(iAgency:Agency, iSqlConnection:Connection) -> Bool
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
    
    func closeMainDatabse() {
        
        mMainDatabase.removeAll()
    }
    
    func closefavoriteDatabse(iId:Int) {
        
        mFavoritesDatabase[iId] = nil
    }
    
    func closeGtfsDatabse(iId:Int) {
        
        mGtfsDatabase[iId] = nil
    }
}