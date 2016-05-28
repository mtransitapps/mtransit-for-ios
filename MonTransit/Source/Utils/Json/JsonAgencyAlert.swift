//
//  JsonAgencyAlert.swift
//  MonTransit
//
//  Created by Thibault on 16-02-03.
//  Copyright © 2016 Thibault. All rights reserved.
//

import UIKit
import SwiftyJSON

@objc protocol AlertAgencyDelegate {

    optional func alertRetrieved()
}

class AgencyAlert{
    
    var id:Int = 0
    var direction:String = ""
    var alert:String = ""
}

class JsonAgencyAlert: NSObject, NSURLConnectionDelegate {

    private var mListAlert = [AgencyAlert]()
    
    var delegate: AlertAgencyDelegate?
    var mData: NSMutableData?
    
    override init() {
        
    }
    func getJsonAlert(iJsonPath:String){
        
        let request = NSURLRequest(URL: NSURL(string: iJsonPath)!)
        let loader = NSURLConnection(request: request, delegate: self, startImmediately: true)
        loader?.start()
    }
    
    func connection(didReceiveResponse: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        self.mData = NSMutableData()
    }
    
    func connection(connection: NSURLConnection!, didReceiveData conData: NSData!) {
        self.mData?.appendData(conData)
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        print(error.description)
    }
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        
        mListAlert.appendContentsOf(processMetroJson())
        mListAlert.appendContentsOf(processBusJson())
        
        delegate?.alertRetrieved?()
    }
    
    private func processMetroJson() -> [AgencyAlert]{
        
        var wListMetroAlert = [AgencyAlert]()
        let json = JSON(data:mData!)
        let metroJson = json["metro"]
        for (_,wMetro):(String,JSON) in metroJson {
            
            let wMetroAlert = AgencyAlert()
            wMetroAlert.id = wMetro["id"].intValue
            wMetroAlert.alert = wMetro["data"]["text"].stringValue
            
            wListMetroAlert.append(wMetroAlert)
        }
        return wListMetroAlert
    }
    
    private func processBusJson() -> [AgencyAlert]{
        
        var wListBusAlert = [AgencyAlert]()
        let json = JSON(data:mData!)
        let busJson = json["bus-interne"]["lignes"][0]
        for (index,wBus):(String,JSON) in busJson {
            
            let wId = Int(index)!
            
            for (_,wInfo):(String,JSON) in wBus {
                
                let wBusAlert = AgencyAlert()

                wBusAlert.id = wId
                wBusAlert.direction = wInfo["direction_name"].stringValue
                wBusAlert.alert = wInfo["text"].stringValue
                
                wListBusAlert.append(wBusAlert)
            }
        }
        return wListBusAlert
    }

    func retrieveAlertById(iId:Int, iDirection:String, iStationId:String) -> [AgencyAlert] {
        
        var wListAlert = [AgencyAlert]()
        
        for wAlert in mListAlert{
            
            if wAlert.id == iId && wAlert.direction.lowercaseString == iDirection.lowercaseString{
                
                if wAlert.alert.lowercaseString.containsString(iStationId.lowercaseString) {
                    wListAlert.insert(wAlert, atIndex: 0)
                }
                else{
                    wListAlert.append(wAlert)
                }
            }
        }
        
        return wListAlert
    }
    
    func retrieveAlertByContainStationId(iId:Int, iDirection:String, iStationId:String) -> Bool {
        
        var wAlertFound = false
        
        for wAlert in mListAlert{
            
            if wAlert.id == iId &&
               wAlert.direction.lowercaseString == iDirection.lowercaseString &&
               wAlert.alert.lowercaseString.containsString(iStationId.lowercaseString)
            {
                wAlertFound = true
                break
            }
        }
        
        return wAlertFound
    }
    
    func getAllAlert() -> [AgencyAlert] {
        return mListAlert
    }
}
