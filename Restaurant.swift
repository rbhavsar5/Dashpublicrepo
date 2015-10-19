//
//  Restaurant.swift
//  Dash
//
//  Created by Arth Joshi on 5/19/15.
//  Copyright (c) 2015 Arth Joshi. All rights reserved.
//

import Foundation
import CloudKit
//here too change class to struct

class Restaurant {
    
    let name : String
    let rDrinks : Array<Drink>
    let location : CLLocation
    
    
    // init new Stop object
    init(name: String, rDrinks:Array<Drink>,location:CLLocation) {
        self.name = name
        self.rDrinks = rDrinks
        self.location = location
    } 
 //   /*
    init () {
        self.name = ""
        self.rDrinks = []
        self.location = CLLocation(latitude: 37.2299365, longitude: -80.4149446)
    }
 //   */
}