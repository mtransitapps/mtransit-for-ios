import Foundation
import UIKit
import QuartzCore
import MZDownloadManager

class UpdateDialogView: UIView {
    
    typealias DatePickerCallback = (date: NSDate) -> Void
    
    /* Consts */
    private let kDialogDefaultButtonHeight:       CGFloat = 50
    private let kDialogDefaultButtonSpacerHeight: CGFloat = 1
    private let kDialogCornerRadius:              CGFloat = 7
    private let kDialogDoneButtonTag:             Int     = 1
    
    /* Views */
    private var dialogView:    UIView!
    private var downloadView:  UIView!
    private var titleLabel:    UILabel!
    private var progressLabel: UILabel!
    private var cancelButton:  UIButton!
    private var updateButton:  UIButton!
    private var downloadLabel: UILabel!
    private var waitWheel:     UIActivityIndicatorView!
    private var progressWhell: UIActivityIndicatorView!
    

    /* Download */
    let mUrl = "https://dl.dropboxusercontent.com/u/1035614/StmAgency.zip"
    
    lazy var downloadManager: MZDownloadManager = {
        [unowned self] in
        let sessionIdentifer: String = "com.iosDevelopment.MZDownloadManager.BackgroundSession"
        
        var completion = AppDelegate().sharedInstance().backgroundSessionCompletionHandler
        
        let downloadmanager = MZDownloadManager(session: sessionIdentifer, delegate: self, completion: completion)
        return downloadmanager
        }()
    
