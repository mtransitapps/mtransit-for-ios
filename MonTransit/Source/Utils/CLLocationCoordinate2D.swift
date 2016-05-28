//
//  CLLocationCoordinate2D.swift
//  MonTransit
//
//  Created by Thibault on 16-01-18.
//  Copyright © 2016 Thibault. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D {
    
    func distanceInMetersFrom(otherCoord : CLLocationCoordinate2D) -> CLLocationDistance {
        let firstLoc = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let secondLoc = CLLocation(latitude: otherCoord.latitude, longitude: otherCoord.longitude)
        return firstLoc.distanceFromLocation(secondLoc)
    }
    
}


extension Double{
    
    var roundedTwoDigit:Double{
        
        return Double(round(100*self)/100)
        
    }
    
    func positionChange(iOherDistance: Double, iTolerance: Int) -> Bool {
        
        
        let wDiff = abs(Int(self - iOherDistance))
        return wDiff > iTolerance ? true : false
    }
}

class Absolute {
    
    static func absFloat(iDouble:Double) -> Double
    {
        return abs(iDouble)
    }
}