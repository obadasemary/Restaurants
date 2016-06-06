//
//  RestaurantViewController.swift
//  Restaurants
//
//  Created by Abdelrahman Mohamed on 6/5/16.
//  Copyright © 2016 Abdelrahman Mohamed. All rights reserved.
//

import UIKit
import MapKit

class RestaurantViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var openLabel: UILabel!
    
    
    var restaurant: NSDictionary?
    var distanceInKM: String?
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let restautantName = restaurant!["name"]! as? String
        
        self.title = restautantName
        let latitude = restaurant!["geometry"]!["location"]!!["lat"] as! Double
        let longitude = restaurant!["geometry"]!["location"]!!["lng"] as! Double
        
//        print("Latitude: \(latitude)")
//        print("Longitude: \(longitude)")
        
        let latDelta: CLLocationDegrees = 0.01
        let longDelta: CLLocationDegrees = 0.01
        
        let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        map.setRegion(region, animated: true)
        
        // pin & Annotation
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = restautantName
        annotation.subtitle = restaurant!["vicinity"]! as? String
        
        map.addAnnotation(annotation)
        
        // restaurant's information
        
        nameLabel.text = restautantName
        
        if restaurant!["opening_hours"] != nil {
            
            let isOpen = restaurant!["opening_hours"]!["open_now"]! as? Bool
            
            if (isOpen != nil) {
                openLabel.text = "Open Now!"
                openLabel.textColor = UIColor.greenColor()
            } else {
                openLabel.text = "Close Now!"
                openLabel.textColor = UIColor.redColor()
            }
        } else {
            openLabel.text = "Close Now!"
            openLabel.textColor = UIColor.redColor()
        }
        
        distanceLabel.text = "\(distanceInKM!) KM"

        
        // golocation
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        map.showsUserLocation = true
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
