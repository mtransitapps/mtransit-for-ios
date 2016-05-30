//
//  LoadingViewController.swift
//  MonTransit
//
//  Created by Thibault on 16-02-05.
//  Copyright © 2016 Thibault. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController, DatabaseyDelegate {
    
    @IBOutlet weak var progress: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        //Create temp folder
        createTemporaryFolder()
        
        //copy zip files
        for wAgency in AgencyManager.getAgencies() {
            
            File.copy(File.getBundleFilePath(wAgency.getZipDataFile(), iOfType: "zip")!, destinationPath: File.getDocumentTempFolderPath() + "\(wAgency.getZipDataFile()).zip")
        }
        
        //Load SQLLite Dabase
        SQLProvider.sqlProvider.delegate = self
        SQLProvider.sqlProvider.openDatabase()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createTemporaryFolder() {
        File.createDirectory("temporary")
        do {
            try NSFileManager.defaultManager().addSkipBackupAttributeToItemAtURL(File.getDocumentTempFolderPath())
            
        } catch {
            // Handle error here
            print("Error: \(error)")
        }
    }
    
    func databaseCreated() {
        performSegueWithIdentifier("MainSegue", sender: self)
        SQLProvider.sqlProvider.delegate = nil
    }
    
}
