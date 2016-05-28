//
//  StationTableViewCell.swift
//  SidebarMenu
//
//  Created by Thibault on 15-12-17.
//

import UIKit

class StationTableViewCell: UITableViewCell {

    @IBOutlet weak var mStationTitleLabel:UILabel!
    @IBOutlet weak var mStationDistance: UILabel!
    @IBOutlet weak var mAlertImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func isNearest(iNearest:Bool)
    {
        if iNearest {
            mStationTitleLabel.font = UIFont.boldSystemFontOfSize(16.0)
            mStationDistance.font = UIFont.boldSystemFontOfSize(11.0)
        }
        else{
            mStationTitleLabel.font = UIFont.systemFontOfSize(16.0)
            mStationDistance.font = UIFont.systemFontOfSize(11.0)
        }
    }
    
    func setAlert(iAlert:Bool)
    {
        if iAlert {
            mAlertImage.hidden = false
        }
        else{
             mAlertImage.hidden = true
        }
    }

}
