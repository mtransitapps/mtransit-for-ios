//
//  NewsTableViewController.swift
//  SidebarMenu
//
//

import UIKit
import SQLite
import GoogleMobileAds

class BusTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var menuButton:UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var marginConstraint: NSLayoutConstraint!
    private var listOfRoute:AnySequence<Row>!
    private var mBusProvider:BusDataProviderHelper!
    private var mTripProvider:TripDataProviderHelper!
    
    private var mSelectedTripList:[TripObject]!
    private var mSelectedBus:BusObject!

    override func viewDidLoad() {
        
        navigationController?.navigationBar.barStyle = .Black;
        
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if revealViewController() != nil {
            
            revealViewController().delegate = self
            revealViewController().rearViewRevealWidth = 180
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().draggableBorderWidth = 100
            
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        mSelectedTripList = [TripObject]()
        mTripProvider = TripDataProviderHelper()
        mBusProvider = BusDataProviderHelper()
        mBusProvider.retrieveRouteName(AgencyManager.getAgency().getAgencyId())
        self.addIAdBanner()
    }
    
    var adRecieved:Bool = false
    
    override func adViewDidReceiveAd(bannerView: GADBannerView!) {
        super.adViewDidReceiveAd(bannerView)
        if (!self.adRecieved)
        {
            marginConstraint.constant = -CGRectGetHeight(bannerView.frame)
            self.adRecieved = true;
        }
    }
    override func viewDidAppear(animated: Bool) {
        
        self.navigationController?.navigationBar.topItem?.title = AgencyManager.getAgency().mAgencyName
        self.navigationController!.navigationBar.barTintColor = ColorUtils.hexStringToUIColor(AgencyManager.getAgency().getAgencyDefaultColor())
        
        //check data outdated
        if self.checkDateLimits(AgencyManager.getAgency().getAgencyId()){
            
            switch AgencyManager.getAgency().mAgencyType {
                case SQLProvider.DatabaseType.eBus:
                    self.displayDataOutdatedPopup("BusDataOutDated")
                case SQLProvider.DatabaseType.eSubway:
                    self.displayDataOutdatedPopup("SubwayDataOutDated")
                case SQLProvider.DatabaseType.eTrain:
                    self.displayDataOutdatedPopup("TrainDataOutDated")
            }
        }
    }
    override func viewWillAppear(animated: Bool) {
        
        self.navigationController?.navigationBar.topItem?.title = AgencyManager.getAgency().mAgencyName
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return mBusProvider.totalRoutes()
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! BusTableViewCell
        
        if mBusProvider.totalRoutes() > indexPath.row{
            let route = mBusProvider.retrieveLongName(indexPath.row)
            
            cell.postTitleLabel.text =  route.wlongName
            cell.addBusNumber(route.wshortName, iColor: (route.iColor == "" ? AgencyManager.getAgency().getAgencyDefaultColor() : route.iColor))
        }
        return cell
    }

    
    // Override to support conditional rearranging of the table view.
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }


    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
      //  var selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
      //  selectedCell.contentView.backgroundColor = UIColor.redColor()
        
        // Get Cell Label
        let indexPath = tableView.indexPathForSelectedRow;
        let wSelectedBus = mBusProvider.retrieveBusAtIndex((indexPath?.row)!)
        
        mSelectedTripList.removeAll()
        mSelectedTripList = mTripProvider.retrieveTrip(wSelectedBus.getBusId(), iId:AgencyManager.getAgency().getAgencyId())
        mSelectedBus = wSelectedBus
        
        performSegueWithIdentifier("StationIdentifier", sender: self)
        
        let deselectedCell = tableView.cellForRowAtIndexPath(indexPath!)!
        deselectedCell.setSelected(false, animated: true)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "StationIdentifier") {
            
            // initialize new view controller and cast it as your view controller
            let viewController = segue.destinationViewController as! DirectionViewController
            viewController.mTripList = mSelectedTripList
            viewController.mSelectedBus = mSelectedBus
        }
    }
}
