//
//  ServiceDateDataProvider.swift
//  MonTransit
//
//  Created by Thibault on 16-01-07.
//  Copyright © 2016 Thibault. All rights reserved.
//

import UIKit
import SQLite

class ServiceDateDataProvider {
    
    private let service_dates = Table("service_dates")
    
    private let service_id = Expression<String>("service_id")
    private let date = Expression<Int>("date")

    
    init()
    {
    }
    
    func createServiceDate(iAgency:Agency, iSqlCOnnection:Connection) -> Bool
    {
        do {
            let wServiceRawType = iAgency.getMainFilePath()
            let wFileText = iAgency.getZipData().getDataFileFromZip(iAgency.mGtfsServiceDate, iDocumentName: wServiceRawType)
            
            if wFileText != ""
            {
                let wServices = wFileText.stringByReplacingOccurrencesOfString("'", withString: "").componentsSeparatedByString("\n")
                
                let docsTrans = try! iSqlCOnnection.prepare("INSERT INTO service_dates (service_id, date) VALUES (?,?)")

                try iSqlCOnnection.transaction {
                    for wService in wServices
                    {
                        let wServiceFormated = wService.componentsSeparatedByString(",")
                        
                        if wServiceFormated.count == 2{
                            try docsTrans.run(wServiceFormated[0], Int(wServiceFormated[1])!)
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
    func retrieveCurrentService(iId:Int) -> [String]
    {
        // get the user's calendar
        let userCalendar = NSCalendar.currentCalendar()
        
        // choose which date and time components are needed
        let requestedComponents: NSCalendarUnit = [
            NSCalendarUnit.Year,
            NSCalendarUnit.Month,
            NSCalendarUnit.Day        ]
        
        // get the components
        let dateTimeComponents = userCalendar.components(requestedComponents, fromDate: NSDate())
        
        let wYear = dateTimeComponents.year
        let wMonth = dateTimeComponents.month
        let wDay = dateTimeComponents.day
        
        //Verify if the current date is in DB
        let wDate = getDatesLimit(iId)
        let wTimeString =  String(format: "%04d", wYear) + String(format: "%02d", wMonth) + String(format: "%02d", wDay)
        var wTimeInt = Int(wTimeString)!
        
        if wDate.max.getNSDate().getDateToInt() < wTimeInt{
            wTimeInt = wDate.max.getNSDate().getDateToInt()
        }
        
        let wServices = try! SQLProvider.sqlProvider.mainDatabase(iId).prepare(service_dates.filter(date == wTimeInt))
        var wCurrentService = [String]()
        
        for wService in wServices
        {
            wCurrentService.append(wService.get(service_id))
        }
        
        return wCurrentService
    }
    
    func retrieveCurrentServiceByDate(iDate:Int, iId:Int) -> [String]
    {
        
        let wServices = try! SQLProvider.sqlProvider.mainDatabase(iId).prepare(service_dates.filter(date == iDate))
        var wCurrentServices = [String]()
        
        for wService in wServices
        {
            wCurrentServices.append(wService.get(service_id))
        }
        
        return wCurrentServices
    }
    
    func getDatesLimit(iId:Int) ->(min:GTFSTimeObject, max:GTFSTimeObject){
        
        var min:GTFSTimeObject!
        var max:GTFSTimeObject!
        var wGtfsList:[GTFSTimeObject] = []
        
        let wServices = try! SQLProvider.sqlProvider.mainDatabase(iId).prepare(service_dates)
        for wService in wServices{
            wGtfsList.append(GTFSTimeObject(iGtfsDate: wService[date]))
        }
        min = wGtfsList.first
        max = wGtfsList.last
        
        return (min,max)
    }
    
}