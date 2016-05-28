//
//  XmlParser.swift
//  MonTransit
//
//  Created by Thibault on 16-05-25.
//  Copyright © 2016 Thibault. All rights reserved.
//

import UIKit

class ParserDelegate:NSObject, NSXMLParserDelegate{
    
    init(element:String){
        self.mAgency = Agency()
        self.element = element
        self.mAgencies = []
        super.init()
    }
    
    var element:String
    var mCurrentValue:String!
    var recordingElementValue:Bool=false
    var mAgency:Agency
    var mAgencies:[Agency]

    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
        if elementName==element{
            
            self.mAgency = Agency()
            self.mAgency.mAgencyName = attributeDict["displayName"]!
            recordingElementValue=true
        }
        else{
            mCurrentValue = elementName
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String)
    {
        if recordingElementValue{
            
            switch mCurrentValue {
                case "zipFile":
                    self.mAgency.setZipDataFile(string)
                case "mainDatabaseFolder":
                    self.mAgency.mMainDatabaseFolder = string
                case "favoritesDatabaseFolder":
                    self.mAgency.mFavoritesDatabaseFolder = string
                case "gtfsDatabaseFolder":
                    self.mAgency.mGtfsDatabaseFolder = string
                case "gtfsFolder":
                    self.mAgency.mStopScheduleFolder = string
                case "mainDatabase":
                    self.mAgency.mMainDatabase = string
                case "favoritesDatabase":
                    self.mAgency.mFavoritesDatabase = string
                case "gtfsDatabase":
                    self.mAgency.mGtfsDatabase = string
                case "gtfsRoute":
                    self.mAgency.mGtfsRoute = string
                case "gtfsStop":
                    self.mAgency.mGtfsStop = string
                case "gtfsTrip":
                    self.mAgency.mGtfsTrip = string
                case "gtfsTripStop":
                    self.mAgency.mGtfsTripStop = string
                case "gtfsServiceDate":
                    self.mAgency.mGtfsServiceDate = string
                case "gtfsSchedule":
                    self.mAgency.mStopScheduleRaw = string
                case "jsonenglish":
                    self.mAgency.mJsonAlertEn = string
                case "jsonfrench":
                    self.mAgency.mJsonAlertFr = string
                case "alertenglish":
                    self.mAgency.mAlertMessageEn = string
                case "alertfrench":
                    self.mAgency.mAlertMessageFr = string
                case "latitude":
                    self.mAgency.mLatitude = Double(string)!
                case "longitude":
                    self.mAgency.mLongitude = Double(string)!
                case "agencyDefaultColor":
                    self.mAgency.mAgencyDefaultColor = string
                case "type":
                    self.mAgency.mAgencyType = SQLProvider.DatabaseType(rawValue: Int(string)!)!
                default: break
            }
        }
    }
    
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if elementName==element{
            recordingElementValue=false
            
            self.mAgency.mAgencyId = mAgencies.count
            mAgencies.append(mAgency)
        }
    }
    
}

class XMLParser{
    
    init(xml:String, element:String){
        self.xmlString=xml
        self.parserDelegate=ParserDelegate(element:element)
        mAgencies = []
    }
    
    private var xmlString:String
    var mAgencies:[Agency]
    private var parserDelegate:ParserDelegate
    
    func parse()->Bool{
        let p=NSXMLParser(data: xmlString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
        p.delegate=parserDelegate
        if p.parse(){
            mAgencies = parserDelegate.mAgencies
            return true
        }
        return false
    }
    
    func getAgencies() -> [Agency]{ return mAgencies}
    
}
