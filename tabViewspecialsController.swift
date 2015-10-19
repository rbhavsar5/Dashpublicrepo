//
//  SpecialsTableViewController.swift
//  Dash
//
//  Created by Arth Joshi on 5/18/15.
//  Copyright (c) 2015 Arth Joshi. All rights reserved.
//

import UIKit
import CloudKit
//original file
class SpecialsSTableViewController: UITableViewController, UISearchResultsUpdating //UISearchBarDelegate 
    {
    
    let publicDB = CKContainer.defaultContainer().publicCloudDatabase
    var drinks:Array<Drink>! = Array<Drink>()
    var restaurants: Array<Restaurant>! = Array<Restaurant>()
    var filteredDrinks:Array<Drink>! = Array<Drink>()
    var filteredRestaurants:Array<Restaurant>! = Array<Restaurant>()
    var timeStart = 0.0
    
    @IBOutlet var searchButton: UIBarButtonItem!
    var resultSearchController = UISearchController()
    
    var drinksDictionary = [CKRecordID: Drink]()
    var restaurantDictionary = [CKRecordID: Restaurant]()
    var specialsDictionary = [CKRecordID: Special]()
    
    
    var restaurantPending = [CKRecordID: Int]()
    var restaurantStillNeedsToBeAdded = [CKRecordID: CKRecordID]()
    
    var specialPending = [CKRecordID: Int]()
    var specialsStillNeedsToBeAdded = [CKRecordID: Array<CKRecordID>]()
    
    var allRestaurantsFound = false
    var allSpecialsFound = false
    
    
    var weekDay : String = ""
    var currentHour : Int = -1
    var currentMinute : Int = -1
    
    var totalDrinks = 0
    var restaurantsFound = 0
    var specialsFound = 0
    var specialsNeedToBeFound = 0
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
    
    let pink = UIColor(red: 255/255, green: 90/255, blue: 100/255, alpha: 1)
    let blue = UIColor(red: 0/255, green: 178/255, blue: 230/255, alpha: 1)
    let green = UIColor(red: 125/255, green: 222/255, blue: 23/255, alpha: 1)
    let yellow = UIColor(red: 235/255, green: 247/255, blue: 0/255, alpha: 1)
    var colors : Array<UIColor> = Array<UIColor>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        let fixedLoc = CLLocation(latitude: 37.2299365, longitude: -80.4149446)
        
        let radius = CGFloat(8000); // meters
        
        let predicate = NSPredicate(format: "distanceToLocation:fromLocation:(location,%@) < %f", argumentArray: [fixedLoc, radius])
        
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        
        
        publicDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results, error) in
            if (error != nil){
                //error occured
                print(error)
            }
            else {
                // got restaurants
                for restaurant in results!{
                    //print(restaurant["name"] as! String)
                }
                
            }
        })
        
        
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if self.resultSearchController.active {
            return filteredDrinks.count + filteredRestaurants.count
        }
        else {
            return drinks.count
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var drink : Drink
        if self.resultSearchController.active {
            
            if (indexPath.row < filteredRestaurants.count) {
                let selectedRestaurant = filteredRestaurants[indexPath.row]
                let count = self.drinks.filter({( drink: Drink) -> Bool in
                    let match = drink.restaurant.name == selectedRestaurant.name
                    
                    return match
                }).count
                
                let cell = self.tableView.dequeueReusableCellWithIdentifier("restaurant", forIndexPath: indexPath)
                
                cell.backgroundColor = UIColor.clearColor()
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                
                let line = UIView(frame: CGRect(x: 15, y: cell.frame.size.height, width: cell.frame.size.width, height: 3))
                let position = indexPath.row % colors.count
                line.backgroundColor = colors[position]
                cell.addSubview(line)
                
                let restaurantName : UILabel = tableView.viewWithTag(101) as! UILabel
                let restaurantSpecials : UILabel = tableView.viewWithTag(102) as! UILabel
                
                
                restaurantName.text = selectedRestaurant.name
                restaurantSpecials.text = "\(count) drinks"
                
                return cell
            }
            
            drink = filteredDrinks[indexPath.row - filteredRestaurants.count]
        }
        else {
            drink = drinks[indexPath.row]
        }
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("special", forIndexPath: indexPath)
        
        cell.backgroundColor = UIColor.clearColor()
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        let line = UIView(frame: CGRect(x: 15, y: cell.frame.size.height, width: cell.frame.size.width, height: 3))
        let position = indexPath.row % colors.count
        line.backgroundColor = colors[position]
        cell.addSubview(line)
        
        let drinkName : UILabel = tableView.viewWithTag(101) as! UILabel
        let restaurant : UILabel = tableView.viewWithTag(102) as! UILabel
        let price : UILabel = tableView.viewWithTag(103) as! UILabel
        let specialMessage : UILabel = tableView.viewWithTag(104) as! UILabel
        let description : UILabel = tableView.viewWithTag(105) as! UILabel
        
        
        drinkName.text = drink.name
        description.text = drink.description
        restaurant.text = drink.restaurant.name
        price.text = String(format: "$%.2f", drink.currentPrice)
        
        if drink.currentPrice < drink.normalPrice {
            specialMessage.text = String(format: "Normally $%.2f", drink.normalPrice)
            specialMessage.hidden = false
        }
        else {
            specialMessage.hidden = true
        }
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        print(cell?.reuseIdentifier, terminator: "")
    }
    
    /*
    // MARK: - Navigation
    
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Search Methods
    
    @IBAction func searchButtonPressed(sender: AnyObject) {
        
        
        
        
        
        
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchBar.becomeFirstResponder()
            controller.searchBar.tintColor = UIColor.whiteColor()
            let view: UIView = controller.searchBar.subviews[0]
            let subViewsArray = view.subviews
            
            /*
            for (subView: UIView) in subViewsArray as! [UIView] {
            if subView.isKindOfClass(UITextField){
            subView.tintColor = UIColor.lightGrayColor()
            }
            }
            */
            
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.hidesNavigationBarDuringPresentation = false
            controller.active = true
            controller.searchBar.delegate = self
            
            self.definesPresentationContext = true
            self.navigationItem.titleView = controller.searchBar
            //self.tableView.tableHeaderView = controller.searchBar
            return controller
        })()
        
        
        self.navigationItem.titleView = self.resultSearchController.searchBar
        self.tableView.resignFirstResponder()
        //self.resultSearchController.active = true
        //self.resultSearchController.becomeFirstResponder()
        self.resultSearchController.searchBar.becomeFirstResponder()
        self.searchBarShouldBeginEditing(self.resultSearchController.searchBar)
        self.navigationItem.rightBarButtonItem = nil
        
        
        
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let extraZeros = "0000000000000"
        let searchText = searchController.searchBar.text!.lowercaseString
        filteredDrinks = self.drinks.filter({( drink: Drink) -> Bool in
            let stringMatch = drink.name.lowercaseString.rangeOfString(searchText)
            let resMatch = drink.restaurant.name.lowercaseString.rangeOfString(searchText)
            let descriptionMatch = drink.description.lowercaseString.rangeOfString(searchText)
            
            let normalPriceString = drink.normalPrice.description.lowercaseString + extraZeros
            let currentPriceString = drink.currentPrice.description.lowercaseString + extraZeros
            let normalPriceMatch = normalPriceString.rangeOfString(searchText)
            let currentPriceMatch = currentPriceString.rangeOfString(searchText)
            
            return (stringMatch != nil || resMatch != nil || descriptionMatch != nil || normalPriceMatch != nil || currentPriceMatch != nil)
        })
        
        self.filteredRestaurants = self.restaurants.filter({( restaurant: Restaurant) -> Bool in
            let nameMatch = restaurant.name.lowercaseString.rangeOfString(searchText)
            return (nameMatch != nil)
        })
        
        
        
        self.tableView.reloadData()
        
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.navigationItem.titleView = nil
        self.navigationItem.rightBarButtonItem = searchButton
        self.resultSearchController.resignFirstResponder()
        self.resultSearchController.active = false
        self.tableView.reloadData()
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        return true
    }
    
    
    
    // MARK: - Fetch Data
    
    func getAllDrinks(){
        let query = CKQuery(recordType: "Drink", predicate: NSPredicate(value: true))
        let sort = NSSortDescriptor(key: "normalPrices", ascending: true)
        query.sortDescriptors = [sort]
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = {(record : CKRecord) in
            self.totalDrinks++
            
            var drinkName : String = record.objectForKey("name") as! String
            var drinkDescription : String = record.objectForKey("description") as! String
            var normalPrice : Double = record.objectForKey("normalPrices") as! Double
            var restaurantRef : CKReference = record.objectForKey("restaurant") as! CKReference
            var specialsRefs : Array<CKReference>
            if let test = record.objectForKey("specials") as? Array<CKReference>{
                specialsRefs = test
                
            }else {
                specialsRefs = Array<CKReference>()
            }
            self.specialsNeedToBeFound = self.specialsNeedToBeFound + specialsRefs.count
            
            var restaurant : Restaurant = Restaurant()
            var specials : Array<Special> = Array<Special>()
            
            var specialsPending : Array<CKRecordID> = Array<CKRecordID>()
            
            var allSpecialsAlreadyFound = true
            
            
            if self.drinksDictionary[record.recordID] != nil {
                
            } else {
                self.drinksDictionary[record.recordID] = Drink(name: drinkName, description: drinkDescription, normalPrice: normalPrice, restaurant: restaurant, specials: specials, currentPrice: normalPrice, restaurantRef: restaurantRef, specialsRefs: specialsRefs)
            }
            
            
            
            
            if self.restaurantDictionary[restaurantRef.recordID] != nil {
                //println("restaurant found")
                //found restaurant
                restaurant = self.restaurantDictionary[restaurantRef.recordID]!
                var drink = self.drinksDictionary[record.recordID]
                drink?.restaurant = restaurant
                self.drinksDictionary[record.recordID] = drink
                //println(self.drinksDictionary[record.recordID]?.restaurant.name)
                self.restaurantsFound++
                
            }
            else {
                //println("restaurant not found")
                //restaurant needs to be found on CloudKit
                if self.restaurantPending[restaurantRef.recordID] != nil {
                    self.restaurantsFound++
                    self.restaurantStillNeedsToBeAdded[record.recordID] = restaurantRef.recordID
                }else {
                    self.restaurantPending[restaurantRef.recordID] = 1
                    self.fetchRestaurant(record.recordID, restaurantRecordID: restaurantRef.recordID)
                }
                
            }
            
            var specialsInQueue = Array<CKRecordID>()
            for specialReference in specialsRefs {
                //go throught every special drink has
                if self.specialsDictionary[specialReference.recordID] != nil {
                    //that special found
                    if (self.drinksDictionary[record.recordID]?.gotCurrentPrice) == false {
                        self.updateCurrentPrice(record.recordID, special: self.specialsDictionary[specialReference.recordID]!)
                    }
                    
                    specials.append(self.specialsDictionary[specialReference.recordID]!)
                    self.specialsFound++
                }
                else {
                    //this special needs to found on CloudKit
                    if self.specialPending[specialReference.recordID] != nil {
                        self.specialsFound++
                        specialsInQueue.append(specialReference.recordID)
                        self.specialsStillNeedsToBeAdded[record.recordID] = specialsInQueue
                    } else {
                        self.specialPending[specialReference.recordID] = 1
                        specialsPending.append(specialReference.recordID)
                        allSpecialsAlreadyFound = false
                    }
                    
                }
            }
            
            if allSpecialsAlreadyFound {
                //println("all specials found")
                //all specials already found
                var drink = self.drinksDictionary[record.recordID]
                drink?.specials = specials
                self.drinksDictionary[record.recordID] = drink
            }
            else {
                //println("not all specials found")
                //specials still need to be found
                self.fetchSpecials(record.recordID, specialsRecordIDs: specialsPending)
                
            }
            
            
            
        }
        
        operation.queryCompletionBlock = {( cursor : CKQueryCursor?, error : NSError?) in
            
            
            while self.totalDrinks != self.restaurantsFound && !self.allRestaurantsFound{
                
            }
            while self.specialsNeedToBeFound != self.specialsFound && !self.allSpecialsFound{
                
            }
            
            for drinkID in self.restaurantStillNeedsToBeAdded.keys {
                print("res duplicates", terminator: "")
                var drink = self.drinksDictionary[drinkID]
                var restaurantID = self.restaurantStillNeedsToBeAdded[drinkID]!
                var restaurant = self.restaurantDictionary[restaurantID]
                drink!.restaurant = restaurant!
                self.drinksDictionary[drinkID] = drink
            }
            
            for drinkID in self.specialsStillNeedsToBeAdded.keys {
                print("special duplicates", terminator: "")
                var drink = self.drinksDictionary[drinkID]
                var specialKeys = self.specialsStillNeedsToBeAdded[drinkID]!
                
                for key in specialKeys {
                    var special = self.specialsDictionary[key]
                    drink!.specials.append(special!)
                    self.drinksDictionary[drinkID] = drink
                    self.updateCurrentPrice(drinkID, special: special!)
                }
            }
            //if let credentials = credentialStorage.credentialsForProtectionSpace(protectionSpace)?.values.array
            //if let credentials = credentialStorage?.credentialsForProtectionSpace(protectionSpace)?.values
            self.drinks = Array(self.drinksDictionary.values)
            
            self.drinks.sortInPlace({ $0.currentPrice < $1.currentPrice })
            
            
            
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                print(((NSDate().timeIntervalSinceReferenceDate) - self.timeStart), terminator: "")
                self.tableView.reloadData()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.activityIndicator.stopAnimating()
                self.tableView.tableHeaderView = nil
            })
            
            let newOperation = CKQueryOperation(cursor: cursor!)
            newOperation.recordFetchedBlock = operation.recordFetchedBlock
            newOperation.queryCompletionBlock = operation.queryCompletionBlock
            self.publicDB.addOperation(newOperation)
        }
        
        publicDB.addOperation(operation)
        
        
    }
    
    func getAllRestaurants() {
        let query = CKQuery(recordType: "Restaurant", predicate: NSPredicate(value: true))
        
        let operation = CKQueryOperation(query: query)
        
        
        operation.recordFetchedBlock = {(record : CKRecord) in
            
            var restaurantName : String
            if let test = record.objectForKey("name") as? String{
                restaurantName = test
                self.restaurantDictionary[record.recordID] = Restaurant(name: restaurantName)
                self.restaurants.append(Restaurant(name: restaurantName))
                //println(self.restaurantDictionary)
                
            }else {
                return
            }
            
            
            
        }
        
        
        operation.queryCompletionBlock = {( cursor : CKQueryCursor?, error : NSError?) in
            print("got all restaurants", terminator: "")
            self.allRestaurantsFound = true
            let newOperation = CKQueryOperation(cursor: cursor!)
            newOperation.recordFetchedBlock = operation.recordFetchedBlock
            newOperation.queryCompletionBlock = operation.queryCompletionBlock
            self.publicDB.addOperation(newOperation)
        }
        
        publicDB.addOperation(operation)
    }
    
    func getAllSpecials() {
        let query = CKQuery(recordType: "Special", predicate: NSPredicate(value: true))
        
        let operation = CKQueryOperation(query: query)
        
        
        operation.recordFetchedBlock = {(record : CKRecord) in
            var day : String
            if let test = record.objectForKey("day") as? String{
                day = test
                var specialPrice : Double = record.objectForKey("specialPrice") as! Double
                var startTimeHour : Int = record.objectForKey("startTimeHour") as! Int
                var startTimeMinute : Int = record.objectForKey("startTimeMinute") as! Int
                var endTimeHour : Int = record.objectForKey("endTimeHour") as! Int
                var endTimeMinute : Int = record.objectForKey("endTimeMinute") as! Int
                
                var newSpecial = Special(specialPrice: specialPrice, day: day, startTimeHour: startTimeHour, startTimeMinute: startTimeMinute, endTimeHour: endTimeHour, endTimeMinute: endTimeMinute)
                self.specialsDictionary[record.recordID] = newSpecial
                
                
            }else {
                return
            }
            2
        }
        
        
        operation.queryCompletionBlock = {( cursor : CKQueryCursor?, error : NSError?) in
            print("got all specials", terminator: "")
            self.allSpecialsFound = true
            let newOperation = CKQueryOperation(cursor: cursor!)
            newOperation.recordFetchedBlock = operation.recordFetchedBlock
            newOperation.queryCompletionBlock = operation.queryCompletionBlock
            self.publicDB.addOperation(newOperation)
        }
        
        publicDB.addOperation(operation)
    }
    
    func fetchRestaurant(drinkRecordID : CKRecordID, restaurantRecordID : CKRecordID) {
        
        
        let operation = CKFetchRecordsOperation(recordIDs: [restaurantRecordID])
        
        operation.perRecordCompletionBlock = {( record : CKRecord?, recordID : CKRecordID?, error : NSError?) in
            var restaurantName = record!.objectForKey("name") as! String
            var restaurantFound = Restaurant(name:restaurantName)
            
            var drink = self.drinksDictionary[drinkRecordID]
            drink?.restaurant = restaurantFound
            self.restaurantDictionary[restaurantRecordID] = restaurantFound
            self.drinksDictionary[drinkRecordID] = drink
            self.restaurantsFound++
            
        }
        
        publicDB.addOperation(operation)
        
    }
    
    
    func fetchSpecials(drinkRecordID : CKRecordID, specialsRecordIDs : Array<CKRecordID>){
        
        var specials : Array<Special> = Array<Special>()
        let operation = CKFetchRecordsOperation(recordIDs: specialsRecordIDs)
        
        operation.perRecordCompletionBlock = {( specialRecord : CKRecord?, recordID : CKRecordID?, error : NSError?) in
            
            var day : String = specialRecord!.objectForKey("day") as! String
            var specialPrice : Double = specialRecord!.objectForKey("specialPrice") as! Double
            var startTimeHour : Int = specialRecord!.objectForKey("startTimeHour") as! Int
            var startTimeMinute : Int = specialRecord!.objectForKey("startTimeMinute") as! Int
            var endTimeHour : Int = specialRecord!.objectForKey("endTimeHour") as! Int
            var endTimeMinute : Int = specialRecord!.objectForKey("endTimeMinute") as! Int
            
            var newSpecial = Special(specialPrice: specialPrice, day: day, startTimeHour: startTimeHour, startTimeMinute: startTimeMinute, endTimeHour: endTimeHour, endTimeMinute: endTimeMinute)
            
            //var newSpecial = Special(day,specialPrice,startTimeHour,startTimeMinute,endTimeHour,endTimeMinute)
            
            specials.append(newSpecial)
            self.specialsDictionary[recordID!] = newSpecial
            
            self.updateCurrentPrice(drinkRecordID, special : newSpecial)
        }
        
        operation.fetchRecordsCompletionBlock = {( dict : [CKRecordID : CKRecord]?, error : NSError?) in
            var drink = self.drinksDictionary[drinkRecordID]
            
            for special in specials {
                self.specialsFound++
                drink?.specials.append(special)
                if drink?.gotCurrentPrice == false {
                    self.updateCurrentPrice(drinkRecordID, special: special)
                }
                
            }
            
            self.drinksDictionary[drinkRecordID] = drink
            print("done finding special")
        }
        
        
        publicDB.addOperation(operation)
    }
    
    func updateCurrentPrice(drinkRecordID : CKRecordID, special : Special) {
        let drink = self.drinksDictionary[drinkRecordID]
        print(drink?.name, terminator: "")
        if weekDay == special.day {
            if currentHour > special.startTimeHour && currentHour < special.endTimeHour {
                drink!.currentPrice = special.specialPrice
                drink!.gotCurrentPrice = true
            }
            else if currentHour == special.startTimeHour {
                if currentMinute > special.startTimeMinute {
                    if currentHour == special.endTimeHour && currentMinute <= special.endTimeMinute{
                        drink!.currentPrice = special.specialPrice
                        drink!.gotCurrentPrice = true
                    }
                    
                }
            }
            else if currentHour == special.endTimeHour {
                if currentMinute < special.endTimeMinute {
                    if currentHour == special.startTimeHour && currentMinute >= special.startTimeMinute {
                        drink!.currentPrice = special.specialPrice
                        drink!.gotCurrentPrice = true
                    }
                    drink!.gotCurrentPrice = true
                    drink!.currentPrice = special.specialPrice
                    
                }
            }
        }
        
        self.drinksDictionary[drinkRecordID] = drink
        
        
    }
    
    
    
    
    
    
    // MARK: - Image Processing
    func imageFromLayer(layer: CALayer) -> UIImage{
        if (UIScreen.mainScreen().respondsToSelector(Selector("scale"))){
            UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, UIScreen.mainScreen().scale)
        }else{
            UIGraphicsBeginImageContext(layer.frame.size)
        }
        
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let outputImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return outputImage
    }
    
    func imageCreate(color : UIColor, size  : CGSize) -> UIImage{
        UIGraphicsBeginImageContext(size)
        let rPath = UIBezierPath(rect: CGRectMake(0, 0, size.width, size.height))
        color.setFill()
        rPath.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
    
    // MARK: - To Add Specials Manually
    func addSpecials() {
        var special1 = Special(specialPrice: 3, day: "Monday", startTimeHour: 11, startTimeMinute: 00, endTimeHour: 21, endTimeMinute: 00)
        var special2 = Special(specialPrice: 3, day: "Tuesday", startTimeHour: 11, startTimeMinute: 00, endTimeHour: 21, endTimeMinute: 00)
        let special3 = Special(specialPrice: 3, day: "Wednesday", startTimeHour: 11, startTimeMinute: 00, endTimeHour: 21, endTimeMinute: 00)
        var special4 = Special(specialPrice: 3, day: "Thursday", startTimeHour: 11, startTimeMinute: 00, endTimeHour: 21, endTimeMinute: 00)
        var special5 = Special(specialPrice: 3, day: "Friday", startTimeHour: 11, startTimeMinute: 00, endTimeHour: 21, endTimeMinute: 00)
        var special6 = Special(specialPrice: 3, day: "Saturday", startTimeHour: 11, startTimeMinute: 00, endTimeHour: 21, endTimeMinute: 00)
        var special7 = Special(specialPrice: 3, day: "Sunday", startTimeHour: 11, startTimeMinute: 00, endTimeHour: 21, endTimeMinute: 00)
        
        
        
        
        
        let specialID : CKRecordID = CKRecordID(recordName: "W1100_2100_$3")
        
        let specialRecord = CKRecord(recordType: "Special", recordID: specialID)
        
        
        
        specialRecord.setObject(special3.specialPrice, forKey: "specialPrice")
        specialRecord.setObject(special3.day, forKey: "day")
        specialRecord.setObject(special3.startTimeHour, forKey: "startTimeHour")
        specialRecord.setObject(special3.startTimeMinute, forKey: "startTimeMinute")
        specialRecord.setObject(special3.endTimeHour, forKey: "endTimeHour")
        specialRecord.setObject(special3.endTimeMinute, forKey: "endTimeMinute")
        
        publicDB.saveRecord(specialRecord, completionHandler: {(record, error) in
            if (error != nil) {
                
                print("Error happened while saving special", terminator: "")
                
            }
                
            else{
                print("Special Saved", terminator: "")
            }
        })
        
        
        
    }
    
    
    // MARK: - Data Fetching -------- OLD
    func fetchDrinks() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let todayDate : NSDate =  NSDate()
        let myCalendar : NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents : NSDateComponents = myCalendar.components(NSCalendarUnit.NSWeekdayCalendarUnit, fromDate: todayDate)
        let weekDayInt : Int = myComponents.weekday
        var weekDay : String = ""
        
        if weekDayInt == 1 {
            weekDay = "Sunday"
        }
        else if weekDayInt == 2 {
            weekDay = "Monday"
        }
        else if weekDayInt == 3 {
            weekDay = "Tuesday"
        }
        else if weekDayInt == 4 {
            weekDay = "Wednesday"
        }
        else if weekDayInt == 5 {
            weekDay = "Thursday"
        }
        else if weekDayInt == 6 {
            weekDay = "Friday"
        }
        else if weekDayInt == 7 {
            weekDay = "Saturday"
        }
        
        
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute], fromDate:  NSDate())
        let currentHour = components.hour
        let currentMinute = components.minute
        
        self.title = "\(weekDay) Specials"
        
        
        var restaurantFound = false
        var specialsArrayFound = false
        var drinksFound = false
        
        var restaurantDictionary = [CKRecordID: Restaurant]()
        var specialsDictionary = [CKRecordID: Special]()
        
        
        let query = CKQuery(recordType: "Drink", predicate: NSPredicate(value: true))
        
        publicDB.performQuery(query, inZoneWithID: nil, completionHandler: {(results, error) in
            if error != nil {
                print(error, terminator: "")
            }
            else {
                self.drinks = []
                
                for drinkRecord in results! {
                    restaurantFound = false
                    specialsArrayFound = false
                    drinksFound = false
                    var specialsList : Array<Special> = Array<Special>()
                    var restaurant : Restaurant = Restaurant()
                    
                    var drinkName : String = drinkRecord["name"] as! String
                    var drinkDescription : String = drinkRecord["description"] as! String
                    var normalPrice : Double = drinkRecord["normalPrices"] as! Double
                    var currentPrice : Double = normalPrice
                    
                    var specialsReferences : Array<CKReference> = Array<CKReference>()
                    
                    if let test = drinkRecord["specials"] as? Array<CKReference>{
                        specialsReferences = drinkRecord["specials"] as! Array<CKReference>
                        
                    } else {
                        specialsArrayFound = true
                    }
                    
                    
                    
                    for special in specialsReferences{
                        var specialID = special.recordID
                        
                        
                        if specialsDictionary[specialID] != nil {
                            var specialFound : Special = specialsDictionary[specialID]!
                            specialsList.append(specialFound)
                            
                            if weekDay == specialFound.day {
                                if currentHour > specialFound.startTimeHour && currentHour < specialFound.endTimeHour {
                                    currentPrice = specialFound.specialPrice
                                }
                                else if currentHour == specialFound.startTimeHour {
                                    if currentMinute > specialFound.startTimeMinute {
                                        if currentHour == specialFound.endTimeHour && currentMinute <= specialFound.endTimeMinute{
                                            currentPrice = specialFound.specialPrice
                                        }
                                        
                                    }
                                }
                                else if currentHour == specialFound.endTimeHour {
                                    if currentMinute < specialFound.endTimeMinute {
                                        if currentHour == specialFound.startTimeHour && currentMinute >= specialFound.startTimeMinute {
                                            currentPrice = specialFound.specialPrice
                                        }
                                        
                                    }
                                }
                            }
                            
                            if specialsList.count == specialsReferences.count {
                                specialsArrayFound = true
                                
                            }
                        }
                        else {
                            self.publicDB.fetchRecordWithID(specialID, completionHandler: {(specialRecord, error) in
                                if error != nil {
                                    print(error, terminator: "")
                                }
                                else{
                                    
                                    var day : String = specialRecord!.objectForKey("day") as! String
                                    var specialPrice : Double = specialRecord!.objectForKey("specialPrice") as! Double
                                    var startTimeHour : Int = specialRecord!.objectForKey("startTimeHour") as! Int
                                    var startTimeMinute : Int = specialRecord!.objectForKey("startTimeMinute") as! Int
                                    var endTimeHour : Int = specialRecord!.objectForKey("endTimeHour") as! Int
                                    var endTimeMinute : Int = specialRecord!.objectForKey("endTimeMinute") as! Int
                                    
                                    var newSpecial = Special(specialPrice: specialPrice, day: day, startTimeHour: startTimeHour, startTimeMinute: startTimeMinute, endTimeHour: endTimeHour, endTimeMinute: endTimeMinute)
                                    
                                    specialsList.append(newSpecial)
                                    specialsDictionary[specialID] = newSpecial
                                    
                                    if weekDay == day {
                                        if currentHour > startTimeHour && currentHour < endTimeHour {
                                            currentPrice = specialPrice
                                        }
                                        else if currentHour == startTimeHour {
                                            if currentMinute > startTimeMinute {
                                                if currentHour == endTimeHour && currentMinute <= endTimeMinute{
                                                    currentPrice = specialPrice
                                                }
                                                
                                            }
                                        }
                                        else if currentHour == endTimeHour {
                                            if currentMinute < endTimeMinute {
                                                if currentHour == startTimeHour && currentMinute >= startTimeMinute {
                                                    currentPrice = specialPrice
                                                }
                                                currentPrice = specialPrice
                                                
                                            }
                                        }
                                    }
                                    
                                    if specialsList.count == specialsReferences.count {
                                        specialsArrayFound = true
                                        
                                    }
                                }
                                
                            })
                            
                        }
                        
                    }
                    
                    
                    
                    
                    var restaurantReference : CKReference = drinkRecord["restaurant"] as! CKReference
                    var restaurantID = restaurantReference.recordID
                    
                    if restaurantDictionary[restaurantID] != nil {
                        restaurant = restaurantDictionary[restaurantID]!
                        restaurantFound = true
                    }
                    else {
                        
                        self.publicDB.fetchRecordWithID(restaurantID, completionHandler: {(restaurantRecord, error) in
                            if error != nil{
                                print(error, terminator: "")
                            }
                            else{
                                var restaurantName : String = restaurantRecord!.objectForKey("name") as! String
                                restaurant = Restaurant(name: restaurantName)
                                restaurantDictionary[restaurantID] = restaurant
                                restaurantFound = true
                            }
                            
                        })
                    }
                    
                    while (!restaurantFound || !specialsArrayFound){
                    }
                    
                    self.drinks.append(Drink(name: drinkName, description: drinkDescription, normalPrice: normalPrice, restaurant: restaurant, specials: specialsList, currentPrice : currentPrice, restaurantRef : restaurantReference, specialsRefs : specialsReferences))
                    //println("drink added")
                    if (self.drinks.count == results!.count) {
                        drinksFound = true
                    }
                    
                }
                
                
                
                
            }
            
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                
                self.drinks.sortInPlace({ $0.currentPrice < $1.currentPrice })
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                print("done", terminator: "")
                print(((NSDate().timeIntervalSinceReferenceDate) - self.timeStart), terminator: "")
                
                self.tableView.reloadData()
            })
            
            
        })
        
    }
    
    
    func testCode(){
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        activityIndicator.startAnimating()
        
        self.tableView.tableHeaderView = activityIndicator
        
        let todayDate : NSDate =  NSDate()
        let myCalendar : NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents : NSDateComponents = myCalendar.components(NSCalendarUnit.NSWeekdayCalendarUnit, fromDate: todayDate)
        let weekDayInt : Int = myComponents.weekday
        //use switch and case
        if weekDayInt == 1 {
            weekDay = "Sunday"
        }
        else if weekDayInt == 2 {
            weekDay = "Monday"
        }
        else if weekDayInt == 3 {
            weekDay = "Tuesday"
        }
        else if weekDayInt == 4 {
            weekDay = "Wednesday"
        }
        else if weekDayInt == 5 {
            weekDay = "Thursday"
        }
        else if weekDayInt == 6 {
            weekDay = "Friday"
        }
        else if weekDayInt == 7 {
            weekDay = "Saturday"
        }
        
        
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute], fromDate:  NSDate())
        currentHour = components.hour
        currentMinute = components.minute
        
        self.title = "\(weekDay) Specials"
        
        timeStart = NSDate().timeIntervalSinceReferenceDate
        
        //let PICTURE = /Users/raajbhavsar/Downloads/Dash-2/Dash/stair.png
        
        //fetchDrinks()
        
        getAllRestaurants()
        getAllSpecials()
        getAllDrinks()
        
        
        
        //var gradient = CAGradientLayer()
        //gradient.frame = self.tableView.bounds
        //var array = [CGColorRef]()
        //array.append(UIColor.blackColor().CGColor)
        
        //array.append(UIColor.grayColor().adjust(0.3, green: 0.3, blue: 0.3,  alpha: 0).CGColor)
        //gradient.colors = array
        
        self.navigationController?.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.translucent
        
        //var backgroundImage : UIImage = imageFromLayer(gradient)
        var backgroundimage : UIImage = UIImage(named:"stair.png")!
        
        var imageView = UIImageView(image: backgroundimage)
        
        //imageView.frame = self.tableView.bounds
        
        self.tableView.backgroundView = imageView
        
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        colors = [yellow, blue, pink, green]
        
        
        
        //let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        //self.navigationController!.navigationBar.titleTextAttributes = titleDict as! [String : AnyObject]
        
        // let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        // self.navigationController?.navigationBar.titleTextAttributes = titleDict as [NSObject : AnyObject]
        self.title = "\(weekDay) Specials"
        
        
        
        var rect = CGRectMake(0.0, 0.0, 1.0, 1.0);
        UIGraphicsBeginImageContext(rect.size);
        var context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, UIColor.blackColor().CGColor);
        CGContextFillRect(context, rect);
        
        var image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.navigationController?.navigationBar.setBackgroundImage(image, forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = self.imageCreate(UIColor.whiteColor(), size: CGSizeMake(self.view.frame.size.width, 2.0))
    }
    
    
    
}








//extension to make image darker
extension UIColor{
    func adjust(red: CGFloat, green: CGFloat, blue: CGFloat, alpha:CGFloat) -> UIColor{
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        var w: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: r+red, green: g+green, blue: b+blue, alpha: a+alpha)
    }
}

