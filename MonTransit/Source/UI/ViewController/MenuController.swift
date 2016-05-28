//
//  MenuController.swift
//  SidebarMenu
//

import UIKit

class MenuController: UITableViewController {
    @IBOutlet weak var resizeView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = true

       resizeView.frame.size = CGSize(width: resizeView.frame.width, height:  UIScreen.mainScreen().bounds.height - 44*8 - 20)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "BusSegue") {
            
            AgencyManager.setCurrentAgency(0)
        }
        else if (segue.identifier == "MetroSegue"){
            
            AgencyManager.setCurrentAgency(1)
        }
        else if (segue.identifier == "TrainSegue"){
            
           AgencyManager.setCurrentAgency(2)
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        if selectedCell.reuseIdentifier == "UpdateId" {
            
            UpdateDialogView().show(NSLocalizedString("Update", comment: "Title"),
                                    doneButtonTitle: NSLocalizedString("UpdateKey", comment: "Update"),
                                    cancelButtonTitle: NSLocalizedString("CancelKey", comment: "Cancel")) {
                                        (date) -> Void in
                                         
            }
        }

    }
    
}

extension UIViewController: SWRevealViewControllerDelegate
{
    public func revealController(revealController: SWRevealViewController!, willMoveToPosition position: FrontViewPosition) {
        
        self.clearAllNotice()
        let tagId = 42078
        
        if revealController.frontViewPosition == FrontViewPosition.Right {
            let lock = self.view.viewWithTag(tagId)
            UIView.animateWithDuration(0.3, animations: {
                lock?.alpha = 0.0
                }, completion: {(finished: Bool) in
                    lock?.removeFromSuperview()
                    //self.tableView.scrollEnabled = true
            })
        } else if revealController.frontViewPosition == FrontViewPosition.Left {
            let lock = UIView(frame: self.view.bounds)
            lock.autoresizingMask = UIViewAutoresizing.FlexibleWidth//UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
            lock.tag = tagId
            lock.alpha = 0
            lock.backgroundColor = UIColor.blackColor()
            lock.addGestureRecognizer(UITapGestureRecognizer(target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:))))
            self.view.addSubview(lock)
            UIView.animateWithDuration(0.3, animations: {
                lock.alpha = 0.5
                }
            )
            //self.tableView.scrollEnabled = false
        }
    }
    
}