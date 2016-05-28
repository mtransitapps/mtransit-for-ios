//
//  NearestObject.swift
//  MonTransit
//
//  Created by Thibault on 16-01-27.
//  Copyright © 2016 Thibault. All rights reserved.
//

import UIKit

class NearestObject: NSObject {
    
    private var mAgencyId:Int!

    private var mRelatedBus:BusObject!
    private var mRelatedTrip:TripObject!
    private var mRelatedStation:StationObject!
    private var mRelatedGtfs:[GTFSTimeObject]?
    
    private var mProviderType:SQLProvider.DatabaseType
    
    override init() {
        
        mAgencyId = 0

        mRelatedBus = BusObject()
        mRelatedTrip = TripObject()
        mRelatedStation = StationObject()
        mRelatedGtfs = nil
        
        mProviderType = .eBus
    }

    func getAgencyId() -> Int{
        return self.mAgencyId
    }
    
    func setAgencyId(iId:Int){
        self.mAgencyId = iId
    }
    
    func getRelatedBus() -> BusObject!{
        return mRelatedBus
    }
    
    func setRelatedBus(iBus:BusObject){
        self.mRelatedBus = iBus
    }
    
    func getRelatedStation() -> StationObject!{
        return mRelatedStation
    }
    
    func setRelatedStation(iStation:StationObject){
        self.mRelatedStation = iStation
    }
    
    func getRelatedTrip() -> TripObject!{
        return mRelatedTrip
    }
    
    func setRelatedTrip(iTrip:TripObject){
        self.mRelatedTrip = iTrip
    }
    
    func getRelatedGtfs() -> [GTFSTimeObject]!{
        return mRelatedGtfs
    }
    
    func setRelatedGtfs(iGtfs:[GTFSTimeObject]){
        self.mRelatedGtfs = iGtfs
    }
    
    func getRelatedDatabaseType() -> SQLProvider.DatabaseType!{
        return mProviderType
    }
    
    func setRelatedDatabaseType(iType:SQLProvider.DatabaseType){
        self.mProviderType = iType
    }
    
}

