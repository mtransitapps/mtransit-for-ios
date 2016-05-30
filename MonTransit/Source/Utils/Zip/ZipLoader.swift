//
//  ZipLoader.swift
//  MonTransit
//
//  Created by Thibault on 16-02-06.
//  Copyright © 2016 Thibault. All rights reserved.
//

import UIKit
import zipzap

class ZipLoader {

    private var mArchive:ZZArchive!
    
    init(iZipFilePath:String) {

        let wUrl = NSURL(fileURLWithPath: File.getDocumentTempFolderPath() + "\(iZipFilePath).zip")
        mArchive = try! ZZArchive(URL: wUrl)
    }
    
    deinit {
    
        mArchive = nil
    }
    
    func getDataFileFromZip(iFileName:String, iDocumentName:String, iSaveExtractedFile:Bool = false) -> String{
        
        for wFile in mArchive.entries{
            
            if wFile.fileName == "\(iDocumentName)/\(iFileName)"{
                var wData:NSData
                wData = try! wFile.newData()
                
                let wDataString = NSString(data: wData, encoding:NSUTF8StringEncoding) as! String
                if(iSaveExtractedFile){
                    File.createDirectory("\(iDocumentName)")
                    File.save(File.getDocumentFilePath() + "\(iDocumentName)/\(iFileName)", content: wDataString)
                }
                
                return NSString(data: wData, encoding:NSUTF8StringEncoding) as! String
            }
        }
        return ""
    }
}
