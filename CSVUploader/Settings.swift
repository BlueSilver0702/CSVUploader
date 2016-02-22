//
//  Settings.swift
//  CSVUploader
//
//  Created by Xiaohu on 9/25/15.
//  Copyright © 2015 Yanny. All rights reserved.
//

import Foundation

class Settings {
    
    let MAX_UPLOAD_SIZE = 1024*1024
    let key_spliter = "\",\""
    
    let key_hts_number = "hts_number"
    let key_indent = "indent"
    let key_description = "description"
    let key_unit_of_quantity = "unit_of_quantity"
    let key_general_rate_of_duty = "general_rate_of_duty"
    let key_special_rate_of_duty = "special_rate_of_duty"
    let key_column_2_rate_of_duty = "column_2_rate_of_duty"
    
    let ShowDetailViewController = "ShowDetailViewController"
    
    
    var viewPosts = "http://192.168.2.10/hts/post.json"
    
//    var uploadUrl = "http://192.168.2.10/hts/upload.php"
    var uploadUrl = "http://ggholdings.us/hts/upload.php"
    
//    var searchUrl = "http://192.168.2.10/hts/search.php"
    var searchUrl = "http://ggholdings.us/hts/search.php"
}