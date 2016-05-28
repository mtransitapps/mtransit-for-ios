//
//  BusObject.swift
//  SidebarMenu
//
//  Created by Thibault on 15-12-16.
//  Copyright © 2015 Thibault. All rights reserved.
//

import UIKit

class BusObject: NSObject {

    private var mBusId:Int!
    private var mBusName:String!
    private var mBusNumber:String!
    private var mBusColor:String!
    
    override init() {
        mBusId = 0
        mBusName = ""
        mBusNumber = ""
        mBusColor = ""
    }
    
    init(iBusId:Int, iBusName:String, iBusNumber:String, iBusColor:String) {
        self.mBusId = iBusId
        self.mBusName = iBusName
        self.mBusNumber = iBusNumber
        self.mBusColor = (iBusColor == "" ? AgencyManager.getAgency().getAgencyDefaultColor() : iBusColor)
    }
    
    func getBusId() -> Int{
        return self.mBusId
    }
    
    func getBusName() -> String{
        return self.mBusName
    }
    
    func getBusNumber() -> String{
        return self.mBusNumber
    }
    
    func getBusColor() -> String{
        return self.mBusColor
    }
}
