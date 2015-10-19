//
//  Special.swift
//  Dash
//
//  Created by Arth Joshi on 5/19/15.
//  Copyright (c) 2015 Arth Joshi. All rights reserved.
//

import Foundation
import CloudKit

class Special {
    
    let specialPrice : Double
    let specialOFF : NSDate
    let specialON : NSDate
    let drinkReference : CKReference
    
    
    
    // init new Special ojbject
    init(specialPrice: Double, specialOFF:NSDate,specialON:NSDate,drinkReference:CKReference) {
        self.specialPrice = specialPrice
        self.specialON = specialON
        self.specialOFF = specialOFF
        self.drinkReference = drinkReference
    }
    
}