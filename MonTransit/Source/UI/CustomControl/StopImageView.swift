import UIKit

class StopImageView: UIView {

    func addBusNumber(iBusNumber:String, iDirection:String) {
        
        if iBusNumber == ""
        {
            let wImage:UIImageView = UIImageView(frame: CGRect(x: 6, y: 6, width: self.frame.size.width - 12, height: self.frame.size.height - 12))
            wImage.image = UIImage(named: "subway_icn")
            wImage.contentMode = UIViewContentMode.ScaleAspectFill
            self.insertSubview(wImage, atIndex: 1)
        }
        else
        {
            let headerLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height - 10))
            headerLabel.contentMode = UIViewContentMode.ScaleAspectFill
            headerLabel.textColor = UIColor.whiteColor()
            headerLabel.textAlignment = NSTextAlignment.Center
            headerLabel.text = iBusNumber
            headerLabel.font = UIFont.boldSystemFontOfSize(30.0)
            self.insertSubview(headerLabel, atIndex: 1)
        }
        
        let directionLabel:UILabel = UILabel(frame: CGRect(x: 2, y: self.frame.origin.y - 33, width: self.frame.size.width - 2, height: 20))
        directionLabel.contentMode = UIViewContentMode.ScaleAspectFill
        directionLabel.textColor = UIColor.whiteColor()
        directionLabel.backgroundColor = UIColor.blackColor()
        directionLabel.alpha = 0.5
        directionLabel.textAlignment = NSTextAlignment.Center
        directionLabel.text = iDirection
        directionLabel.font = UIFont.boldSystemFontOfSize(10.0)
        self.insertSubview(directionLabel, atIndex: 2)
    }

    override func awakeFromNib() {
        self.layer.cornerRadius = 10.0
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 3.0
    }
}
