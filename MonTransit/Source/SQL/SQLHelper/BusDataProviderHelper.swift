//
//  BusDataProviderHelper.swift
//  SidebarMenu
//
//  Created by Thibault on 15-12-17.
//  Copyright © 2015 Thibault. All rights reserved.
//

import UIKit
import SQLite

class BusDataProviderHelper {

    private let routes = Table("route")
    
    private let id = Expression<Int>("_id")
    private let shortname = Expression<String>("short_name")
    private let longName = Expression<String>("long_name")
    private let color = Expression<String>("color")
    
    private var  busList = [BusObject]()
    
    init()
    {
    }
    
    func createRoutes(iAgency:Agency, iSqlCOnnection:Connection) -> Bool
    {
        do {
            let wStopRawType = iAgency.getMainFilePath()
            let wFileText = iAgency.getZipData().getDataFileFromZip(iAgency.mGtfsRoute, iDocumentName: wStopRawType)
            
            if wFileText != ""
            {
                let wStops = wFileText.stringByReplacingOccurrencesOfString("'", withString: "").componentsSeparatedByString("\n")
                
                let docsTrans = try! iSqlCOnnection.prepare("INSERT INTO ROUTE (_id, short_name, long_name, color) VALUES (?,?,?,?)")
                
                try iSqlCOnnection.transaction(.Deferred) { () -> Void in
                    for wStop in wStops
                    {
                        let wStopFormated = wStop.componentsSeparatedByString(",")
                        
                        if wStopFormated.count == 4{
                            try docsTrans.run(Int(wStopFormated[0])!, wStopFormated[1], wStopFormated[2], wStopFormated[3])
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
    
    func retrieveRouteName(iId:Int)
    {
        let wRoutes = try! SQLProvider.sqlProvider.mainDatabase(iId).prepare(routes)
        for route in wRoutes
        {
            busList.append(BusObject(iBusId: route[id], iBusName: route[longName],iBusNumber: route[shortname],iBusColor: route[color]))
        }
    }
    
    func retrieveRouteById(iRouteId:Int, iId:Int) -> BusObject
    {
        let wRoute = try! SQLProvider.sqlProvider.mainDatabase(iId).prepare(routes.filter(id == iRouteId))
        for route in wRoute
        {
            return BusObject(iBusId: route[id], iBusName: route[longName],iBusNumber: route[shortname],iBusColor: route[color])
        }
        return BusObject()
    }
    
    func retrieveLongName(index:Int) -> (wlongName: String, wshortName: String, iColor: String)
    {
        return (busList[index].getBusName(), busList[index].getBusNumber(), busList[index].getBusColor())
    }
    
    func retrieveBusAtIndex(iBusId:Int) -> BusObject
    {
        return busList[iBusId]
    }
    
    func retrieveBus(iBusId:Int) -> BusObject!
    {
        for wBus in busList
        {
            if wBus.getBusId() == iBusId{
                return wBus
            }
        }
        return nil
    }
    
    func totalRoutes() -> Int
    {
        return busList.count
    }
}
