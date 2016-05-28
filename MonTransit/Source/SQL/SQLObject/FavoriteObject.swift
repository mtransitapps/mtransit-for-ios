//
//  FavoriteObject.swift
//  MonTransit
//
//  Created by Thibault on 16-01-20.
//  Copyright © 2016 Thibault. All rights reserved.
//

import UIKit

class FavoriteObject: NSObject {
    
    private var mId:Int!
    private var mAgencyId:Int!
    private var mRouteId:Int!
    private var mTripId:Int!
    private var mStopId:Int!
    private var mFolderId:Int!
    
    private var mRelatedBus:BusObject!
    private var mRelatedTrip:TripObject!
    private var mRelatedStation:StationObject!
    private var mRelatedGtfs:[GTFSTimeObject]?
    
    private var mProviderType:SQLProvider.DatabaseType
    
    override init() {
        
        mId = 0
        mAgencyId = 0
        mRouteId = 0
        mTripId = 0
        mStopId = 0
        mFolderId = 0
        
        mRelatedBus = BusObject()
        mRelatedTrip = TripObject()
        mRelatedStation = StationObject()
        mRelatedGtfs = nil

        
        mProviderType = .eBus
    }
    
    init(iId:Int, iRouteId:Int, iTripId:Int, iStopId:Int, iFolderId:Int, iProviderType:SQLProvider.DatabaseType, iAgencyId:Int) {
        
        self.mId = iId
        self.mRouteId = iRouteId
        self.mTripId = iTripId
        self.mStopId = iStopId
        self.mFolderId = iFolderId
        
        mRelatedBus = BusObject()
        mRelatedTrip = TripObject()
        mRelatedStation = StationObject()
        mRelatedGtfs = nil
        
        mProviderType = iProviderType
        mAgencyId = iAgencyId
    }
    
    func getFavoriteId() -> Int{
        return self.mId
    }
    
    func getRouteId() -> Int{
        return self.mRouteId
    }
    
    func getTripId() -> Int{
        return self.mTripId
    }
    
    func getStopId() -> Int{
        return self.mStopId
    }
    
    func getFolderId() -> Int{
        return self.mFolderId
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
    
    func getAgencyId() -> Int{
        return self.mAgencyId
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
    
    func setRelatedGtfs(iGtfs:[GTFSTimeObject]!){
        self.mRelatedGtfs = iGtfs
    }
    
    func getRelatedDatabaseType() -> SQLProvider.DatabaseType!{
        return mProviderType
    }
    
    func setRelatedDatabaseType(iType:SQLProvider.DatabaseType){
        self.mProviderType = iType
    }
    
}

