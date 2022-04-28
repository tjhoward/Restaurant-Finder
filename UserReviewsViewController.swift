//
//  UserReviewsViewController.swift
//  myClassProject
//
//  Created by Travis howard on 4/16/22.
//

import UIKit

class UserReviewsViewController: UIViewController {

    
    @IBOutlet weak var name1Label: UILabel!
    @IBOutlet weak var rating1label: UILabel!
    @IBOutlet weak var review1: UITextView!
    @IBOutlet weak var review1Link: UIButton!
    @IBOutlet weak var name2label: UILabel!
    @IBOutlet weak var rating2label: UILabel!
    @IBOutlet weak var review2: UITextView!
    @IBOutlet weak var review2Link: UIButton!
    @IBOutlet weak var name3label: UILabel!
    @IBOutlet weak var rating3label: UILabel!
    @IBOutlet weak var review3: UITextView!
    @IBOutlet weak var review3Link: UIButton!
    
    var myRestaurants:restaurants! //store and manage restaurants
    var restaurantID:String?
    var reviewLink1:String?
    var reviewLink2:String?
    var reviewLink3:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //make api request
        requestReviews()
    }
    
    //request review data. Web service limits us to only 3 review excerpts
    func requestReviews(){
    
        let urlAsString = "https://api.yelp.com/v3/businesses/\(restaurantID!)/reviews"
        let decoder = JSONDecoder()
        var name1:String?
        var rating1:String?
        var review1:String?
        var name2:String?
        var rating2:String?
        var review2:String?
        var name3:String?
        var rating3:String?
        var review3:String?
    
        let (urlSession, request) = myRestaurants.createUrlSession(urlAsString: urlAsString)
        
        if urlSession == nil || request == nil{
            self.present(ViewController.displayErrorMessage(message: "Please Try Again", title: "Invalid Input"), animated: true) //show alert
            return
        }
        
        let jsonQuery = urlSession!.dataTask(with: request!, completionHandler: {data, response, error -> Void in
            
            if error != nil{
                print(error!.localizedDescription)
            }
            
            let jsonResult = try? decoder.decode(restaurantResults_Reviews.self, from: data!)
            
            if jsonResult != nil{
                
                let reviews = jsonResult!.reviews
                
                if reviews.count > 0{
                    
                    var index = 1
                    for rev in reviews{
                        
                        if index == 1{
                            name1 = rev.user.name
                            rating1 = String(rev.rating)
                            review1 = rev.text
                            self.reviewLink1 = rev.url
                        }
                        else if index == 2{
                            name2 = rev.user.name
                            rating2 = String(rev.rating)
                            review2 = rev.text
                            self.reviewLink2 = rev.url
                        }
                        else if index == 3{
                            name3 = rev.user.name
                            rating3 = String(rev.rating)
                            review3 = rev.text
                            self.reviewLink3 = rev.url
                        }
                        index += 1
                    }
                    
                }
                
     
                
            }
            
            //get restaurant details and set them as current restaurant
            DispatchQueue.main.async {
   
                self.name1Label.text = name1
                self.rating1label.text = "Rating: " + rating1! + " / 5"
                self.review1.text = review1
                
                self.name2label.text = name2
                self.rating2label.text = "Rating: " + rating2! + " / 5"
                self.review2.text = review2
                
                self.name3label.text = name3
                self.rating3label.text = "Rating: " + rating3! + " / 5"
                self.review3.text = review3
                
            }
            
        })

        jsonQuery.resume() //start call
        
    }
    
    
    //When user clicks button to see full reviews
    @IBAction func review1Clicked(_ sender: Any) {
        
        if reviewLink1 != nil{
            let urlLink = URL(string: reviewLink1!)
            
            if urlLink != nil{
            UIApplication.shared.openURL(urlLink!)
            }
        }
    }
    
    
    @IBAction func review2Clicked(_ sender: Any) {
        
        if reviewLink2 != nil{
            let urlLink = URL(string: reviewLink2!)
            
            if urlLink != nil{
            UIApplication.shared.openURL(urlLink!)
            }
        }
    }
    
    
    @IBAction func review3Clicked(_ sender: Any) {
        
        if reviewLink3 != nil{
            let urlLink = URL(string: reviewLink3!)
            
            if urlLink != nil{
            UIApplication.shared.openURL(urlLink!)
            }
        }
    }
    

}
