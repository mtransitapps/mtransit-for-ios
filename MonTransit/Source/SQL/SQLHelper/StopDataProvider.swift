//
//  StopDataProviderHelper.swift
//  SidebarMenu
//
//  Created by Thibault on 15-12-18.
//  Copyright © 2015 Thibault. All rights reserved.
//

import UIKit
import SQLite

class StopDataProviderHelper {
    
    private let gtfs = Table("gtfs")
    private let service_id = Expression<String>("service_id")
    private let stop_id = Expression<Int>("stop_id")
    private let trip_id = Expression<Int>("trip_id")
    private let gtfs_time = Expression<Int>("gtfs_time")
    
    private let GTFS_SCHEDULE_STOP_FILE_COL_SPLIT_ON = ","
    private let GTFS_SCHEDULE_STOP_FILE_COL_COUNT = 5
    private let GTFS_SCHEDULE_STOP_FILE_COL_TIME_COUNT = 3

    private let GTFS_SCHEDULE_STOP_FILE_COL_SERVICE_IDX = 0
    private let GTFS_SCHEDULE_STOP_FILE_COL_TRIP_IDX = 1
    private let GTFS_SCHEDULE_STOP_FILE_COL_DEPARTURE_IDX = 2
    private let GTFS_SCHEDULE_STOP_FILE_COL_HEADSIGN_TYPE_IDX = 3
    private let GTFS_SCHEDULE_STOP_FILE_COL_HEADSIGN_VALUE_IDX = 4
    
    
    init()
    {
    }
    
    func retrieveGtfsTime(iServiceId:[String], iStationCodeId:Int, iTripId:Int, iId:Int, iDate:Int = NSDate().getDateToInt()) -> [GTFSTimeObject]
    {
        var wListOfGtfsTime = [GTFSTimeObject]()
        
        //check if is already extracted
        
        for wServiceId in iServiceId {
            
            let wSuccess = gtfsTimeExistInDb(wServiceId, iStationCodeId: iStationCodeId, iTripId: iTripId, iId: iId)
            
            if wSuccess
            {
                let wGtfslists = try! SQLProvider.sqlProvider.gtfsDatabase(iId).prepare(gtfs.select(gtfs_time).filter(service_id == wServiceId && stop_id == iStationCodeId && trip_id == iTripId))
                
                for wGtfs in wGtfslists
                {
                    wListOfGtfsTime.append(GTFSTimeObject(iGtfsTime: wGtfs[gtfs_time],iGtfdDate: iDate ))
                }
            }
            else
            {
                print("in File")
                let wStopRawType = AgencyManager.getAgencyById(iId).getMainFilePath()
                let wFilePath = AgencyManager.getAgencyById(iId).getStopScheduleRawfileFormat() + "\(iStationCodeId)"

                let wFileText = AgencyManager.getAgencyById(iId).getZipData().getDataFileFromZip(wFilePath, iDocumentName: wStopRawType)
                if wFileText != ""
                {
                    let wServices = wFileText.stringByReplacingOccurrencesOfString("'", withString: "").componentsSeparatedByString("\n")
                    
                    var wGtfsTimes = [Int]()

                    for wService in wServices
                    {
                        let wGtfs = wService.componentsSeparatedByString(GTFS_SCHEDULE_STOP_FILE_COL_SPLIT_ON)
                        if wGtfs[GTFS_SCHEDULE_STOP_FILE_COL_SERVICE_IDX] == wServiceId && wGtfs[GTFS_SCHEDULE_STOP_FILE_COL_TRIP_IDX] == String(iTripId)
                        {
                            var wCounterGtfs = 0
                            var wPreviousTime = 0
                            while wGtfs.count > (GTFS_SCHEDULE_STOP_FILE_COL_DEPARTURE_IDX + wCounterGtfs)
                            {
                                wPreviousTime += Int(wGtfs[GTFS_SCHEDULE_STOP_FILE_COL_DEPARTURE_IDX + wCounterGtfs])!
                                wListOfGtfsTime.append(GTFSTimeObject(iGtfsTime: wPreviousTime,iGtfdDate: iDate ))
                                wCounterGtfs += GTFS_SCHEDULE_STOP_FILE_COL_TIME_COUNT
                                
                                wGtfsTimes.append(wPreviousTime)
                            }
                            insertGtfsTime(wServiceId, iStationCodeId: iStationCodeId, iTripId: iTripId, iGtfs: wGtfsTimes, iId: iId)
                            break
                        }
                    }
                }
                else
                {
                    print("error reading file")
                }
            }
        }
        wListOfGtfsTime.sortInPlace({$0.getNSDate().timeIntervalSince1970 < $1.getNSDate().timeIntervalSince1970})
        return wListOfGtfsTime
    }
    
    func filterListByTime(iListOfTime:[GTFSTimeObject], iPreviousTime:Int, iAfterTime:Int) -> [GTFSTimeObject]
    {
        var wPreviousGtfsTime = [GTFSTimeObject]()
        var wAfterGtfsTime = [GTFSTimeObject]()
        
        var wListOfGtfsTime = [GTFSTimeObject]()
        
        for wGtfsTime in iListOfTime
        {
            let dueDate = wGtfsTime.getNSDate()
            
            let calendar = NSCalendar.currentCalendar()
            let comps = NSDateComponents()
            
            let date2 = calendar.dateByAddingComponents(comps, toDate: NSDate(), options: NSCalendarOptions())
            
            if dueDate.compare(date2!) == NSComparisonResult.OrderedDescending{
                
                wAfterGtfsTime.append(wGtfsTime)
            } else if dueDate.compare(date2!) == NSComparisonResult.OrderedAscending{
                
                wPreviousGtfsTime.append(wGtfsTime)
            }
        }
        
        wPreviousGtfsTime = wPreviousGtfsTime.reverse()
        if iPreviousTime-1 >= 0{
            for wPrevious in 0...(iPreviousTime-1)
            {
                if wPrevious < wPreviousGtfsTime.count {
                    
                    wListOfGtfsTime.append(wPreviousGtfsTime[wPrevious])
                }
                wListOfGtfsTime = wListOfGtfsTime.reverse()
            }
        }
        
        if (iAfterTime-1) >= 0 {
            for wNext in 0...(iAfterTime-1)
            {
                if wNext < wAfterGtfsTime.count {
                 
                    wListOfGtfsTime.append(wAfterGtfsTime[wNext])
                }
            }                   
        }
        
        return wListOfGtfsTime
    }
    
    func gtfsTimeExistInDb(iServiceId:String, iStationCodeId:Int, iTripId:Int, iId:Int) -> Bool
    {
        let count = SQLProvider.sqlProvider.gtfsDatabase(iId).scalar(gtfs.filter(service_id == iServiceId && stop_id == iStationCodeId && trip_id == iTripId).count)
        
        return (count > 0 ? true : false)
    }

    func insertGtfsTime(iServiceId:String, iStationCodeId:Int, iTripId:Int, iGtfs:[Int], iId:Int)
    {
        do {
            let docsTrans = try! SQLProvider.sqlProvider.gtfsDatabase(iId).prepare("INSERT INTO GTFS (service_id, stop_id, trip_id, gtfs_time) VALUES (?,?,?,?)")
            
            try SQLProvider.sqlProvider.gtfsDatabase(iId).transaction(.Exclusive) { () -> Void in
                for wGtfs in iGtfs
                {
                    try docsTrans.run(iServiceId, Int(iStationCodeId), Int(iTripId), wGtfs)
                }
            }
        }
        catch {
            print("insertion failed: \(error)")
        }
    }
}