//
//  AddRestaurantViewController.swift
//  myClassProject
//
//  Created by Travis howard on 3/15/22.
//

import UIKit
import WebKit
import CoreLocation

class AddRestaurantViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchBox: UITextField!
    @IBOutlet weak var locationBox: UITextField!
    @IBOutlet weak var locationSegmentController: UISegmentedControl!
    @IBOutlet weak var addRestaurantsTable: UITableView!
    @IBOutlet weak var sortSegmentController: UISegmentedControl!
    @IBOutlet weak var sortingLabel: UILabel!
    
    var myRestaurants:restaurants! //restaurant model
    var userLocationManager:userLocation! //Manages user location
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //preferences
        if myRestaurants.default_locationPref == "current"{
            self.locationSegmentController.selectedSegmentIndex = 0
            locationSegmentChanged()
        }
        else{
            self.locationSegmentController.selectedSegmentIndex = 1
            self.locationBox.text = myRestaurants.default_locationPref
            locationSegmentChanged()
        }
        
        if myRestaurants.default_sortType == "name"{
            self.sortSegmentController.selectedSegmentIndex = 0
        }
        else if myRestaurants.default_sortType == "distance"{
            self.sortSegmentController.selectedSegmentIndex = 1
        }
        else if myRestaurants.default_sortType == "price"{
            self.sortSegmentController.selectedSegmentIndex = 2
        }
        else if myRestaurants.default_sortType == "user"{
            self.sortSegmentController.selectedSegmentIndex = 3
        }

        //make cells larger
        self.addRestaurantsTable.rowHeight = 100
       
        //sort
        sortLists()
       
    }
    
    
    //when value changes on segmented controller
    @IBAction func locationSegmentChange(_ sender: UISegmentedControl) {
        
        locationSegmentChanged()
    }
    
    
    func locationSegmentChanged(){
        
        if locationSegmentController.selectedSegmentIndex == 0{ //current location
            locationBox.isUserInteractionEnabled = false
            locationBox.backgroundColor = UIColor.systemGray3
            locationBox.text = ""
            locationBox.placeholder = ""
        }
        
        else if locationSegmentController.selectedSegmentIndex == 1{ //custom location
            locationBox.isUserInteractionEnabled = true
            locationBox.backgroundColor = UIColor.white
            locationBox.placeholder = "enter zip code, city/state, etc."
        }
        
    }
    
    //Get longitude and latitude for custom location
    func getCustomLocation(){
        
        let geocoder = CLGeocoder()
        let address = locationBox.text
        CLGeocoder().geocodeAddressString(address!, completionHandler:
                                            {(placemarks, error) in
            
            if error != nil{
                self.present(ViewController.displayErrorMessage(message: "Try again", title: "Invalid Location"), animated: true) //show alert
            }
            else if placemarks!.count > 0{
                let placemark = placemarks![0]
                let location = placemark.location
                let coords = location!.coordinate
                let (customLat, customLong) = (coords.latitude, coords.longitude)
                self.userLocationManager.updateCustomLatitudeLongitude(lat: customLat, long: customLong)
                
                //Create location - pass user lat and long
                let location2 = CLLocation(latitude: customLat, longitude: customLong)
                
                CLGeocoder().reverseGeocodeLocation(location2){(placemarks, error) in
                    self.processResponse(withPlacemarks: placemarks, error: error)
                }
            }
            
        })
    }
    
    
    //Get users location
    func processRequest_location(){
        
        let locationSegmentIndex = locationSegmentController.selectedSegmentIndex
        
        if locationSegmentIndex == 1{ //custom location
            getCustomLocation()
            
        }
        
        else if locationSegmentIndex == 0{ //current location
            
            let (userLat,userLong) = self.userLocationManager.getLatitudeLongitude(type: locationSegmentIndex)
            let location = CLLocation(latitude: userLat!, longitude: userLong!)
            
            CLGeocoder().reverseGeocodeLocation(location){(placemarks, error) in
                self.processResponse(withPlacemarks: placemarks, error: error)
            }
        }

    }
    
    
    //process response when trying to get user location
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?){
        
        if let error = error{
            print("unable to reverse geocode location")
        }
        else{
            
            if (placemarks?.count)! > 0{ // if placemark count is > 0 we have at least 1 location
                
                let city = placemarks?[0].locality
                let state = placemarks?[0].administrativeArea
                
                let current_location = "\(city!),\(state!)" //set location
                userLocationManager.updateCurrentLocation(location: current_location)
                
                processRequest_apiCall() //make web api call after getting location
              
                
            }
        }
        
        
    }
    
    
    //when user presses search button
    @IBAction func searchButton(_ sender: UIButton) {
        
        //first, get the correct location. Then after location is found, call web service
        if userLocationManager.isLocationServiceEnabled() == true{ //get location
            processRequest_location()
        }
        else{
            self.present(ViewController.displayErrorMessage(message: "Location Service down.", title: "Service Unavailable!"), animated: true) //show alert
        }
    }
    
    
    //After we have gotten the location, we can attempt to call the api
    func processRequest_apiCall() {
        
        //clear previous search results if there were any
        myRestaurants.deleteAllSearchResultRestaurants()
        
        var returned_businesess:[Business]?
        
        //variables to store response from Yelp Web API which will be passed to Model
        var image_urlString:String?
        var image_url:URL?
        var error_occured:Bool?
        var error_occured_invalid:Bool?
        let decoder = JSONDecoder()
        let data = searchBox.text! //users search term
        let locationSegment = self.locationSegmentController.selectedSegmentIndex
        
        let current_location = userLocationManager.getCurrentLocation()
        //get a list of businsses and their IDs
        let urlAsString = "https://api.yelp.com/v3/businesses/search?location=\(current_location!)&term=\(data)&categories=restaurants"
        
        
        
        let (urlSession, request) = myRestaurants.createUrlSession(urlAsString: urlAsString)
        
        if urlSession == nil || request == nil{
            self.present(ViewController.displayErrorMessage(message: "Please Try Again", title: "Invalid Input"), animated: true) //show alert
            
            return
        }
        
            let jsonQuery = urlSession!.dataTask(with: request!, completionHandler: {data, response, error -> Void in
                
                if error != nil{
                    print(error!.localizedDescription)
                }
                
                let jsonResult_error = try? decoder.decode(restaurantResults_ERROR.self, from: data!)
                
                //If error was returned from JSON request
                if let res = jsonResult_error{
                    
                    error_occured = true
                }
                
                let jsonResult = try? decoder.decode(restaurantResults.self, from: data!)
                
                    if jsonResult != nil{
                        
                        if jsonResult!.businesses.count > 0{
                            
                            returned_businesess = jsonResult!.businesses
                            
                            for bus in returned_businesess!{
                                
                                var img:Data?
                                image_urlString = bus.image_url //get business main photo
                                image_url = URL(string: image_urlString!) // get url
                            
                                if let valid_image_url = image_url{      //see if url is valid
                                    
                                    //if image is valid
                                    if let img_data = try? Data(contentsOf: valid_image_url){
                                        img = img_data
                                    }
                                }
                                
                                //save search result restaurant
                                self.myRestaurants.saveSearchResultRestaurant(name: bus.name, ID: bus.id, image: img, rating: bus.rating!, price: bus.price, distance: bus.distance!, latitude: bus.coordinates.latitude!, longitude: bus.coordinates.longitude!)
                                
                                let (userLat,userLong) = self.userLocationManager.getLatitudeLongitude(type: locationSegment)
                                //update distances for search result restaurants
                                self.myRestaurants.updateDistances(type:"search", userLat: userLat!,userLong: userLong!)
                               
                            }
                            
                        }
                        else{
                            error_occured = true
                        }
                         
                        
                    }
                else{
                    error_occured_invalid = true
                }

            
                DispatchQueue.main.async { //after recquest is done processing this is done
                
                    if error_occured == true{
                        self.present(ViewController.displayErrorMessage(message: "Please Try Again", title: "Invalid Input"), animated: true) //show alert
                        return
                    }
                    else if error_occured_invalid == true{ //when json response is nulL
                        
                        self.present(ViewController.displayErrorMessage(message: "Please Try Again", title: "No Results!"), animated: true) //show alert
                        return
                        
                    }
                    else{
                        self.sortLists() //sort then display search result restaurants
                    }
                    
                }
                
            })
            jsonQuery.resume()
    }
    
    
    //number of rows in table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myRestaurants.getCount(type: "search")
    }
    
    
    //generating the table rows
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        // add each row
        let cell = tableView.dequeueReusableCell(withIdentifier: "addRestaurantsCell", for: indexPath)
        cell.layer.borderWidth = 1.0
        cell.textLabel?.text = myRestaurants.getSearchResultRestaurantName(index: indexPath.row) // get cell name/text
        let picture = myRestaurants.getRestaurantImage_searchResults(index: indexPath.row)
        
        //get image for cell
        if picture != nil {
            cell.imageView?.image =  UIImage(data: picture!  as Data)
            
        } else {
            cell.imageView?.image = nil
        }
        
        return cell
    }
    
    
    //When we are about to go to a new view via segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //check name of segue
        if segue.identifier == "toAddRestaurantsDetailsView"{
            
            //get selected table object
            let selectedIndex: IndexPath = self.addRestaurantsTable.indexPath(for: sender as! UITableViewCell)!
            
            //our destination is the AddRestaurantsDetailsViewController
            let des = segue.destination as! AddRestaurantDetailsViewController
            
            //make sure the view has the current list of saved restaurants
            des.myRestaurants = myRestaurants
            des.userLocationManager = userLocationManager
            des.locationSegmentIndex = locationSegmentController.selectedSegmentIndex
            
            //set search restaurant for the details page
            des.search_result_restaurant = myRestaurants.getRestaurant_searchResults(index: selectedIndex.row)
        }
    }
    
    
    //when we return to the add restaurant view controller from the add restaurant details page
    @IBAction func fromAddDetails(segue: UIStoryboardSegue){
        
        //check if the view controller we came from was the add details view controller
        if let sourceViewController = segue.source as? AddRestaurantDetailsViewController{
            
            //update current restaurants and reload table
            let dataReceived = sourceViewController.myRestaurants
            myRestaurants = dataReceived
            
            let dataRecieved2 = sourceViewController.userLocationManager
            userLocationManager = dataRecieved2!
            
            addRestaurantsTable.reloadData()
            
   
        }
    }
    
    
    //when user changes the type of sort
    @IBAction func sortTypeChanged(_ sender: Any) {
        
        self.sortLists()
    }
    
    
    //when lists need to be sorted
    func sortLists(){
        
        let num_search_restaurants = myRestaurants.getCount(type: "search")
        
        if num_search_restaurants > 0{
            
            if sortSegmentController.selectedSegmentIndex == 0{
            
                    //sort alphabetically
                    myRestaurants.sort_alphabetical(type: "search", show_category: false)
                    self.sortingLabel.text = "(alphabetically)"
            }
            else if sortSegmentController.selectedSegmentIndex == 1{
                
                    //sort by distance
                    myRestaurants.sort_distance(type: "search", show_category: false)
                    self.sortingLabel.text = "(shortest distance from search location)"
            }
            else if sortSegmentController.selectedSegmentIndex == 2{
                
                    //sort by price
                    myRestaurants.sort_price(type: "search", show_category: false)
                    self.sortingLabel.text = "(lowest price)"
            }
            else if sortSegmentController.selectedSegmentIndex == 3{
                
                    //sort by user rating
                    myRestaurants.sort_rating(type: "search", show_category: false)
                    self.sortingLabel.text = "(highest user rating)"
            }
            addRestaurantsTable.reloadData() //reload after sort
        }
        else{
            self.sortingLabel.text = ""
        }
    }

}
