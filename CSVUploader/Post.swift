//
//  Post.swift
//  CSVUploader
//
//  Created by Xiaohu on 9/25/15.
//  Copyright © 2015 Yanny. All rights reserved.
//

import Foundation

class Post {
    
    var id:Int
    var htsNumber:String
    var indent:String
    var description:String
    var unitOfQuantity:String
    var generalRateOfDuty:String
    var specialRateOfDuty:String
    var column2RateOfDuty:String
    
    init(id:Int, htsNumber:String, indent:String, description:String, unitOfQuantity:String, generalRateOfDuty:String, specialRateOfDuty:String, column2RateOfDuty:String) {
        
        self.id = id
        self.htsNumber = htsNumber
        self.indent = indent
        self.description = description
        self.unitOfQuantity = unitOfQuantity
        self.generalRateOfDuty = generalRateOfDuty
        self.specialRateOfDuty = specialRateOfDuty
        self.column2RateOfDuty = column2RateOfDuty
    }
    
    func toJSON() -> String {
        return ""
    }
}