//
//  TripObject.swift
//  SidebarMenu
//
//  Created by Thibault on 15-12-17.
//  Copyright © 2015 Thibault. All rights reserved.
//

import UIKit

class TripObject: NSObject {

    private var mTripId:Int!
    private var mDirection:String!
    private var mRouteId:Int!

    override init() {
        mTripId = 0
        mRouteId = 0
        mDirection = ""
    }
    
    init(iTripId:Int, iDirection:String, iRouteId:Int) {
        self.mTripId = iTripId
        self.mDirection = iDirection
        self.mRouteId = iRouteId
    }
    
    func getTripId() -> Int{
        return self.mTripId
    }
    
    func getRouteId() -> Int{
        return self.mRouteId
    }
    
    func getTripDirection() -> String{
        return getDirection(self.mDirection)
    }
    
    private func getDirection(iDirection:String) -> String
    {
        let wLangId = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode)!
        
        var wDirection = ""
        switch iDirection
        {
            case "N":
                wDirection = wLangId as! String == "fr" ? "Nord" : "North"
                break
            case "S":
                wDirection = wLangId as! String == "fr" ? "Sud" : "South"
                break
            case "E":
                wDirection = wLangId as! String == "fr" ? "Est" : "East"
                break
            case "W":
                wDirection = wLangId as! String == "fr" ? "Ouest" : "West"
                break
            default:
                wDirection = iDirection
        }
        return wDirection
    }
    
}
