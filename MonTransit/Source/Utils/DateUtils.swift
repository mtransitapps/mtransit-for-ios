//
//  DateUtils.swift
//  MonTransit
//
//  Created by Thibault on 16-01-25.
//  Copyright © 2016 Thibault. All rights reserved.
//

import UIKit

extension NSDate {

    static func daysBetweenDate(startDate: NSDate, endDate: NSDate) -> Int
    {
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components([.Day], fromDate: startDate, toDate: endDate, options: [])
        
        return components.day
    }
    
    func getDate() -> String{
        
        let formatter = NSDateFormatter()
        formatter.timeStyle = NSDateFormatterStyle.NoStyle
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        return formatter.stringFromDate(self)
    }
    
    func getTime() -> String{
        
        let formatter = NSDateFormatter()
        formatter.timeStyle = NSDateFormatterStyle.MediumStyle
        formatter.dateStyle = NSDateFormatterStyle.NoStyle
        
        return formatter.stringFromDate(self)
    }
    
    func getHour() -> Int{
        
        let calendar = NSCalendar.currentCalendar()
        let hour = calendar.component(NSCalendarUnit.Hour, fromDate: self)
        
        return hour
    }
    
    func getYear() -> Int{
        
        let calendar = NSCalendar.currentCalendar()
        let year = calendar.component(NSCalendarUnit.Year, fromDate: self)
        
        return year
    }
    
    func getMonth() -> Int{
        
        let calendar = NSCalendar.currentCalendar()
        let month = calendar.component(NSCalendarUnit.Month, fromDate: self)
        
        return month
    }
    
    func getDay() -> Int{
        
        let calendar = NSCalendar.currentCalendar()
        let day = calendar.component(NSCalendarUnit.Day, fromDate: self)
        
        return day
    }
    
    func getGtfsFormatTime() -> String{
        
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
        let dateTimeComponents = userCalendar.components(requestedComponents, fromDate:self)
        
        return String(format: "%02d", dateTimeComponents.hour)
            + String(format: "%02d", dateTimeComponents.minute)
            + String(format: "%02d", dateTimeComponents.second)
    }
    
    func getDateToInt() -> Int{
        
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
        let dateTimeComponents = userCalendar.components(requestedComponents, fromDate: self)
        
        let wDateString = String(format: "%04d", dateTimeComponents.year) + String(format: "%02d", dateTimeComponents.month) + String(format: "%02d", dateTimeComponents.day)
        
        return Int(wDateString)!
    }
    
    func substractDays(iDays:Int) -> NSDate{

        let wNewDate = NSCalendar.currentCalendar().dateByAddingUnit(
            .Day,
            value: -iDays,
            toDate: self,
            options: NSCalendarOptions(rawValue: 0))
        
        return wNewDate!
    }
    
    func getTimeWithFormat(iFormatter:NSDateFormatter) -> String{
        
        return iFormatter.stringFromDate(self)
    }
    
    func getMinutesDiference(iCompareDate:NSDate) -> Int {
        
        let calendar = NSCalendar.currentCalendar()
        let datecomponenets = calendar.components(.Minute, fromDate: iCompareDate, toDate: self, options: [])
        let wDiffMin = datecomponenets.minute

        
        return wDiffMin
    }
}
