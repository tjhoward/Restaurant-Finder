//
//  ViewController.swift
//  myClassProject
//
//  Created by Travis howard on 3/15/22.
//

import UIKit

class ViewController: UIViewController {
    

    //The saved restaurants
    var myRestaurants:restaurants = restaurants()

    override func viewDidLoad() {
        super.viewDidLoad()
        //Load saved model
        
    }
    
    //When we are about to go to a new view via segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //check name of segue
        if segue.identifier == "toAddRestaurant"{
            
            //our destination is the add restaurants view controller
            let des = segue.destination as! AddRestaurantViewController
            
            //set week for controller
            des.myRestaurants = myRestaurants

        }
        else if segue.identifier == "toViewSavedRestaurants"{
            
            //our destination is the view saved restaurants view controller
            let des = segue.destination as! ViewSavedRestaurantsViewController
            
            //set week for controller
            des.myRestaurants = myRestaurants

        }
        
   
    }
    
    //when we return to the starting view controller from the other view controllers
    //**ui bar button in second view must be connected to segue (far right icon) *segue and unwind
    @IBAction func fromOtherVCs(segue: UIStoryboardSegue){
        
        //check if the view controller we came from was the enterHealth view controller
        if let sourceViewController = segue.source as? AddRestaurantViewController{
            
            //update the  current restaurants
            let dataReceived = sourceViewController.myRestaurants
            myRestaurants = dataReceived
            //print("From add rest")
   
        }
        
        else if let sourceViewController = segue.source as? ViewSavedRestaurantsViewController{
            
            //update the  current restaurants
            let dataReceived = sourceViewController.myRestaurants
            myRestaurants = dataReceived
           // print("From view saved")
        }

        
    }


}

