//
//  iAdBannerView.swift
//  MonTransit
//
//  Created by Thibault on 16-02-10.
//  Copyright © 2016 Thibault. All rights reserved.
//

import UIKit
import GoogleMobileAds

extension UIViewController: GADBannerViewDelegate
{
    func addIAdBanner()
    {
        if AgencyManager.getAgency().mDisplayIAds{
            
            let adMobUdid = NSLocalizedString("AdMobKey", tableName: "AdMob", value: "ca-app-pub-3940256099942544/2934735716", comment: "")
            
            let bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bannerView)
            
            let widthConstraint = NSLayoutConstraint(item: bannerView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 320)
            view.addConstraint(widthConstraint)
            
            let heightConstraint = NSLayoutConstraint(item: bannerView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 50)
            view.addConstraint(heightConstraint)
            
            let horizontalConstraint = NSLayoutConstraint(item: bannerView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
            view.addConstraint(horizontalConstraint)
            
            let bottomConstraint = NSLayoutConstraint(item: bannerView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
            view.addConstraint(bottomConstraint)
            
            bannerView.adUnitID = adMobUdid
            bannerView.rootViewController = self
            bannerView.delegate = self
            
            bannerView.loadRequest(GADRequest())
            bannerView.hidden = true
        }
    }
    
    public func adViewDidReceiveAd(bannerView: GADBannerView!) {
        
        bannerView.hidden = false
    }
}