    /* Overrides */
    init() {
        super.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.dialogView = createContainerView()
    
        self.dialogView!.layer.shouldRasterize = true
        self.dialogView!.layer.rasterizationScale = UIScreen.mainScreen().scale
    
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
    
        self.dialogView!.layer.opacity = 0.5
        self.dialogView!.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1)
    
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    
        self.addSubview(self.dialogView!)
    }
    
    /* Handle device orientation changes */
    func deviceOrientationDidChange(notification: NSNotification) {
        close() // For now just close it
    }
    
    /* Create the dialog view, and animate opening the dialog */
    func show(title: String, doneButtonTitle: String = "Update", cancelButtonTitle: String = "Cancel", callback: DatePickerCallback) {
        
        setupView()
        processReach()

        self.titleLabel.text = title
        self.cancelButton.setTitle(cancelButtonTitle, forState: .Normal)
        self.updateButton.setTitle(doneButtonTitle, forState: .Normal)
        
        /* */
        UIApplication.sharedApplication().windows.first!.addSubview(self)
        UIApplication.sharedApplication().windows.first!.endEditing(true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DatePickerDialog.deviceOrientationDidChange(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        /* Anim */
        UIView.animateWithDuration(
            0.2,
            delay: 0,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
                self.dialogView!.layer.opacity = 1
                self.dialogView!.layer.transform = CATransform3DMakeScale(1, 1, 1)
            },
            completion: nil
        )
    }
    
    /* Dialog close animation then cleaning and removing the view from the parent */
    private func close() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        let currentTransform = self.dialogView.layer.transform
        
        let startRotation = (self.valueForKeyPath("layer.transform.rotation.z") as? NSNumber) as? Double ?? 0.0
        let rotation = CATransform3DMakeRotation((CGFloat)(-startRotation + M_PI * 270 / 180), 0, 0, 0)
        
        self.dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1))
        self.dialogView.layer.opacity = 1
        
        UIView.animateWithDuration(
            0.2,
            delay: 0,
            options: UIViewAnimationOptions.TransitionNone,
            animations: { () -> Void in
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                self.dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6, 0.6, 1))
                self.dialogView.layer.opacity = 0
            }) { (finished: Bool) -> Void in
                for v in self.subviews {
                    v.removeFromSuperview()
                }
                
                self.removeFromSuperview()
        }
    }
    
    /* Creates the container view here: create the dialog, then add the custom content and buttons */
    private func createContainerView() -> UIView {
        let screenSize = countScreenSize()
        let dialogSize = CGSizeMake(
            300,
            230
                + kDialogDefaultButtonHeight
                + kDialogDefaultButtonSpacerHeight)
        
        // For the black background
        self.frame = CGRectMake(0, 0, screenSize.width, screenSize.height)
        
        // This is the dialog's container; we attach the custom content and the buttons to this one
        let dialogContainer = UIView(frame: CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height))
        
        // First, we style the dialog to match the iOS8 UIAlertView >>>
        let gradient: CAGradientLayer = CAGradientLayer(layer: self.layer)
        gradient.frame = dialogContainer.bounds
        gradient.colors = [UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).CGColor,
            UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).CGColor,
            UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).CGColor]
        
        let cornerRadius = kDialogCornerRadius
        gradient.cornerRadius = cornerRadius
        dialogContainer.layer.insertSublayer(gradient, atIndex: 0)
        
        dialogContainer.layer.cornerRadius = cornerRadius
        dialogContainer.layer.borderColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1).CGColor
        dialogContainer.layer.borderWidth = 1
        dialogContainer.layer.shadowRadius = cornerRadius + 5
        dialogContainer.layer.shadowOpacity = 0.1
        dialogContainer.layer.shadowOffset = CGSizeMake(0 - (cornerRadius + 5) / 2, 0 - (cornerRadius + 5) / 2)
        dialogContainer.layer.shadowColor = UIColor.blackColor().CGColor
        dialogContainer.layer.shadowPath = UIBezierPath(roundedRect: dialogContainer.bounds, cornerRadius: dialogContainer.layer.cornerRadius).CGPath
        
        // There is a line above the button
        let lineView = UIView(frame: CGRectMake(0, dialogContainer.bounds.size.height - kDialogDefaultButtonHeight - kDialogDefaultButtonSpacerHeight, dialogContainer.bounds.size.width, kDialogDefaultButtonSpacerHeight))
        lineView.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        dialogContainer.addSubview(lineView)
        // ˆˆˆ
        
        //Title
        self.titleLabel = UILabel(frame: CGRectMake(10, 10, 280, 30))
        self.titleLabel.textAlignment = NSTextAlignment.Center
        self.titleLabel.font = UIFont.boldSystemFontOfSize(17)
        dialogContainer.addSubview(self.titleLabel)
   
        // There is a line above the title
        let lineTitleView = UIView(frame: CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.height + 10, dialogContainer.bounds.size.width, kDialogDefaultButtonSpacerHeight))
        lineTitleView.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        dialogContainer.addSubview(lineTitleView)
        
        // Download Text
        self.downloadLabel = UILabel(frame: CGRectMake(10, 50, 280, 100))
        self.downloadLabel.textAlignment = NSTextAlignment.Center
        self.downloadLabel.font = UIFont.boldSystemFontOfSize(16)
        self.downloadLabel.numberOfLines = 3
        self.downloadLabel.text = "Check if an update is available... please wait"
        dialogContainer.addSubview(self.downloadLabel)
        
        // Wait wheel
        self.waitWheel = UIActivityIndicatorView(frame: CGRectMake(dialogContainer.bounds.size.width/2 - 10, 150, 20,20))
        self.waitWheel.color = UIColor.blackColor()
        self.waitWheel.startAnimating()
        dialogContainer.addSubview(self.waitWheel)
        
        // Add the buttons
        addButtonsToView(dialogContainer)
        
        addDownloadView(dialogContainer)
        
        return dialogContainer
    }
    
    private func addDownloadView(container: UIView) {
        
        self.downloadView = UIView(frame: CGRect(x: 80, y: 140, width: 280, height: 40))
        progressLabel = UILabel(frame: CGRect(x: 40, y: 0, width: 200, height: 20))
        progressLabel.text = "0%"
        
        progressWhell = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        progressWhell.color = UIColor.blackColor()
        progressWhell.startAnimating()
        
        downloadView.addSubview(progressLabel)
        downloadView.addSubview(progressWhell)
        
        container.addSubview(downloadView)
    }
    
    /* Add buttons to container */
    private func addButtonsToView(container: UIView) {
        let buttonWidth = container.bounds.size.width / 2
        
        self.cancelButton = UIButton(type: UIButtonType.Custom) as UIButton
        self.cancelButton.frame = CGRectMake(
            0,
            container.bounds.size.height - kDialogDefaultButtonHeight,
            buttonWidth,
            kDialogDefaultButtonHeight
        )
        self.cancelButton.setTitleColor(UIColor(red: 0, green: 0.5, blue: 1, alpha: 1), forState: UIControlState.Normal)
        self.cancelButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), forState: UIControlState.Highlighted)
        self.cancelButton.titleLabel!.font = UIFont.boldSystemFontOfSize(14)
        self.cancelButton.layer.cornerRadius = kDialogCornerRadius
        self.cancelButton.addTarget(self, action: #selector(DatePickerDialog.buttonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        container.addSubview(self.cancelButton)
        
        self.updateButton = UIButton(type: UIButtonType.Custom) as UIButton
        self.updateButton.frame = CGRectMake(
            buttonWidth,
            container.bounds.size.height - kDialogDefaultButtonHeight,
            buttonWidth,
            kDialogDefaultButtonHeight
        )
        self.updateButton.tag = kDialogDoneButtonTag
        self.updateButton.setTitleColor(UIColor(red: 0, green: 0.5, blue: 1, alpha: 1), forState: UIControlState.Normal)
        self.updateButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), forState: UIControlState.Highlighted)
        self.updateButton.titleLabel!.font = UIFont.boldSystemFontOfSize(14)
        self.updateButton.layer.cornerRadius = kDialogCornerRadius
        self.updateButton.addTarget(self, action: #selector(DatePickerDialog.buttonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.updateButton.enabled = false
        
        container.addSubview(self.updateButton)
    }
    
    func buttonTapped(sender: UIButton!) {
        if sender.tag == kDialogDoneButtonTag {
            
            let fileURL  : NSString = mUrl as NSString
            var fileName : NSString = fileURL.lastPathComponent
            fileName = MZUtility.getUniqueFileNameWithPath((MZUtility.baseFilePath as NSString).stringByAppendingPathComponent(fileName as String))
            
            downloadManager.addDownloadTask(fileName as String, fileURL: fileURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        }
        else{
        
            close()
        }
    }
    
    /* Helper function: count and return the screen's size */
    func countScreenSize() -> CGSize {
        let screenWidth = UIScreen.mainScreen().applicationFrame.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        return CGSizeMake(screenWidth, screenHeight)
    }
    
    
    /* Connectivity States */
    
    func processReach(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(networkStatusChanged(_:)), name: ReachabilityStatusChangedNotification, object: nil)
        Reach().monitorReachabilityChanges()
    }
    
    func networkStatusChanged(notification: NSNotification) {
        
        var wConnectOn = false
        let status = Reach().connectionStatus()
        switch status {
        case .Unknown, .Offline:
            self.downloadLabel.text = "No internet connections available. Please check your internet connection."
            self.waitWheel.stopAnimating()
        case .Online(.WWAN):
            print("Connected via WWAN")
            wConnectOn = true
        case .Online(.WiFi):
            print("Connected via WiFi")
            wConnectOn = true
        }
        
        if wConnectOn {
            
            self.downloadLabel.text = "An update is available. Do you want to download it now ?"
            self.waitWheel.stopAnimating()
            self.updateButton.enabled = true
        }
    }
}


