//
//  AddRestaurantDetailsViewController.swift
//  myClassProject
//
//  Created by Travis howard on 3/18/22.
//

import UIKit
import CoreLocation
import MapKit

class AddRestaurantDetailsViewController: UIViewController{
    
    @IBOutlet weak var restaurant_images: UIImageView!
    @IBOutlet weak var restaurant_address: UITextField!
    @IBOutlet weak var restaurant_phone: UITextField!
    @IBOutlet weak var restaurant_rating: UITextField!
    @IBOutlet weak var restaurant_open: UITextField!
    @IBOutlet weak var restaurant_nameTitle: UINavigationBar!
    
    
    var myRestaurants:restaurants! //The saved restaurants
    var userLocationManager:userLocation! //Manages user location
    var locationSegmentIndex:Int? // 0 = current , 1 = custom
    
    //the search result restaurant that we clicked on
    var search_result_restaurant:restaurant?


    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //make api request to get full details on business
        requestRestaurantData()
    }
    

    //Get map directions
    @IBAction func mapDirectionsButton(_ sender: UIButton) {
        
        let (userLat,userLong) = self.userLocationManager.getLatitudeLongitude(type: self.locationSegmentIndex!)
        
        if userLat != nil && userLong != nil{
            requestUserLocation()
        }
        else{
            self.present(ViewController.displayErrorMessage(message: "Try again later", title: "Location Service Error"), animated: true) //show alert
            
        }
    }
    
    
    //get user current location
    func requestUserLocation(){
        
        let (userLat,userLong) = self.userLocationManager.getLatitudeLongitude(type: self.locationSegmentIndex!)
        let location = CLLocation(latitude: userLat!, longitude: userLong!)
        
        CLGeocoder().reverseGeocodeLocation(location){(placemarks, error) in
            self.processResponse(withPlacemarks: placemarks, error: error)
        }
        
    }
    
    
    
    //process response when trying to get user location
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?){
        
        if let error = error{
            print(error)
        }
        else{
            
            if (placemarks?.count)! > 0{ // if placemark count is > 0 we have at least 1 location
                
                let city = placemarks?[0].locality
                let state = placemarks?[0].administrativeArea
                
                let user_current_location = "\(city!),\(state!)" //set location
                userLocationManager.updateCurrentLocation(location: user_current_location)
                getMapDirections()
                
                
            }
        }
        
    }
    
    
    
    //Get directions for map
    func getMapDirections(){
        
        let (lat, long) = self.myRestaurants.getCurrentRestaurantLatitudeLongitude()
        let (userLat,userLong) = self.userLocationManager.getLatitudeLongitude(type: self.locationSegmentIndex!)
        let destinationCoords = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let coords = CLLocationCoordinate2D(latitude: userLat!, longitude: userLong!)
        let destination_location = self.myRestaurants.current_restaurant!.restaurant_address
        let user_current_location = userLocationManager.getCurrentLocation()
        
        ViewController.showMap(coords: coords, destinationCoords: destinationCoords, user_current_location: user_current_location!, destination_location: destination_location!)
    }
    
    
    //request the restaurant data
    func requestRestaurantData(){
    
        //let ID = myrestaurants.getcurrentrestaurantID()
        let urlAsString = "https://api.yelp.com/v3/businesses/\(search_result_restaurant!.restaurant_ID!)"
        let decoder = JSONDecoder()
        var name: String?
        var image_url:URL?
        var address:String?
        var phone:String?
        var rating:Float?
        var ID:String?
        var price:String?
        var distance:Float?
        var latitude:Float?
        var longitude:Float?
        
        var images:[Data] = []
        let (urlSession, request) = myRestaurants.createUrlSession(urlAsString: urlAsString)
        
        if urlSession == nil || request == nil{
            self.present(ViewController.displayErrorMessage(message: "Please Try Again", title: "Invalid Input"), animated: true) //show alert
            return
        }
        
        let jsonQuery = urlSession!.dataTask(with: request!, completionHandler: {data, response, error -> Void in
            
            if error != nil{
                print(error!.localizedDescription)
            }
            
            let jsonResult = try? decoder.decode(restaurantResults_Detailed.self, from: data!)
            
            if jsonResult != nil{
                
                name = jsonResult!.name
                
                var a1:String = "" //address values
                var a2:String = ""
                var a3:String = ""
                
                //check for null values
                if jsonResult!.location.address1 != nil{
                    a1 = jsonResult!.location.address1!
                }
                if jsonResult!.location.address2 != nil{
                    a2 = jsonResult!.location.address2!
                }
                if jsonResult!.location.address3 != nil{
                    a3 = jsonResult!.location.address3!
                }
                
                
                address = "\(a1) \(a2) \(a3), \(jsonResult!.location.city!),\(jsonResult!.location.state!) \(jsonResult!.location.zip_code!)"
               
                phone = jsonResult!.display_phone!
                rating = jsonResult!.rating!
                ID = jsonResult!.id!
                price = jsonResult!.price
                latitude = jsonResult!.coordinates.latitude
                longitude = jsonResult!.coordinates.longitude
            
                
                let image_urls:[String] = jsonResult!.photos
                
                //create array of images
                for im in image_urls{
                    
                    image_url = URL(string: im) // get url
                    
                    //see if url is valid
                    if let valid_image_url = image_url{
                        
                    
                        //if image is valid, add it to array
                        if let img_data = try? Data(contentsOf: valid_image_url){ 
                            images.append(img_data)
                        }
                    }
                }
                
            }
            
            //get restaurant details and set them as current restaurant
            DispatchQueue.main.async {
   
                let (userLat,userLong) = self.userLocationManager.getLatitudeLongitude(type: self.locationSegmentIndex!)
                distance = self.myRestaurants.getDistance(rest_latitude: latitude!, rest_longitude: longitude!, userLat: userLat!, userLong: userLong!)
                
                //set values for current restaurant
                self.myRestaurants.setCurrentRestaurant(name: name, images: images, address: address, phone: phone, rating: rating, ID: ID, price: price, distance: distance, latitude: latitude, longitude: longitude, index: 0, category: 0)
                let currentRestaurant = self.myRestaurants.getCurrentRestaurant()
                //set values for detail page
                self.restaurant_nameTitle.topItem?.title = name
                self.restaurant_address.text = address
                self.restaurant_phone.text = currentRestaurant.restaurant_phone//phone
                self.restaurant_rating.text = String(rating!) + "/5.0"
                
                if jsonResult!.hours![0].is_open_now! == true{
                    self.restaurant_open.text = "OPEN"
                }
                else{
                    self.restaurant_open.text = "CLOSED"
                }
                
                //get image data
                let img_data = self.myRestaurants.getCurrentRestaurantImage(type: 0)
                
                //check if valid image
                if let img = UIImage(data: img_data!){
                
                    self.restaurant_images.image = img
                }
                
            }
            
        })

        jsonQuery.resume() //start call
        
    }
    
    
    //when user wantas to save restaurant entry
    @IBAction func saveRestaurantButton(_ sender: UIButton) {
        
        //get current restaurnt and set values
        let currentRestaurant = myRestaurants.getCurrentRestaurant()
        let name = currentRestaurant.restaurant_name
        let imgs = currentRestaurant.restaurant_images
        let address = currentRestaurant.restaurant_address
        let phone = currentRestaurant.restaurant_phone
        let rating = currentRestaurant.restaurant_rating
        let ID = currentRestaurant.restaurant_ID
        let price = currentRestaurant.restaurant_price
        let distance = currentRestaurant.restaurant_distance //*******
        let latitude = currentRestaurant.restaurant_latitude
        let longitude = currentRestaurant.restaurant_longitude
        var alreadyExists:Bool = false
        

        alreadyExists = myRestaurants.saveRestaurant(name: name!, images: imgs, address: address!, phone: phone!, rating: rating!, ID: ID!, price: price!, distance: distance!, latitude: latitude!, longitude: longitude!)
        
        if alreadyExists == false{
            self.present(ViewController.displayErrorMessage(message: "Restaurant Saved to your list!!", title: "Save Successful!"), animated: true) //show alert
        }
        else if alreadyExists == true{
            self.present(ViewController.displayErrorMessage(message: "Restaurant is already saved!!", title: "Already Saved"), animated: true) //show alert
        }

    }
    
    
    //show next image of current restaurant
    @IBAction func nextImage(_ sender: UIButton) {
        
        //get image data
        let img_data = self.myRestaurants.getCurrentRestaurantImage(type: 1)
        
        if img_data != nil {
            
           let img = UIImage(data: img_data!)
           self.restaurant_images.image = img
            
        }
    }
    
    
    //show previous image of current restaurant
    @IBAction func previmage(_ sender: UIButton) {
        
        //get image data
        let img_data = self.myRestaurants.getCurrentRestaurantImage(type: 2)
        
        if img_data != nil{
            let img = UIImage(data: img_data!)
            self.restaurant_images.image = img
            
        }
    }
    
    
    //When we are about to go to a new view via segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //check name of segue
        if segue.identifier == "toUserReviewsAD"{
    
            //our destination is the ViewSavedRestaurantsDetailsViewController
            let des = segue.destination as! UserReviewsViewController
            
            //update model
            des.myRestaurants = myRestaurants
            des.restaurantID = myRestaurants.getCurrentRestaurant().restaurant_ID!
        }
   
    }
    
    //when we return to the starting view controller from the other view controllers
    @IBAction func fromUserReview(segue: UIStoryboardSegue){
        
    }
    
    
}
