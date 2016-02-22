//
//  RootViewController.swift
//  CSVUploader
//
//  Created by Xiaohu on 9/25/15.
//  Copyright © 2015 Yanny. All rights reserved.
//

import UIKit
import iAd

class RootViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ADBannerViewDelegate {

    @IBOutlet weak var countField: UITextField!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var csvTableView: UITableView!
    @IBOutlet weak var csvSearchBar: UISearchBar!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var bannerView: ADBannerView!
    
    var postItems: NSMutableArray = [];
    var searchItems: NSMutableArray = [];
    
    var postsCollection = [Post]()
    var service:PostService!
    
    var progressHUD: MBProgressHUD?
    
    var uploadedCount: Int? = 0
    
    
    var settings:Settings!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.settings = Settings()
        
        self.title = "HTS Audit"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        
        self.configureSearchBar()
        
        service = PostService()
        
        self.loadCSVData();
        
        
        // iAd
        // On iOS 6 ADBannerView introduces a new initializer, use it when available.
        if (ADBannerView.instancesRespondToSelector("initWithAdType:")) {
            self.bannerView = ADBannerView(adType:ADAdType.Banner)
        }
        else {
            self.bannerView = ADBannerView()
        }
        self.bannerView.delegate = self
        self.view.addSubview(self.bannerView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.layoutAnimated(false)
    }
    
    override func viewDidLayoutSubviews() {
        self.layoutAnimated(UIView.areAnimationsEnabled())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureSearchBar() {
        self.csvSearchBar.showsCancelButton = true
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.csvSearchBar.text?.characters.count > 0 {
            return self.searchItems.count
        }
        return self.postItems.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier: String? = "CSVCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier!, forIndexPath: indexPath)
        
        var post: NSDictionary? = nil
        if self.csvSearchBar.text?.characters.count > 0 {
            post = self.searchItems[indexPath.row] as? NSDictionary
        }
        else {
            post = self.postItems[indexPath.row] as? NSDictionary
        }
        
//        let htsNumber = post[key_hts_number] as! NSString
//        cell.textLabel?.text = NSString(format: "%d: %@", indexPath.row + 1 as Int, htsNumber) as String
        
        cell.textLabel?.text = post![settings.key_hts_number] as? String
        cell.detailTextLabel?.text = post![settings.key_description] as? String
        cell.detailTextLabel?.numberOfLines = 2

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var info: NSDictionary? = self.postItems[indexPath.row] as? NSDictionary
        if self.csvSearchBar.text?.characters.count > 0 {
            info = self.searchItems[indexPath.row] as? NSDictionary
        }
        
        self.performSegueWithIdentifier(settings.ShowDetailViewController, sender: info)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let identifier: NSString? = segue.identifier
        if (identifier!.isEqualToString(settings.ShowDetailViewController)) {
            let vc: DetailViewController = segue.destinationViewController as! DetailViewController
            vc.info = sender as? NSDictionary
        }
    }

    // MARK: Main methods
    
    @IBAction func tapUploadButton(sender: UIButton) {
        
        self.uploadButton.enabled = false
        
//        if self.postItems.count > 0 {
//            self.postItems.removeAllObjects()
//        }
        self.uploadedCount = 0;
        
        
        // show progress HUD
        self.progressHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.progressHUD!.labelText = "Loading CSV data..."
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
            
//            self.loadCSVData();
            
            dispatch_async(dispatch_get_main_queue()) {
                
                self.csvTableView.reloadData()
                
                self.progressHUD!.labelText = "Uploading CSV data..."
                
                self.uploadProc()
            }
        }
        
        
//        service.getPosts { (response) -> () in
//            self.loadPosts(response["posts"]! as! NSArray)
//        }
    }
    
    func testFunc() {
        
        // test code
        let testItems: NSMutableArray? = NSMutableArray(array: self.postItems)
//        for var i = 0; i < 3000; ++i {
//            testItems?.addObject(postItems[i])
//        }
        
        do {
            let htsData: NSData? = try NSJSONSerialization.dataWithJSONObject(testItems!, options: NSJSONWritingOptions.PrettyPrinted)
            let htsString: NSString? = NSString(data: htsData!, encoding: NSUTF8StringEncoding)
            let bodyString: NSString? = NSString(format: "arr=%@", htsString!)
            print("\n\n\(bodyString)")
        }
        catch {
        }
    }
    
