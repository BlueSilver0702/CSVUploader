//
//  PostService.swift
//  CSVUploader
//
//  Created by Xiaohu on 9/25/15.
//  Copyright © 2015 Yanny. All rights reserved.
//

import Foundation

class PostService {
    
    var settings:Settings!
    
    init() {
        self.settings = Settings()
    }
    
    func getPosts(callback:(NSDictionary) -> ()) {
        request(settings.viewPosts, callback: callback)
    }
    
    func request(urlString:String, callback:(NSDictionary) -> ()) {
        let url = NSURL(string: urlString)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
            
            do {
                let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                
                callback(jsonData)
                
            } catch {
                print("error = \(error)")
            }
        })
        task.resume()
    }
    
    func search(search: NSString, callback:(NSArray) -> ()) {
        
        let bodyString: NSString = NSString(format: "search=%@", search)
        
        let url = NSURL(string: settings.searchUrl)
        
        //create the session object
        let session = NSURLSession.sharedSession()
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST" //set http method as POST
        request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding)
        
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            if (error != nil) {
                callback([])
                return
            }
            
            // test code
            print("Response: \(response)")
            
            if data == nil {
                callback([])
                return
            }
            
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            
            do {
                let jsonData: NSArray? = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSArray
                
                if (jsonData == nil) {
                    callback([])
                }
                else {
                    callback(jsonData!)
                }
                
            } catch {
                callback([])
            }
        })
        
        task.resume()
    }
    
    func post(bodyData: NSData, callback:(NSString) -> ()) {
        
        let url = NSURL(string: settings.uploadUrl)
        
        //create the session object
        let session = NSURLSession.sharedSession()
        
        //now create the NSMutableRequest object using the url object
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST" //set http method as POST
        request.HTTPBody = bodyData
        
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            if (error != nil) {
                let errorResponse: NSError = error!
                callback("\(errorResponse.localizedDescription)")
                return
            }
            
            // test code
//            print("Response: \(response)")
            
            if data == nil {
                callback("Failed to upload.")
                return
            }
            
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
//            print("Body: \(strData)")
            
            do {
                let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                
                if (jsonData == nil) {
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    callback(NSString(format: "Could not parse response: \"%@\"", jsonStr!))
                }
                else {
                    if let parseJSON = jsonData {
                        let success: NSString = parseJSON["result"] as! NSString
                        callback(success);
                    }
                    else {
                        let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        callback(NSString(format: "Failed to upload CSV data: \"%@\"", jsonStr!))
                    }
                }
                
            } catch {
//                print("error = \(error)")
                callback(strData!)
            }
            
        })
        
        task.resume()
    }
}