//
//  DownloadManager.swift
//  MonTransit
//
//  Created by Thibault on 16-05-31.
//  Copyright © 2016 Thibault. All rights reserved.
//

import UIKit
import MZDownloadManager

class DownloadManager {

    var delegate: MZDownloadManagerDelegate?
    private var mzDownloadManager: MZDownloadManager!
    static let downloadManager = DownloadManager()
    
    private init() {
        
        mzDownloadManager = {
            [unowned self] in
            let sessionIdentifer: String = "com.iosDevelopment.MZDownloadManager.BackgroundSession"
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let completion = appDelegate.backgroundSessionCompletionHandler
            
            let downloadmanager = MZDownloadManager(session: sessionIdentifer, delegate: self.delegate!, completion: completion)
            return downloadmanager
            }()
    }

    func getDownloader() -> MZDownloadManager { return mzDownloadManager }
}
