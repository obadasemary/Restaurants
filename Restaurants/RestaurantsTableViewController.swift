//
//  RestaurantsTableViewController.swift
//  Restaurants
//
//  Created by Abdelrahman Mohamed on 6/5/16.
//  Copyright © 2016 Abdelrahman Mohamed. All rights reserved.
//

import UIKit
import MapKit

class RestaurantsTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var resturants = [NSDictionary]()
    let locationManager = CLLocationManager()
    var userLocation: CLLocation?
    var distanceInKM: String?
    
    // 25.285646
    // 51.535406

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=25.290998,51.533949&radius=1000&type=restaurant&key=AIzaSyALMZHpV3BlxC5hVltOaPyDujPul-6RTdc"
        
        downloadRestaurants(url) { (array) in
            
            self.resturants = array as! [NSDictionary]
         
            self.tableView.reloadData()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        locationManager.stopUpdatingLocation()
        print(error)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resturants.count
    }

   
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        
        cell.textLabel?.text = resturants[indexPath.row]["name"] as? String
        
        let restaurantLat = resturants[indexPath.row]["geometry"]!["location"]!!["lat"] as? Double
        let restaurantLong = resturants[indexPath.row]["geometry"]!["location"]!!["lng"] as? Double
        
        
        let distanceKM: String? = getRestaurantDistance(restaurantLat!, long: restaurantLong!)
//
//        print("lat \(restaurantLat)")
//        print(restaurantLong)
        
        cell.detailTextLabel?.text = "\(distanceKM!) KM"
        distanceInKM = distanceKM
        
        return cell
    }
    
    // MARK: - Networking

    func downloadRestaurants(urlString: String, complethionHandler:(array: NSArray) -> ()) {
        
        var restaurantsList = [NSDictionary]()
        
        let url = NSURL(string: urlString)
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) in
            
            do {
                
                let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                
                let list = jsonDictionary["results"] as! NSArray
                
                for restaurant in list {
                    
                    restaurantsList.append(restaurant as! NSDictionary)
                }
                
                dispatch_async(dispatch_get_main_queue(), { 
                    
                    complethionHandler(array: restaurantsList)
                })
                
            } catch {
                print("invalid json format")
            }
        }
        task.resume()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        userLocation = locations[0]
        let long = userLocation!.coordinate.longitude;
        let lat = userLocation!.coordinate.latitude;
        //Do What ever you want with it
        print("long = \(long)")
        print("lat = \(lat)")
        
        self.tableView.reloadData()
    }

    
    func getRestaurantDistance(lat: Double, long: Double) -> String {
        
        var distanceLocationStr:String?
        
        //restaurant's location
        let restaurantLocation = CLLocation(latitude: lat, longitude: long)
        
        var distance:CLLocationDistance?
        
        distance = userLocation?.distanceFromLocation(restaurantLocation)
        
        let distanceKM = NSString(format: "%.2f", distance! / 100)
        
        distanceLocationStr = String(distanceKM)
        
        
        return distanceLocationStr!

    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "seeDetails" {
            
            let index = tableView.indexPathForSelectedRow
            let resturantSelected = resturants[index!.row]
            
            let restaurantVC = segue.destinationViewController as! RestaurantViewController
            restaurantVC.restaurant = resturantSelected
            restaurantVC.distanceInKM = distanceInKM
        }
    }
}