extension UpdateDialogView : MZDownloadManagerDelegate{
    
    func downloadRequestStarted(downloadModel: MZDownloadModel, index: Int) {
        
        print("Download Started")
    }
    
    func downloadRequestDidPopulatedInterruptedTasks(downloadModels: [MZDownloadModel]) {
    }
    
    func downloadRequestDidUpdateProgress(downloadModel: MZDownloadModel, index: Int) {
        
        print("Progress: \(downloadModel.progress)")
        progressLabel.text = "Downloading: \(Int(downloadModel.progress * 100))%"
    }
    
    func downloadRequestDidPaused(downloadModel: MZDownloadModel, index: Int) {
    }
    
    func downloadRequestDidResumed(downloadModel: MZDownloadModel, index: Int) {
    }
    
    func downloadRequestCanceled(downloadModel: MZDownloadModel, index: Int) {
        
    }
    
    func downloadRequestFinished(downloadModel: MZDownloadModel, index: Int) {
        
        print("Download Finished")
        downloadManager.presentNotificationForDownload("Ok", notifBody: "Download did completed")
        progressWhell.stopAnimating()
        
        let sourceDirectoryPath = (MZUtility.baseFilePath as NSString).stringByAppendingPathComponent(downloadModel.fileName)
        let destDirectoryPath   = File.getDocumentTempFolderPath().stringByAppendingString(downloadModel.fileName)
        
        // close current database connection
        SQLProvider.sqlProvider.closeMainDatabse()
        
        // close zip file
        AgencyManager.getAgencyById(0).closeZipData()
   
        // move new zip data file
        File.move(sourceDirectoryPath, destinationPath: destDirectoryPath, delete: true)
        
        // set zipdata
        AgencyManager.getAgencyById(0).setZipData()
        
        // open database
        SQLProvider.sqlProvider.openDatabase()
        
    }
    
    func downloadRequestDidFailedWithError(error: NSError, downloadModel: MZDownloadModel, index: Int) {
        
    }
}

