//
//  DetailViewController.swift
//  CSVUploader
//
//  Created by Xiaohu on 9/28/15.
//  Copyright © 2015 Yanny. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    let maxSize: CGSize = CGSizeMake(UIScreen.mainScreen().bounds.width - 30, 9999)
    
    @IBOutlet weak var detailTableView: UITableView!
    
    var info: NSDictionary?
    
    
    var settings:Settings!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.settings = Settings()
        
        self.title = info!["hts_number"] as? String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.info!.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var rowHeight: CGFloat? = CGFloat(0)
        
        let infoString: NSString? = self.getInfoString(indexPath.section)
        if (infoString != nil && infoString?.length > 0) {
            let frame = infoString?.boundingRectWithSize(maxSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(17)], context: nil)
            rowHeight = (frame?.size.height)! + 10
        }
        
        if rowHeight < CGFloat(50) {
            rowHeight = CGFloat(50)
        }
        
        return rowHeight!
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var headerTitle: String? = nil
        
        switch section {
        case 0:
            headerTitle = "HTS Number"
            break
        case 1:
            headerTitle = "Indent"
            break
        case 2:
            headerTitle = "Description"
            break
        case 3:
            headerTitle = "Unit of Quantity"
            break
        case 4:
            headerTitle = "General Rate of Duty"
            break
        case 5:
            headerTitle = "Special Rate of Duty"
            break
        case 6:
            headerTitle = "Column 2 Rate of Duty"
            break
            
        default:
            break
        }
        
        return headerTitle
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath)

        // Configure the cell...
        
        let infoString: NSString? = self.getInfoString(indexPath.section)
        
        cell.textLabel?.text = infoString as? String
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = UIColor.darkGrayColor()

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Main methods
    
    func getInfoString(keyIndex: Int) -> NSString? {
        
        var infoString: NSString? = nil
        
        switch keyIndex {
        case 0:
            infoString = self.info![settings.key_hts_number] as? NSString
            break
        case 1:
            infoString = self.info![settings.key_indent] as? NSString
            break
        case 2:
            infoString = self.info![settings.key_description] as? NSString
            break
        case 3:
            infoString = self.info![settings.key_unit_of_quantity] as? NSString
            break
        case 4:
            infoString = self.info![settings.key_general_rate_of_duty] as? NSString
            break
        case 5:
            infoString = self.info![settings.key_special_rate_of_duty] as? NSString
            break
        case 6:
            infoString = self.info![settings.key_column_2_rate_of_duty] as? NSString
            break
            
        default:
            break
        }
        
        return infoString
    }
}