    func uploadProc() {
        
        if self.postItems.count > 0 {
            if (self.uploadedCount < self.postItems.count) {
                
                let uploadItems: NSMutableArray? = NSMutableArray(capacity: 0)
                var uploadBodyData: NSMutableData? = NSMutableData(capacity: 0)
                
                var count: Int = self.postItems.count - self.uploadedCount!
                if (count > 3000) {
                    count = 3000
                }
                
                for var i: Int = 0; i < count; ++i {
                    let item: NSDictionary? = self.postItems[self.uploadedCount! + i] as? NSDictionary
                    if (item == nil) {
                        continue
                    }
                    
                    uploadItems!.addObject(item!)
                }
                
                do {
                    let htsData: NSData? = try NSJSONSerialization.dataWithJSONObject(uploadItems!, options: NSJSONWritingOptions.PrettyPrinted)
                    let bodyData: NSMutableData? = NSMutableData(data: "arr=".dataUsingEncoding(NSUTF8StringEncoding)!)
                    bodyData!.appendData(htsData!)
                    
                    if bodyData?.length >= settings.MAX_UPLOAD_SIZE {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            // hide progress HUD
                            self.progressHUD!.hide(true)
                            
                            self.uploadButton.enabled = true
                            
                            // show result alert
                            let alert: UIAlertController? = UIAlertController(title: "CSV Uploader", message: "Upload data should be less than 1M", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            alert?.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                                
                            }))
                            self.presentViewController(alert!, animated: true, completion: { () -> Void in
                                
                            })
                        })
                        return
                    }
                    
