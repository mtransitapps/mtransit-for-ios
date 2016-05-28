//
//  TripDataProviderHelper.swift
//  SidebarMenu
//
//  Created by Thibault on 15-12-17.
//  Copyright © 2015 Thibault. All rights reserved.
//

import UIKit
import SQLite

class TripDataProviderHelper{

    
    private let trip = Table("trip")
    private let trip_stations = Table("trip_stops")
    
    private let headsign_type = Expression<Int>("headsign_type")
    private let headsign_value = Expression<String>("headsign_value")
    private let id = Expression<Int>("_id")
    private let trip_id = Expression<Int>("trip_id")
    private let stop_id = Expression<Int>("stop_id")
    private let route_id = Expression<Int>("route_id")
    
    init()
    {
    }
    
    func createTrips(iAgency:AgencyProtocol, iSqlCOnnection:Connection) -> Bool
    {
        do {
            let wStopRawType = iAgency.getMainFilePath()
            let wFileText = iAgency.getZipData().getDataFileFromZip(iAgency.mGtfsTrip, iDocumentName: wStopRawType)
            
            if wFileText != ""
            {
                let wStops = wFileText.stringByReplacingOccurrencesOfString("'", withString: "").componentsSeparatedByString("\n")
                
                let docsTrans = try!  iSqlCOnnection.prepare("INSERT INTO TRIP (_id, headsign_type, headsign_value, route_id) VALUES (?,?,?,?)")

                try iSqlCOnnection.transaction {
                    for wStop in wStops
                    {
                        let wTripFormated = wStop.componentsSeparatedByString(",")
                        
                        if wTripFormated.count == 4{
                            try docsTrans.run(Int(wTripFormated[0])!, Int(wTripFormated[1])!, wTripFormated[2], Int(wTripFormated[3])!)
                        }
                    }
                }
            }
            return true
        }
        catch {
            print("insertion failed: \(error)")
            return false
        }
    }
    
    func retrieveTrip(iBusId:Int, iId:Int) -> [TripObject]
    {
        let wTrips = try!  SQLProvider.sqlProvider.mainDatabase(iId).prepare(trip.filter(route_id == iBusId))
        var  wTripList = [TripObject]()
        
        for trip in wTrips
        {
            wTripList.append(TripObject(iTripId: trip[id], iDirection: trip[headsign_value], iRouteId: trip[route_id]))
        }
        
        return wTripList
    }
    
    func retrieveTripById(iTripId:Int, iId:Int) -> TripObject
    {
        let wTrips = try! SQLProvider.sqlProvider.mainDatabase(iId).prepare(trip.filter(id == iTripId))
        for wTrip in wTrips
        {
            return TripObject(iTripId: wTrip[id], iDirection: wTrip[headsign_value], iRouteId: wTrip[route_id])
        }
        return TripObject()
    }
    
    func retrieveTripByStopId(iStopId:Int, iId:Int) -> [TripObject]
    {
        var wTripList = [TripObject]()
        
        let wTrips = try! SQLProvider.sqlProvider.mainDatabase(iId).prepare(trip_stations.filter(stop_id == iStopId).join(trip, on: trip[id] == trip_stations[trip_id]))
        
        for wTrip in wTrips
        {
            wTripList.append(TripObject(iTripId: wTrip[trip_id], iDirection: wTrip[headsign_value], iRouteId: wTrip[route_id]))
        }
        return wTripList
    }
}
