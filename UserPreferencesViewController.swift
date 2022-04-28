//
//  UserPreferencesViewController.swift
//  myClassProject
//
//  Created by Travis howard on 4/21/22.
//

import UIKit

class UserPreferencesViewController: UIViewController {

    @IBOutlet weak var locationSegment: UISegmentedControl!
    @IBOutlet weak var locationTextBox: UITextField!
    @IBOutlet weak var sortSegment: UISegmentedControl!
    @IBOutlet weak var categorySegment: UISegmentedControl!
    
    var myRestaurants:restaurants!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //get default preferences
        let (locationPref, sortPref, categoriePref) = myRestaurants.getDefaultsPreferences()
        
        if locationPref == "current"{
            self.locationSegment.selectedSegmentIndex = 0
            self.locationSegmentChanged()
        }
        else{
            self.locationSegment.selectedSegmentIndex = 1
            self.locationTextBox.text = locationPref
            self.locationSegmentChanged()
        }
        
        if sortPref == "name"{
            self.sortSegment.selectedSegmentIndex = 0
        }
        else if sortPref == "distance"{
            self.sortSegment.selectedSegmentIndex = 1
        }
        else if sortPref == "price"{
            self.sortSegment.selectedSegmentIndex = 2
        }
        else if sortPref == "user"{
            self.sortSegment.selectedSegmentIndex = 3
        }
        
        if categoriePref == true{
            self.categorySegment.selectedSegmentIndex = 0
        }
        else if categoriePref == false{
            self.categorySegment.selectedSegmentIndex = 1
        }
    }
    
    
    @IBAction func locationSegmentChange(_ sender: UISegmentedControl) {
        locationSegmentChanged()
    }
    
    func locationSegmentChanged(){
        
        if locationSegment.selectedSegmentIndex == 0{ //current location
            locationTextBox.isUserInteractionEnabled = false
            locationTextBox.backgroundColor = UIColor.systemGray3
            locationTextBox.text = ""
            locationTextBox.placeholder = ""
        }
        
        else if locationSegment.selectedSegmentIndex == 1{ //custom location
            locationTextBox.isUserInteractionEnabled = true
            locationTextBox.backgroundColor = UIColor.white
            locationTextBox.placeholder = "enter zip code, city/state, etc."
        }
        
    }
    
    //when user wants to save prefernces
    @IBAction func savePreferences(_ sender: UIButton) {
        
        var locationPref:String?
        var sortPref:String?
        var categoryPref:Bool?
        let locationIndex = locationSegment.selectedSegmentIndex
        let sortIndex = sortSegment.selectedSegmentIndex
        let catIndex = categorySegment.selectedSegmentIndex
        
        if locationIndex == 0{
            locationPref = "current"
        }
        else if locationIndex == 1{
            locationPref = locationTextBox.text
        }
        
        if sortIndex == 0{
            sortPref = "name"
        }
        else if sortIndex == 1{
            sortPref = "distance"
        }
        else if sortIndex == 2{
            sortPref = "price"
        }
        else if sortIndex == 3{
            sortPref = "user"
        }
        
        if catIndex == 0{
            categoryPref = true
        }
        else if catIndex == 1{
            categoryPref = false
        }
        
        myRestaurants.delete_all_CoreData(entityName: "UserPrefs")
        myRestaurants.save_preferences_CoreData(location: locationPref!, sort: sortPref!, categories: categoryPref!)
        myRestaurants.initialLoad_coreData(type: "pref")
        self.present(ViewController.displayErrorMessage(message: "Your preferences were saved!", title: "Save Successful!"), animated: true) //show alert
        
    }
    
}
