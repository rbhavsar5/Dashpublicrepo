//
//  Drink.swift
//  Dash
//
//  Created by Arth Joshi on 5/20/15.
//  Copyright (c) 2015 Arth Joshi. All rights reserved.
//

import Foundation
import CloudKit

class Drink {
    
    let name : String
    let description : Array<String>
    let normalPrice : Double
    let specials : Array<Special>
    let currentPrice : Double
    let gotCurrentPrice : Bool = false
    //let restaurantID : CKReference
    let restaurantName : String
    
    
    // init new Drink object
    init(name: String, description: Array<String>, normalPrice: Double, restaurant: Restaurant, specials: Array<Special>, currentPrice : Double, restaurantRef : String, specialsRefs : Array<CKReference>) {
        self.name = name
        self.description = description
        self.normalPrice = normalPrice
        self.specials = specials
        self.currentPrice = currentPrice
        self.restaurantName = restaurantRef
    }
    
    
    // init new Drink object
        
}