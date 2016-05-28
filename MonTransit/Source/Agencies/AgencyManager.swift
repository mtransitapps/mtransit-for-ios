//
//  AgencyManager.swift
//  MonTransit
//
//  Created by Thibault on 16-02-08.
//  Copyright © 2016 Thibault. All rights reserved.
//

import UIKit

class AgencyManager {

    private static var mListOfAgencies:[Agency] = []
    private static var mCurrentAgency:AgencyProtocol!
    
    static func getAgency() -> AgencyProtocol { return mCurrentAgency}
    static func getAgencyById(iAgencyId:Int) -> AgencyProtocol {
        
        for wAgency in mListOfAgencies
        {
            if wAgency.mAgencyId == iAgencyId {
                return wAgency
            }
        }
        return mCurrentAgency
    }
    static func getAgencies() -> [Agency] { return mListOfAgencies}
    
    static func setAgencies(iAgencies:[Agency]) { mListOfAgencies = iAgencies}
    static func setCurrentAgency(iAgencyId:Int)
    {
        for wAgency in mListOfAgencies
        {
            if wAgency.mAgencyId == iAgencyId {
                mCurrentAgency = wAgency
                break
            }
        }
    }
}
