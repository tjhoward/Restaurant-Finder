//
//  userLocation.swift
//  myClassProject
//
//  Created by Travis howard on 4/22/22.
//

import Foundation
import CoreLocation

//Handles user location
class userLocation: NSObject, CLLocationManagerDelegate{
    
    var manager:CLLocationManager = CLLocationManager()
    var currentLocation:String? //the user location in city,state format
    var user_current_latitude:Double?
    var user_current_longitude:Double?
    var user_custom_latitude:Double?
    var user_custom_longitude:Double?
    
    
    override init(){
        
        super.init()
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.distanceFilter = 0.1
        self.manager.requestWhenInUseAuthorization()
        
        
    }
    
    //Get user latitude and longitude. index 0 = current , index 1 = custom
    func getLatitudeLongitude(type:Int)-> (lat:Double?, long:Double?){
        
        if type == 0 || (user_custom_latitude == nil || user_custom_longitude == nil) {
            return (user_current_latitude!, user_current_longitude!)
        }
        else{
            return (user_custom_latitude!, user_custom_longitude!)
        }
    }
    
    //Update custom lat/long
    func updateCustomLatitudeLongitude(lat:Double, long:Double){
        
        user_custom_latitude = lat
        user_custom_longitude = long
    }
    
    //Update current location
    func updateCurrentLocation(location:String){
        currentLocation = location
    }
    
    func getCurrentLocation()->String?{
        return currentLocation
    }
    
    //Track CURRENT location. returns array of locations, where location[0] is the most recent location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {        
    
        let userLocation:CLLocation = locations[0]
        self.user_current_latitude = Double( userLocation.coordinate.latitude)
        self.user_current_longitude = Double( userLocation.coordinate.longitude)
        
    }
    
    //when authorization changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.manager.startUpdatingLocation()
    }
    
    
    //If error occured with location manager
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if isLocationServiceEnabled() == false{
            print("LOCATION SERVICE NOT ENABLED")
        }
    }
    
    //checks if location service is active
    func isLocationServiceEnabled() -> Bool{
        
        if CLLocationManager.locationServicesEnabled(){
            
            switch(CLLocationManager.authorizationStatus()){
                
            case .notDetermined, .restricted, .denied:
                return true
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            default:
                return false
                
            }
        }
        else{
            return false
        }
    }
    
}
