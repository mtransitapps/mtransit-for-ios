//
//  PopUpViewControllerSwift.swift
//  NMPopUpView
//
//  Created by Nikos Maounis on 13/9/14.
//  Copyright (c) 2014 Nikos Maounis. All rights reserved.
//

import UIKit
import QuartzCore

@objc public class PopUpViewControllerSwift : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var listHeightConstraint: NSLayoutConstraint!
    
    private var mViewController:UIViewController!
    
    var mNearestList = [NearestObject]()
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.popUpView.layer.cornerRadius = 5
        self.popUpView.layer.shadowOpacity = 0.8
        self.popUpView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        
        self.tableView.registerNib(UINib(nibName: "CustomMapViewCell", bundle: nil), forCellReuseIdentifier: "StopCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        listHeightConstraint.constant = min(CGFloat(mNearestList.count * 58 + 10), (self.view.frame.height - 250))
    }
    
    func showInView(aView: UIViewController!, iNearestList:[NearestObject], animated: Bool)
    {
        self.mViewController = aView
        self.mNearestList = iNearestList
        
        aView.view.addSubview(self.view)
        if animated
        {
            self.showAnimate()
        }
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
        self.view.alpha = 0.0;
        UIView.animateWithDuration(0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animateWithDuration(0.25, animations: {
            self.view.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.view.removeFromSuperview()
                }
        });
    }
    
    @IBAction public func closePopup(sender: AnyObject) {
        self.removeAnimate()
    }
    
    // MARK: - Table view data source
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return mNearestList.count
    }
    
  public   
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("StopCell", forIndexPath: indexPath) as! CustomMapViewCell
        
        if !mNearestList.isEmpty && mNearestList.count > 0
        {
            let wNearest = mNearestList[indexPath.row]
            cell.addNearestarameter(wNearest.getRelatedStation().getStationTitle(), iBusNumber: wNearest.getRelatedBus().getBusNumber(), iDirection: wNearest.getRelatedTrip().getTripDirection(), iColor: wNearest.getRelatedBus().getBusColor(), iDistance: wNearest.getRelatedStation().distanceToUser(AppDelegate().sharedInstance().getUserLocation()))
            cell.setUpNearestComputations(wNearest,iId: wNearest.getAgencyId())

        }
        return cell
    }
    
    
    // Override to support conditional rearranging of the table view.
    public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let stopViewController = mainStoryboard.instantiateViewControllerWithIdentifier("StopViewController") as! StopViewController
        
        stopViewController.mSelectedStation = mNearestList[indexPath.row].getRelatedStation()
        stopViewController.mSelectedBus     = mNearestList[indexPath.row].getRelatedBus()
        stopViewController.mSelectedTrip    = mNearestList[indexPath.row].getRelatedTrip()
        
        self.mViewController.navigationController?.pushViewController(stopViewController, animated: true)
        
        let deselectedCell = tableView.cellForRowAtIndexPath(indexPath)!
        deselectedCell.setSelected(false, animated: true)
    }

}
