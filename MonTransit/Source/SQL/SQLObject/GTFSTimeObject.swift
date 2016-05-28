//
//  GTFSTimeObject
//  SidebarMenu
//
//  Created by Thibault on 15-12-17.
//  Copyright © 2015 Thibault. All rights reserved.
//

import UIKit

class GTFSTimeObject : NSObject{

    private var mGtfsTime:NSDate
    private var mIsNearest:Bool
    
    override init() {
        
        // get the user's calendar
        let userCalendar = NSCalendar.currentCalendar()
        
        // choose which date and time components are needed
        let requestedComponents: NSCalendarUnit = [
            NSCalendarUnit.Year,
            NSCalendarUnit.Month,
            NSCalendarUnit.Day,
            NSCalendarUnit.Hour,
            NSCalendarUnit.Minute,
            NSCalendarUnit.Second
        ]
        
        // get the components
        let wDate = NSDate().substractDays(1)
        let dateTimeComponents = userCalendar.components(requestedComponents, fromDate: wDate)
        
        // Create date from components
        mGtfsTime = userCalendar.dateFromComponents(dateTimeComponents)!
        mIsNearest = false
    }
    
    init(iGtfsTime:Int, iGtfdDate:Int) {
        
        // convert string time format to hh:mm:ss
        let timeString = String(format: "%06d", iGtfsTime)
        let wHour:Int? = Int(timeString.substringWithRange(timeString.startIndex.advancedBy(0)..<timeString.startIndex.advancedBy(2)))
        let wMinute:Int? = Int(timeString.substringWithRange(timeString.startIndex.advancedBy(2)..<timeString.startIndex.advancedBy(4)))
        let wSecond:Int?   = Int(timeString.substringWithRange(timeString.startIndex.advancedBy(4)..<timeString.startIndex.advancedBy(6)))
        
        // convert string time format to hh:mm:ss
        let dateString = String(format: "%08d", iGtfdDate)
        let wYears:Int? = Int(dateString.substringWithRange(dateString.startIndex.advancedBy(0)..<dateString.startIndex.advancedBy(4)))
        let wMonths:Int? = Int(dateString.substringWithRange(dateString.startIndex.advancedBy(4)..<dateString.startIndex.advancedBy(6)))
        let wDays:Int?   = Int(dateString.substringWithRange(dateString.startIndex.advancedBy(6)..<dateString.startIndex.advancedBy(8)))
        
        // get the user's calendar
        let userCalendar = NSCalendar.currentCalendar()
        
        // choose which date and time components are needed
        let requestedComponents: NSCalendarUnit = [
            NSCalendarUnit.Year,
            NSCalendarUnit.Month,
            NSCalendarUnit.Day,
            NSCalendarUnit.Hour,
            NSCalendarUnit.Minute,
            NSCalendarUnit.Second
        ]
        
        // get the components
        let dateTimeComponents = userCalendar.components(requestedComponents, fromDate: NSDate())
        
        dateTimeComponents.hour = wHour!
        dateTimeComponents.minute = wMinute!
        dateTimeComponents.second = wSecond!
        dateTimeComponents.year = wYears!
        dateTimeComponents.month = wMonths!
        dateTimeComponents.day = wDays!
        
        // Create date from components
        mGtfsTime = userCalendar.dateFromComponents(dateTimeComponents)!
        mIsNearest = false
    }
    
    init(iGtfsDate:Int) {
        
        // convert string time format to hh:mm:ss
        let timeString = String(format: "%08d", iGtfsDate)
        let wYears:Int? = Int(timeString.substringWithRange(timeString.startIndex.advancedBy(0)..<timeString.startIndex.advancedBy(4)))
        let wMonths:Int? = Int(timeString.substringWithRange(timeString.startIndex.advancedBy(4)..<timeString.startIndex.advancedBy(6)))
        let wDays:Int?   = Int(timeString.substringWithRange(timeString.startIndex.advancedBy(6)..<timeString.startIndex.advancedBy(8)))
        
        // get the user's calendar
        let userCalendar = NSCalendar.currentCalendar()
        
        // choose which date and time components are needed
        let requestedComponents: NSCalendarUnit = [
            NSCalendarUnit.Year,
            NSCalendarUnit.Month,
            NSCalendarUnit.Day,
            NSCalendarUnit.Hour,
            NSCalendarUnit.Minute,
            NSCalendarUnit.Second
        ]
        
        // get the components
        let dateTimeComponents = userCalendar.components(requestedComponents, fromDate: NSDate())
        
        dateTimeComponents.year = wYears!
        dateTimeComponents.month = wMonths!
        dateTimeComponents.day = wDays!
        
        // Create date from components
        mGtfsTime = userCalendar.dateFromComponents(dateTimeComponents)!
        mIsNearest = false
    }
    
    func getNSDate() -> NSDate{
        
        return mGtfsTime
    }
    
    func isNearest(iNearest:Bool){
        
        mIsNearest = iNearest
    }
    
    func isNearest() -> Bool{
        
        return mIsNearest
    }
    
}
