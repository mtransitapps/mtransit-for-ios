//
//  StopTableViewCell.swift
//  MonTransit
//
//  Created by Thibault on 16-01-08.
//

import UIKit

class StopTableViewCell: UITableViewCell {

    @IBOutlet weak var mTimeBusLabel:UILabel!
    @IBOutlet weak var mDateBusLabel:UILabel!
    
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
        if iNearest{
            mTimeBusLabel.font = UIFont.boldSystemFontOfSize(22.0)
            mDateBusLabel.font = UIFont.boldSystemFontOfSize(14.0)
        }
        else {
            mTimeBusLabel.font = UIFont.systemFontOfSize(16.0)
            mDateBusLabel.font = UIFont.systemFontOfSize(12.0)
        }
    }
}
