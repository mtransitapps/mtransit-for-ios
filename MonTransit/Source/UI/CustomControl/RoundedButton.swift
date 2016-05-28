//
//  RoundedButton.swift
//  MonTransit
//
//  Created by Thibault on 16-01-25.
//  Copyright © 2016 Thibault. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5.0
        self.layer.borderColor = ColorUtils.hexStringToUIColor(AgencyManager.getAgency().getAgencyDefaultColor()).CGColor
        self.layer.borderWidth = 1.0
    }
}
