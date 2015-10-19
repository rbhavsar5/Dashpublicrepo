//
//  SpecialsTableViewController.swift
//  Dash
//
//  Created by Arth Joshi on 5/18/15.
//  Copyright (c) 2015 Arth Joshi. All rights reserved.
//

import UIKit
import CloudKit

class SpecialsTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {

    let publicDB = CKContainer.defaultContainer().privateCloudDatabase
    var drinks:Array<Drink>! = Array<Drink>()
    var restaurants: Array<Restaurant>! = Array<Restaurant>()
    var filteredDrinks:Array<Drink>! = Array<Drink>()
    var filteredRestaurants:Array<Restaurant>! = Array<Restaurant>()
    var timeStart = 0.0
    
    @IBOutlet var searchButton: UIBarButtonItem!
    var resultSearchController = UISearchController()
    
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
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        activityIndicator.startAnimating()
        
        self.tableView.tableHeaderView = activityIndicator
        
        let todayDate : NSDate =  NSDate()
        let myCalendar : NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents : NSDateComponents = myCalendar.components(NSCalendarUnit.NSWeekdayCalendarUnit, fromDate: todayDate)
        let weekDayInt : Int = myComponents.weekday
        
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
        
    }
    
    
    func getAllRestaurants() {
        
        getAllDrinks() //get all specials in this 
        //drinks 
            
        let fixedLoc = CLLocation(latitude: 37.2299365, longitude: -80.4149446)
            
        let radius = CGFloat(8000); // meters
        // predicate gets only relevant restaurants in the area of the user
        // change to get user 
        let predicate = NSPredicate(format: "distanceToLocation:fromLocation:(location,%@) < %f", argumentArray: [fixedLoc, radius])
            
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
            
        let operation = CKQueryOperation(query: query)
            
        operation.recordFetchedBlock = {(record : CKRecord) in
                
            var restaurantName : String
            var restaurantLoc : CLLocation
            var restaurantID : CKRecordID
            var rDrinks :Array<Drink>
            
            //filter out only drinks for current restaurant
            let predicate:NSPredicate = NSPredicate(format: "restaurant == restaurantID")
            let rDrinks = drinks.filteredArrayUsingPredicate(predicate)
    
        
            
            //rDrinks = self.drinks.    
            if let testRest = record.objectForKey("name") as? String, let testLoc = record.objectForKey("location") as? CLLocation{
                restaurantName = testRest
                restaurantLoc = testLoc
                restaurantDrinks = testDrinks
                
   
            }else {
                return
                
            }
            
         self.restaurants.append(Restaurant(name: restaurantName, rDrinks: restaurantDrinks,location: restaurantLoc))
        }
           
    }
            
    func getAllDrinks() {
        
        getAllSpecials()
        
        let query = CKQuery(recordType: "Drink", predicate: NSPredicate(value:true))
        
        let operation = CKQueryOperation(query: query)

        operation.recordFetchedBlock = {(record : CKRecord) in
            
            var name : String
            var description : Array<String>
            var normalPrice : Double
            //var specials : Array<Special>
            //var currentPrice : Double
            //var gotCurrentPrice : Bool = false
            var restaurantReference : CKReference 
            
            if let testDrink = record.objectForKey("name") as? String, 
                let testDescription = record.objectForKey("Description") as? Array<String>,
                let testNormalPrices = record.objectForKey("normalPrices") as? Double,
                let testRestaurant = record.objectForKey("restaurant") as? CKReference
            
            {
                name = testDrink
                description = testDescription
                normalPrice = testNormalPrices
                restaurantReference = testRestaurant.
            
                restaurantReference = testRestaurant
                
                
            }else {
                return
            }
                self.drinks.append(Drink(name: name, description: description, normalPrice: normalPrice, restaurant: restaurantReference, specials: <#T##Array<Special>#>, currentPrice: <#T##Double#>, restaurantRef: <#T##CKReference#>, specialsRefs: <#T##Array<CKReference>#>))
    }
        
        
    
        
        func getAllSpecials() {
            
            let query = CKQuery(recordType: "Special", predicate: NSPredicate(value:true))
            
            let operation = CKQueryOperation(query: query)
            
            operation.recordFetchedBlock = {(record : CKRecord) in
                
                var drinkSpecialPrice : Double
                var drinkSpecialOFF : NSDate
                var drinkSpecialON : NSDate
                var drinkReference : CKReference
                
                //filter out only specials for current drink
                let predicate:NSPredicate = NSPredicate(format: "drink == drinkID")
                                
                if let testSpecialP = record.objectForKey("specialprice") as? Double, 
                    let testON = record.objectForKey("specialON") as? NSDate, 
                    let testOFF = record.objectForKey("specialOFF") as? NSDate,
                    let testDrink = record.objectForKey("Drink") as? CKReference{
                    
                    drinkSpecialPrice = testSpecialP
                    drinkSpecialOFF = testOFF
                    drinkSpecialON = testON
                    
                    
                    
                }else {
                    return
                    
                }
                
                self.restaurants.append(Restaurant(name: restaurantName, rDrinks: restaurantDrinks,location: restaurantLoc))
            }
            
        }



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
        
        //for (arrayval) in? drink.description 
          //  description.text = [arrayval]
        
            
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
    
    //func getAllDrinks(){
        
        
    //}
    
    //func getAllRestaurants() {
        
        
    //}
    
    //func getAllSpecials(){
        
        
    //}
    
    func fetchRestaurant(drinkRecordID : CKRecordID, restaurantRecordID : CKRecordID) {
        
        
        let operation = CKFetchRecordsOperation(recordIDs: [restaurantRecordID])
        
        operation.perRecordCompletionBlock = {( record : CKRecord?, recordID : CKRecordID?, error : NSError?) in
            var restaurantName = record!.objectForKey("name") as! String
            var restaurantFound = Restaurant(name:restaurantName)
            
            /*var drink = self.drinksDictionary[drinkRecordID]
            drink?.restaurant = restaurantFound
            self.restaurantDictionary[restaurantRecordID] = restaurantFound
            self.drinksDictionary[drinkRecordID] = drink
            self.restaurantsFound++
            */
        }
        
        publicDB.addOperation(operation)
        
    }
    
    /*
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
    */

    
    
    

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
       //func addSpecials() 
    
    
    // MARK: - Data Fetching -------- OLD
   
    


    
}

