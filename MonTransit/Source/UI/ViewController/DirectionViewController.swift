//
//  DirectionViewController.swift
//  SidebarMenu
//
//  Created by Thibault on 15-12-18.
//

import UIKit
import GoogleMobileAds
import PagingMenuController

class DirectionViewController: UIViewController, PagingMenuControllerDelegate {

    var mTripList:[TripObject]!
    var mSelectedBus:BusObject!
    
    var firstViewController:StationsViewController!  = nil
    var secondViewController:StationsViewController! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        let wColor:UIColor = ColorUtils.hexStringToUIColor(mSelectedBus.getBusColor())
        
        self.navigationController?.navigationBar.topItem?.title = ""

        firstViewController = self.storyboard?.instantiateViewControllerWithIdentifier("StationsViewController") as! StationsViewController
        secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("StationsViewController") as! StationsViewController
        
        if mTripList != nil && mTripList.count >= 2
        {
            // Configure the Name
            firstViewController.title  = mTripList[0].getTripDirection()
            secondViewController.title = mTripList[1].getTripDirection()
            
            // Configure the Bus List
            firstViewController.mSelectedTrip  = mTripList[0]
            secondViewController.mSelectedTrip = mTripList[1]
            
            firstViewController.mSelectedBus  = mSelectedBus
            secondViewController.mSelectedBus = mSelectedBus
            
        }
        
        // Color and options
        let viewControllers:[UIViewController] = [firstViewController, secondViewController]
        
        let options = PagingMenuOptions()
        options.menuDisplayMode = .SegmentedControl//(widthMode: .Flexible, centerItem: false, scrollingMode: .PagingEnabled)
        options.menuItemMode = .Underline(height: 3, color: UIColor.whiteColor(), horizontalPadding: 1, verticalPadding: 1)
        //roptions.animateMenuInTransition = false
        
        options.backgroundColor = wColor
        options.selectedBackgroundColor = wColor
        options.textColor = UIColor.lightGrayColor()
        options.selectedTextColor = UIColor.whiteColor()
        options.selectedFont = UIFont.boldSystemFontOfSize(16)
        options.menuHeight = 40
        
        let pagingMenuController = self.childViewControllers.first as! PagingMenuController
        pagingMenuController.delegate = self
        pagingMenuController.setup(viewControllers, options: options)
        
        self.addIAdBanner()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let wColor:UIColor = ColorUtils.hexStringToUIColor(mSelectedBus.getBusColor())
        
        self.navigationItem.title = String(mSelectedBus.getBusNumber() + " " + mSelectedBus.getBusName()).trunc(15)
        self.navigationController!.navigationBar.barTintColor = wColor
    }
    
    var adRecieved:Bool = false
    override func adViewDidReceiveAd(bannerView: GADBannerView!) {
        super.adViewDidReceiveAd(bannerView)
        if !adRecieved{
            let pagingMenuController = self.childViewControllers.first as! PagingMenuController
            
            var currentRect:CGRect = pagingMenuController.view.frame;
            currentRect.size.height -= CGRectGetHeight(bannerView.frame)
            pagingMenuController.view.frame = currentRect
            
            self.adRecieved = true;
            
            firstViewController.replaceListViewPosition()
            secondViewController.replaceListViewPosition()
        }
    }

}
