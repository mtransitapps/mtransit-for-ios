//
//  FBAnnotation.swift
//  FBAnnotationClusteringSwift
//
//  Created by Robert Chen on 4/2/15.
//  Copyright (c) 2015 Robert Chen. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import FBAnnotationClusteringSwift

class FBCustomAnnotation : FBAnnotation {
    
    var subtitle: String? = ""
    var station:StationObject!
    var nearest:[NearestObject]!
    var type:SQLProvider.DatabaseType = SQLProvider.DatabaseType.eBus
    var agencyId:Int = 0
}