                    uploadBodyData = bodyData
                }
                catch {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        // hide progress HUD
                        self.progressHUD!.hide(true)
                        
                        self.uploadButton.enabled = true
                        
                        // show result alert
                        let alert: UIAlertController? = UIAlertController(title: "CSV Uploader", message: "Parse Error", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        alert?.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                            
                        }))
                        self.presentViewController(alert!, animated: true, completion: { () -> Void in
                            
                        })
                    })
                    return
                }
                
                print("\(uploadBodyData?.length)")
                
                self.service.post(uploadBodyData!, callback: { (response) -> () in
                    print("\(response)")
                    
                    if response.isEqualToString("success") {
                        self.uploadedCount = self.uploadedCount! + uploadItems!.count
                        print("+++++++ Uploaded count = \(uploadItems!.count) : (\(self.uploadedCount) / \(self.postItems.count))")
                        
                        if (self.uploadedCount < self.postItems.count) {
                            self.uploadProc()
                            return
                        }
                    }
                    
                    
                    self.uploadButton.enabled = true
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        // hide progress HUD
                        self.progressHUD!.hide(true)
                        
                        // show result alert
                        let alert: UIAlertController? = UIAlertController(title: "CSV Uploader", message: response as String, preferredStyle: UIAlertControllerStyle.Alert)
                        if response.isEqualToString("success") {
                            alert?.message = "Success to upload CSV data!";
                        }
                        
                        alert?.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                            
                        }))
                        self.presentViewController(alert!, animated: true, completion: { () -> Void in
                            
                        })
                    })
                })
            }
        }
    }
    
    func uploadProcWithCheckingLimit() {
        
        if self.postItems.count > 0 {
            if (self.uploadedCount < self.postItems.count) {
                
                let uploadItems: NSMutableArray? = NSMutableArray(capacity: 0)
                var uploadBodyData: NSMutableData? = NSMutableData(capacity: 0)
                
                for var i: Int = self.uploadedCount!; i < self.postItems.count; ++i {
                    let item: NSDictionary? = self.postItems[i] as? NSDictionary
                    if (item == nil) {
                        continue
                    }
                    
                    uploadItems!.addObject(item!)
                    do {
                        let htsData: NSData? = try NSJSONSerialization.dataWithJSONObject(uploadItems!, options: NSJSONWritingOptions.PrettyPrinted)
                        let bodyData: NSMutableData? = NSMutableData(data: "arr=".dataUsingEncoding(NSUTF8StringEncoding)!)
                        bodyData!.appendData(htsData!)
                        
                        if bodyData?.length < settings.MAX_UPLOAD_SIZE {
                            uploadBodyData = bodyData
                        }
                        else {
                            uploadItems?.removeObject(item!)
                            break
                        }
                    }
                    catch {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            // hide progress HUD
                            self.progressHUD!.hide(true)
                            
                            // show result alert
                            let alert: UIAlertController? = UIAlertController(title: "CSV Uploader", message: "Parse Error", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            alert?.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                                
                            }))
                            self.presentViewController(alert!, animated: true, completion: { () -> Void in
                                
                            })
                        })
                        return
                    }
                }
                
                print("\(uploadBodyData?.length)")
                
                self.service.post(uploadBodyData!, callback: { (response) -> () in
                    print("\(response)")
                    
                    if response.isEqualToString("success") {
                        self.uploadedCount = self.uploadedCount! + uploadItems!.count
                        print("+++++++ Uploaded count = \(uploadItems!.count) : (\(self.uploadedCount) / \(self.postItems.count))")
                        
                        if (self.uploadedCount < self.postItems.count) {
                            self.uploadProc()
                            return
                        }
                    }
                    
                    
                    self.uploadButton.enabled = true
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        // hide progress HUD
                        self.progressHUD!.hide(true)
                        
                        // show result alert
                        let alert: UIAlertController? = UIAlertController(title: "CSV Uploader", message: response as String, preferredStyle: UIAlertControllerStyle.Alert)
                        if response.isEqualToString("success") {
                            alert?.message = "Success to upload CSV data!";
                        }
                        
                        alert?.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                            
                        }))
                        self.presentViewController(alert!, animated: true, completion: { () -> Void in
                            
                        })
                    })
                })
            }
        }
    }
    
    func getString (string:NSString) -> NSString {
        
        var result:NSString = ""
        
        if string.length > 0 {
            result = string.stringByReplacingOccurrencesOfString("\n", withString: "")
//            result = result.stringByReplacingOccurrencesOfString("'", withString: "\'")
            result = result.stringByReplacingOccurrencesOfString("&cent;", withString: "¢")
            result = result.stringByReplacingOccurrencesOfString("&nbsp;", withString: " ")
            result = result.stringByReplacingOccurrencesOfString("&#38;", withString: "#38;")
            result = result.stringByReplacingOccurrencesOfString("&deg;", withString: "˚")
            result = result.stringByReplacingOccurrencesOfString("%16", withString: "% 16")
            result = result.stringByReplacingOccurrencesOfString("&lpar;", withString: "#38;lpar;")
            result = result.stringByReplacingOccurrencesOfString("&rpar;", withString: "#38;rpar;")
            
            return result
        }
        
        return result
    }
    
    func getSubString (string:NSString) -> NSString {
        
        var result:NSString = ""
        
        if string.length > 0 {
            result = string.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
            return result
        }
        
        return result
    }
    
    func parseCsvLineString (strCsvRecord: NSString) -> NSArray {
        
        var result: NSMutableArray = NSMutableArray(capacity: 0)
        
        let range1: NSRange? = strCsvRecord.rangeOfString("\",\"[\"") as NSRange
        let range2: NSRange? = strCsvRecord.rangeOfString("\"]\",\"") as NSRange
        if range1?.length > 0 && range2?.length > 0 && range2?.location > range1?.location {
            let firstSubString: NSString? = strCsvRecord.substringToIndex(range1!.location)
            result.addObjectsFromArray(firstSubString!.componentsSeparatedByString(settings.key_spliter))
            
            var midSubString: NSString? = strCsvRecord.substringWithRange(NSMakeRange(range1!.location, range2!.location + range2!.length - range1!.location))
            if midSubString!.hasPrefix(settings.key_spliter) {
                midSubString = midSubString!.substringFromIndex(settings.key_spliter.characters.count)
            }
            if midSubString!.hasSuffix(settings.key_spliter) {
                midSubString = midSubString!.substringToIndex(midSubString!.length - settings.key_spliter.characters.count)
            }
            
            if midSubString!.length > 0 {
                midSubString = midSubString?.stringByReplacingOccurrencesOfString("\"\"", withString: "\"")
            }
            result.addObject(midSubString!)
            
            let lastSubString: NSString? = strCsvRecord.substringFromIndex(range2!.location + range2!.length)
            result.addObjectsFromArray(lastSubString!.componentsSeparatedByString(settings.key_spliter))
        }
        else {
            result = NSMutableArray(array: strCsvRecord.componentsSeparatedByString(settings.key_spliter))
        }
        
        return result
    }
    
    func loadCSVData() {
        
//        guard let path = NSBundle.mainBundle().pathForResource("htsdata", ofType: "csv") else {
//            return
//        }
        
        let path = NSBundle.mainBundle().pathForResource("htsdata", ofType: "csv")
        
        do {
            var strData: NSString? = try NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
            
            if strData!.hasPrefix("\"") {
                strData = strData?.substringFromIndex(1)
            }
            if strData!.hasSuffix("\"") {
                strData = strData?.substringToIndex(strData!.length - 1)
            }
            
            var csvRecords: NSArray? = strData!.componentsSeparatedByString("\n")
            NSLog("======> %lu", csvRecords!.count);
            
            csvRecords = strData!.componentsSeparatedByString("\"\n\"")
            NSLog("======> %lu", csvRecords!.count);
            
            
            for var i: Int = 0; i < csvRecords!.count; ++i {
                
                // test code
                /*
                let strCount: NSString? = self.countField.text
                let count: Int? = strCount?.integerValue
                if self.postItems.count >= count {
                    break
                }
                */
                
                let csvRecord = csvRecords![i] as! NSString
                if csvRecord.length > 0 {
                    let strCsvRecord: NSString = self.getString(csvRecord)
                    
//                    let recordItems: NSArray = strCsvRecord.componentsSeparatedByString(settings.key_spliter)
                    
                    let recordItems: NSArray = self.parseCsvLineString(strCsvRecord)
                    if recordItems.count > 6 {
                        let csvRecordInfo: NSMutableDictionary? = NSMutableDictionary(capacity: 0)
                        csvRecordInfo!.setObject(self.getSubString(recordItems[0] as! NSString), forKey: settings.key_hts_number)
                        csvRecordInfo!.setObject(self.getSubString(recordItems[1] as! NSString), forKey: settings.key_indent)
                        csvRecordInfo!.setObject(self.getSubString(recordItems[2] as! NSString), forKey: settings.key_description)
                        csvRecordInfo!.setObject(self.getSubString(recordItems[3] as! NSString), forKey: settings.key_unit_of_quantity)
                        csvRecordInfo!.setObject(self.getSubString(recordItems[4] as! NSString), forKey: settings.key_general_rate_of_duty)
                        csvRecordInfo!.setObject(self.getSubString(recordItems[5] as! NSString), forKey: settings.key_special_rate_of_duty)
                        csvRecordInfo!.setObject(self.getSubString(recordItems[6] as! NSString), forKey: settings.key_column_2_rate_of_duty)
                        
                        if csvRecordInfo != nil {
                            self.postItems.addObject(csvRecordInfo!)
                        }
                        else {
                            NSLog("NULL Info %@", csvRecord);
                        }
                    }
                    else {
                        NSLog("##### %@", csvRecord);
                    }
                }
                else {
//                    NSLog("##### %@", csvRecord);
                }
            }
            NSLog("<====== %lu", self.postItems.count);
            print("\(self.postItems.lastObject)")
        } catch _ as NSError {
            return
        }
    }
    
    func loadPosts(posts:NSArray) {
        for post in posts {
            let htsNumber = post[settings.key_hts_number] as! String
            let indent = post[settings.key_indent] as! String
            let description = post[settings.key_description] as! String
            let unitOfQuantity = post[settings.key_unit_of_quantity] as! String
            let generalRateOfDuty = post[settings.key_general_rate_of_duty] as! String
            let specialRateOfDuty = post[settings.key_special_rate_of_duty] as! String
            let column2RateOfDuty = post[settings.key_column_2_rate_of_duty] as! String
            
            let postObj = Post(id: 0, htsNumber: htsNumber, indent: indent, description: description, unitOfQuantity: unitOfQuantity, generalRateOfDuty: generalRateOfDuty, specialRateOfDuty: specialRateOfDuty, column2RateOfDuty: column2RateOfDuty)
            postsCollection.append(postObj)
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.csvTableView.reloadData()
        })
    }
    
    
    // MARK: UISearchBarDelegate
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        NSLog("The default search selected scope button index changed to \(selectedScope).")
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        NSLog("The default search bar keyboard search button was tapped: \(searchBar.text).")
        
        let search: NSString? = self.csvSearchBar.text
        searchBar.resignFirstResponder()
        
        if search?.length < 1 {
            self.csvTableView.reloadData()
            return
        }
        
        service.search(search!) { (result) -> () in
            print("\(result)")
            
            self.searchItems = NSMutableArray(array: result)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.csvTableView.reloadData()
            })
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        NSLog("The default search bar cancel button was tapped.")
        
        searchBar.resignFirstResponder()
        
        self.csvSearchBar.text = nil
        self.csvTableView.reloadData()
    }
    
    
    // MARK: ADBannerView delegate
    
    func layoutAnimated(animated: Bool) {
        var contentFrame: CGRect = self.view.bounds
        
        // all we need to do is ask the banner for a size that fits into the layout area we are using
        let sizeForBanner: CGSize = self.bannerView.sizeThatFits(contentFrame.size)
        
        // compute the ad banner frame
        var bannerFrame: CGRect = self.bannerView.frame
        if (self.bannerView.bannerLoaded) {
            
            contentFrame.size.height -= sizeForBanner.height
            bannerFrame.origin.y = contentFrame.size.height
            bannerFrame.size.height = sizeForBanner.height
            bannerFrame.size.width = sizeForBanner.width
            
            let verticalBottomConstraint: NSLayoutConstraint = self.bottomConstraint
            verticalBottomConstraint.constant = sizeForBanner.height
            self.view.layoutSubviews()
            
        }
        else {
            // hide the banner off screen further off the bottom
            bannerFrame.origin.y = contentFrame.size.height
        }
        
        UIView.animateWithDuration(animated ? 0.25 : 0.0) { () -> Void in
            self.csvTableView.layoutIfNeeded()
            self.bannerView.frame = bannerFrame
        }
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView) {
        self.layoutAnimated(true)
        
        NSLog("bannerViewDidLoadAd")
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        NSLog("didFailToReceiveAdWithError %@", error);
        self.layoutAnimated(true)
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return true
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
    }
}
