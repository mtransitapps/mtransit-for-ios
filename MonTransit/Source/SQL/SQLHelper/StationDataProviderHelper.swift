//
//  StationDataProviderHelper.swift
//  SidebarMenu
//
//  Created by Thibault on 15-12-18.
//  Copyright © 2015 Thibault. All rights reserved.
//

import UIKit
import SQLite

class StationDataProviderHelper {
    
    private let station = Table("stop")
    private let trip_stations = Table("trip_stops")
    
    private let id = Expression<Int>("_id")
    private let trip_id = Expression<Int>("trip_id")
    private let stop_id = Expression<Int>("stop_id")
    private let station_sequence = Expression<Int>("stop_sequence")
    private let decent_only = Expression<Int>("decent_only")
    private let station_code = Expression<String>("code")
    private let station_name = Expression<String>("name")
    private let station_latitude = Expression<Double>("lat")
    private let station_longitude = Expression<Double>("lng")
    
    init()
    {
    }
    
    func createStops(iAgency:AgencyProtocol, iSqlCOnnection:Connection) -> Bool
    {
        do {
            let wStopRawType = iAgency.getMainFilePath()
            let wFileText = iAgency.getZipData().getDataFileFromZip(iAgency.mGtfsStop, iDocumentName: wStopRawType)
            
            if wFileText != ""
            {
                let wStops = wFileText.stringByReplacingOccurrencesOfString("'", withString: "").componentsSeparatedByString("\n")
                
                let docsTrans = try iSqlCOnnection.prepare("INSERT INTO STOP (_id, code, name, lat, lng) VALUES (?,?,?,?,?)")
                
                try iSqlCOnnection.transaction(.Deferred) { () -> Void in
                    for wStop in wStops
                    {
                        let wStopFormated = wStop.componentsSeparatedByString(",")
                        
                        if wStopFormated.count == 5{
                            try docsTrans.run(Int(wStopFormated[0])!, wStopFormated[1], wStopFormated[2], Double(wStopFormated[3])!, Double(wStopFormated[4])!)
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
    
    func createTripStops(iAgency:AgencyProtocol, iSqlCOnnection:Connection) -> Bool
    {
        do {
            let wTripStopRawType = iAgency.getMainFilePath()
            let wFileText = iAgency.getZipData().getDataFileFromZip(iAgency.mGtfsTripStop, iDocumentName: wTripStopRawType)
            
            if wFileText != ""
            {
                let wTripStops = wFileText.stringByReplacingOccurrencesOfString("'", withString: "").componentsSeparatedByString("\n")
                
                let docsTrans = try iSqlCOnnection.prepare("INSERT INTO TRIP_STOPS (trip_id, stop_id, stop_sequence, decent_only) VALUES (?,?,?,?)")
                
                try iSqlCOnnection.transaction(.Deferred) { () -> Void in
                    for wTripStop in wTripStops
                    {
                        let wTripStopFormated = wTripStop.componentsSeparatedByString(",")
                        
                        if wTripStopFormated.count == 4{
                            try docsTrans.run(Int(wTripStopFormated[0])!, Int(wTripStopFormated[1])!, Int(wTripStopFormated[2])!, Int(wTripStopFormated[3])!)
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
    
    func retrieveAllStations(iId:Int) -> [StationObject]
    {
        var  wStationsList = [StationObject]()
        
        let wStations = try! SQLProvider.sqlProvider.mainDatabase(iId).prepare(station)

        for wStation in wStations
        {
            wStationsList.append(StationObject(iId: wStation[self.id] ,iCode: wStation[self.station_code], iTitle: wStation[self.station_name], iLongitude: wStation[self.station_longitude], iLatitude: wStation[self.station_latitude], iDecentOnly: 0))
        }

        
        return wStationsList
    }
    
    func retrieveStations(iTripId:Int, iId:Int) -> [StationObject]
    {
        var  wStationsList = [StationObject]()
        
        let wStations = try! SQLProvider.sqlProvider.mainDatabase(iId).prepare(station.join(trip_stations, on: station[id] == trip_stations[stop_id]).filter(iTripId == trip_stations[trip_id]).order(station_sequence))
        
        for wStation in wStations
        {
            wStationsList.append(StationObject(iId: wStation[station[id]] ,iCode: wStation[station_code], iTitle: wStation[station_name], iLongitude: wStation[station_longitude], iLatitude: wStation[station_latitude], iDecentOnly: wStation[decent_only]))
        }
        
        return wStationsList
    }
    
    func retrieveStationById(iStopId:Int, iTripId:Int, iId:Int) -> StationObject
    {
        let wStations = try! SQLProvider.sqlProvider.mainDatabase(iId).prepare(station.join(trip_stations, on: station[id] == trip_stations[stop_id]).filter(station[id] == iStopId && trip_stations[trip_id] == iTripId))
        for wStation in wStations
        {
            return StationObject(iId: wStation[station[id]] ,iCode: wStation[station_code], iTitle: wStation[station_name], iLongitude: wStation[station_longitude], iLatitude: wStation[station_latitude], iDecentOnly: wStation[self.decent_only])
        }
        return StationObject()
    }
    
    func retrieveClosestStations(iLatitude:Double, iLongitude:Double, iDistance:Double, iId:Int, iType:SQLProvider.DatabaseType) -> [NearestObject]
    {
        var  wNearestStationsList = [NearestObject]()
        
        let wTripService = TripDataProviderHelper()
        let wBusService = BusDataProviderHelper()

        let wRequete = prepareRequest(iLatitude, iLongitude: iLongitude, range: iDistance)
        let wStations = try! SQLProvider.sqlProvider.mainDatabase(iId).prepare(wRequete)
        
        for wStation in wStations
        {
            if (wStation.count == 5) {
                let wId:Int = Int("\(wStation[0]!)")!
                let wCode = String(wStation[1]!)
                let wTitle = String(wStation[2]!)
                let wLatitude = Double("\(wStation[3]!)")
                let wLongitude = Double("\(wStation[4]!)")
                
                let wStationObj = StationObject(iId: wId ,iCode: wCode, iTitle: wTitle, iLongitude: wLongitude!, iLatitude: wLatitude!, iDecentOnly: 0)
                
                let wTripList = wTripService.retrieveTripByStopId(wStationObj.getStationId(), iId: iId)
                for wTrip in wTripList
                {
                    let wNearest = NearestObject()

                    wNearest.setAgencyId(iId)
                    wNearest.setRelatedStation(wStationObj)
                    wNearest.setRelatedTrip(wTrip)
                    wNearest.setRelatedDatabaseType(iType)
                    wNearestStationsList.append(wNearest)
                }
            }
        }
        
        // Get Bus Object
        for wNearest in wNearestStationsList {
            wNearest.setRelatedBus(wBusService.retrieveRouteById(wNearest.getRelatedTrip().getRouteId(), iId: iId))
        }
        
        return wNearestStationsList
    }
    
    
    func retrieveStationsByStopCode(iStop:StationObject, iId:Int, iType:SQLProvider.DatabaseType) -> [NearestObject]
    {
        
        var wNearestStationsList = [NearestObject]()
        
        let wTripService = TripDataProviderHelper()
        let wBusService = BusDataProviderHelper()
            
        let wTripList = wTripService.retrieveTripByStopId(iStop.getStationId(), iId: iId)
        for wTrip in wTripList
        {
            let wNearest = NearestObject()
            
            wNearest.setRelatedStation(iStop)
            wNearest.setRelatedTrip(wTrip)
            wNearest.setRelatedDatabaseType(iType)
            wNearest.setAgencyId(iId)
            wNearestStationsList.append(wNearest)
        }
        
        // Get Bus Object
        for wNearest in wNearestStationsList {
            wNearest.setRelatedBus(wBusService.retrieveRouteById(wNearest.getRelatedTrip().getRouteId(), iId: iId))
        }
        
        return wNearestStationsList
    }
    
    /**
    * Calculates the end-point from a given source at a given range (meters)
    * and bearing (degrees). This methods uses simple geometry equations to
    * calculate the end-point.
    *
    * @param point
    *            Point of origin
    * @param range
    *            Range in meters
    * @param bearing
    *            Bearing in degrees
    * @return End-point from the source given the desired range and bearing.
    */
    func calculateDerivedPosition(iLatitude:Double, iLongitude:Double, range:Double, bearing:Double) -> CGPoint
    {
        let EarthRadius:Double = 6371000; // m
    
        let latA:Double = DegreesToRadians(iLatitude)
        let lonA:Double = DegreesToRadians(iLongitude)
        let angularDistance:Double = range / EarthRadius
        let trueCourse:Double = DegreesToRadians(bearing)
    
        var lat:Double = asin(sin(latA) * cos(angularDistance) + cos(latA) * sin(angularDistance) * cos(trueCourse))
    
        let dlon:Double = atan2(sin(trueCourse) * sin(angularDistance) * cos(latA), cos(angularDistance) - sin(latA) * sin(lat))
    
        var lon:Double = ((lonA + dlon + M_PI) % (M_PI * 2)) - M_PI
    
        lat = RadiansToDegrees(lat)
        lon = RadiansToDegrees(lon)
        
        let newPoint:CGPoint = CGPoint(x: lat, y: lon)
        
        return newPoint
    
    }
    
    func prepareRequest(iLatitude:Double, iLongitude:Double, range:Double) -> String
    {
        let COL_X = "lat"
        let COL_Y = "lng"
        
        let mult:Double = 1; // mult = 1.1; is more reliable
        let p1:CGPoint = calculateDerivedPosition(iLatitude, iLongitude: iLongitude, range:  mult * range, bearing: 0)
        let p2:CGPoint = calculateDerivedPosition(iLatitude, iLongitude: iLongitude, range:  mult * range, bearing: 90)
        let p3:CGPoint = calculateDerivedPosition(iLatitude, iLongitude: iLongitude, range:  mult * range, bearing: 180)
        let p4:CGPoint = calculateDerivedPosition(iLatitude, iLongitude: iLongitude, range:  mult * range, bearing: 270)
        
        return "SELECT * FROM STOP WHERE " + COL_X + " > " + String(p3.x) + " AND " + COL_X + " < " + String(p1.x) + " AND " + COL_Y + " < " + String(p2.y) + " AND " + COL_Y + " > " + String(p4.y)
    }
    
    func DegreesToRadians (value:Double) -> Double {
        return value * M_PI / 180.0
    }
    
    func RadiansToDegrees (value:Double) -> Double {
        return value * 180.0 / M_PI
    }
}