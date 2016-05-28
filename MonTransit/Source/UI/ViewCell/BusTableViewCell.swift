//
//  NewsTableViewCell.swift
//  SidebarMenu
//

import UIKit

class BusTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postTitleLabel:UILabel!
    @IBOutlet weak var busColor:UILabel!
    @IBOutlet weak var metroImage:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func addBusNumber(iBusNumber:String, iColor:String ) {
        
        busColor.backgroundColor =  ColorUtils.hexStringToUIColor(iColor)

        if iBusNumber == ""
        {
            self.metroImage.image = UIImage(named: "subway_icn")
        }
        else
        {
            busColor.text = iBusNumber
        }
    }

}
