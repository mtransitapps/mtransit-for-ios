//
//  File.swift
//  MonTransit
//
//  Created by Thibault on 16-01-07.
//  Copyright © 2016 Thibault. All rights reserved.
//

import Foundation

class File {
    class func open(path: String, encoding: NSStringEncoding = NSUTF8StringEncoding) -> String? {
        
        if NSFileManager().fileExistsAtPath(path) {
            do {
                return try String(contentsOfFile: path, encoding: encoding)
            } catch let error as NSError {
                print(error.code)
                return nil
            }
        }
        return  nil
    }
    class func save(path: String, content: String, encoding: NSStringEncoding = NSUTF8StringEncoding) -> Bool {
        do {
            try content.writeToFile(path, atomically: true, encoding: encoding)
            return true
        } catch let error as NSError {
            print(error.code)
            return false
        }
    }
    
    class func copy(sourcePath: String, destinationPath: String) -> Bool{
        
        if NSFileManager().fileExistsAtPath(sourcePath) {
            do {
                try NSFileManager().copyItemAtPath(sourcePath, toPath: destinationPath)
                return true
                
            } catch let error as NSError {
                
                print(error.code)
                return false
            }
        }
        return false
    }
    
    class func move(sourcePath: String, destinationPath: String, delete: Bool = false) -> Bool{

        if delete && NSFileManager().fileExistsAtPath(destinationPath) {
            File.delete(destinationPath)
        }
        
        if NSFileManager().fileExistsAtPath(sourcePath) {
            do {
                try NSFileManager().moveItemAtPath(sourcePath, toPath: destinationPath)
                return true
                
            } catch let error as NSError {
                
                print(error.code)
                return false
            }
        }
        return false
    }
    
    class func createDirectory(path:String) {
    
        if !File.documentFileExist(path){
            let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
            let documentsDirectory: AnyObject = paths[0]
            
            let dataPath = documentsDirectory.stringByAppendingPathComponent(path)
            
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(dataPath, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
    }
    
    class func delete(path: String) -> Bool {
        do {
            try NSFileManager().removeItemAtPath(path)
            return true
        } catch let error as NSError {
            print(error.code)
            return false
        }
    }
    
    class func deleteContentsOfFolder(path: String)
    {
        if let enumerator = NSFileManager.defaultManager().enumeratorAtPath(path) {
            while let fileName = enumerator.nextObject() as? String {
                do {
                    try NSFileManager.defaultManager().removeItemAtPath("\(path)\(fileName)")
                }
                catch let e as NSError {
                    print(e)
                }
                catch {
                    print("error")
                }
            }
        }
    }
    
    class func getBundleFilePath(iFileName:String, iOfType:String) -> String? {
        
        guard let path = NSBundle.mainBundle().pathForResource(iFileName, ofType: iOfType) else {
            return ""
        }
        return path
        
    }
    
    class func documentFileExist(iFileName:String) -> Bool {
        
        let wPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        let wgetFileNamePath = "\(wPaths)/\(iFileName)"
        let wCheckValidation = NSFileManager.defaultManager()
        
        return (wCheckValidation.fileExistsAtPath(wgetFileNamePath))
    }
    
    class func getDocumentFilePath() -> String {
        
        return "\(NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!)/"
    }
    
    class func getDocumentTempFolderPath() -> String {
        
        let wPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! + "/temporary/"
        return wPath
    }
    
    class func getDocumentDownloadFolderPath() -> String {
        
        let wPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! + "/download/"
        return wPath
    }
}

extension NSBundle {
    
    var releaseVersionNumber: String? {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildVersionNumber: String? {
        return self.infoDictionary?["CFBundleVersion"] as? String
    }
    
}