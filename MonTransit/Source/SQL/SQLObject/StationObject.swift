//
//  StationObject.swift
//  SidebarMenu
//
//  Created by Thibault on 15-12-17.
//  Copyright © 2015 Thibault. All rights reserved.
//

import UIKit
import CoreLocation

class StationObject: NSObject {
    
    private var mId:Int
    private var mCode:String
    private var mTitle:String
    private var mLongitude:Double
    private var mLatitude:Double
    private var mDecentOnly:Int
    private var mIsNearest:Bool
    
    override init() {
        
        mId = 0
        mCode = ""
        mTitle = ""
        mLongitude = 0.0
        mLatitude  = 0.0
        mDecentOnly = 0
        mIsNearest = false
    }
    
    init(iId:Int, iCode:String, iTitle:String, iLongitude:Double, iLatitude:Double, iDecentOnly:Int) {
        
        self.mId = iId
        self.mCode = iCode
        self.mTitle = iTitle
        self.mLongitude = iLongitude
        self.mLatitude  = iLatitude
        self.mDecentOnly = iDecentOnly
        self.mIsNearest = false
    }
    
    func getStationId() -> Int{
        return self.mId
    }
    
    func getStationCode() -> String{
        return self.mCode
    }
    
    func getStationTitle() -> String{
        return self.mTitle
    }
    
    func getStationLongitude() -> Double{
        return self.mLongitude
    }
    
    func getStationLatitude() -> Double{
        return self.mLatitude
    }
    
    func getDecentOnly() -> Int{
        return self.mDecentOnly
    }
    
    func setStationNearest(){
        return self.mIsNearest = true
    }
    func getStationNearest() -> Bool{
        return self.mIsNearest
    }
    
    func distanceToUserInMeter(iUserLocation:CLLocation) -> Int {
        
        return Int(iUserLocation.coordinate.distanceInMetersFrom(CLLocationCoordinate2D(latitude: self.getStationLatitude(), longitude: self.getStationLongitude())))
    }
    
    func distanceToUser(iUserLocation:CLLocation) -> String {
        
        var wDistanceString = ""
        var wDistanteTo:Double = iUserLocation.coordinate.distanceInMetersFrom(CLLocationCoordinate2D(latitude: self.getStationLatitude(), longitude: self.getStationLongitude()))
        
        if wDistanteTo > 1000{
            wDistanteTo = wDistanteTo / 1000
            wDistanteTo = wDistanteTo.roundedTwoDigit
            wDistanceString = String(wDistanteTo) + " km"
        }
        else{
            wDistanceString = String(Int(wDistanteTo)) + " m"
        }
        
        return wDistanceString
    }

}
