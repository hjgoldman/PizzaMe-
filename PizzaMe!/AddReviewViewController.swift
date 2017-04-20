//
//  AddReviewViewController.swift
//  PizzaMe!
//
//  Created by Hayden Goldman on 4/20/17.
//  Copyright © 2017 Hayden Goldman. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import RxSwift
import RxCocoa


class AddReviewViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    @IBOutlet weak var reviewTextTextView: UITextView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ratingPickerView: UIPickerView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var imageArray: [UIImage] = [UIImage(named: "1_stars.png")!, UIImage(named: "2_stars.png")!,UIImage(named: "3_stars.png")!,UIImage(named: "4_stars.png")!,UIImage(named: "5_stars.png")!]
    var selectedRowIndex :Int!
    var selectedRating :Int!
    var tacoLocationPlace_id :String!
    var reviews = [Any]()
    var tacoLocationDetail = LocationDetail()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reviewTextTextView.delegate = self
        self.nameTextField.delegate = self
        self.ratingPickerView.delegate = self
        self.ratingPickerView.dataSource = self
        // Input data into the Array:
        
        self.getFireBaseReviews()
        self.populateView()
    }
    
    
    func populateView() {
        
        self.nameLabel.text = self.tacoLocationDetail.name
    }
    
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        
        if self.selectedRowIndex == nil {
            self.selectedRating = 1
        } else if self.selectedRowIndex == 0 {
            self.selectedRating = 1
        } else if self.selectedRowIndex == 1 {
            self.selectedRating = 2
        } else if self.selectedRowIndex == 2 {
            self.selectedRating = 3
        } else if self.selectedRowIndex == 3 {
            self.selectedRating = 4
        } else if self.selectedRowIndex == 4 {
            self.selectedRating = 5
        }
        
        if self.nameTextField.text == "" {
            let alertController = UIAlertController(title: "Oops!", message: "Enter your name.", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel) {
                UIAlertAction in
            }
            alertController.addAction(dismissAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            
            if self.reviewTextTextView.text == "" {
                
                let alertController = UIAlertController(title: "Opps!", message:  "Please enter a review.", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel) {
                    UIAlertAction in
                }
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                
                self.saveReviewToFireBase()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //MARK: Post and Get FireBase Data
    
    private func getFireBaseReviews() {
        
        let ref = FIRDatabase.database().reference(withPath: "reviews")
        ref.observe(.value) { (snapshot :FIRDataSnapshot) in
            
            let locationInDB = snapshot.childSnapshot(forPath: self.tacoLocationPlace_id!)
            
            if locationInDB.exists() == true {
                
                self.reviews.removeAll()
                
                for item in locationInDB.children {
                    
                    let snapshotDictionary = (item as! FIRDataSnapshot).value as! [String:Any]
                    
                    let review = Review()
                    review.author_name = snapshotDictionary["author_name"] as? String
                    review.isTacoMeReview = snapshotDictionary["isTacoMeReview"] as? Bool
                    review.rating = snapshotDictionary["rating"] as? Int
                    review.text = snapshotDictionary["text"] as? String
                    review.relative_time_description = snapshotDictionary["relative_time_description"] as? String
                    
                    self.reviews.append(review.toDictionary())
                    
                }
            }
        }
    }
    
    
    private func saveReviewToFireBase() {
        
        let ref = FIRDatabase.database().reference(withPath: "reviews")
        
        let reviewRef = ref.child(self.tacoLocationPlace_id!)
        
        let review = Review()
        
        review.author_name = self.nameTextField.text!
        review.rating = self.selectedRating!
        review.text = self.reviewTextTextView.text!
        review.isTacoMeReview = true
        
        let uglyDate = String(describing: Date())
        //formatting the date
        let startIndex = uglyDate.index(uglyDate.startIndex, offsetBy: 0)
        let endIndex = uglyDate.index(uglyDate.startIndex, offsetBy: 9)
        let date = uglyDate[startIndex...endIndex]
        let yearStartIndex = date.index(date.startIndex, offsetBy: 0)
        let yearEndIndex = date.index(date.startIndex, offsetBy: 3)
        let year = date[yearStartIndex...yearEndIndex]
        let dayAndMonthStartIndex = date.index(date.startIndex, offsetBy: 5)
        let dayAndMonthEndIndex = date.index(date.startIndex, offsetBy: 9)
        let dayAndMonth = date[dayAndMonthStartIndex...dayAndMonthEndIndex]
        let formattedDate = "\(dayAndMonth)-\(year)"
        
        review.relative_time_description = formattedDate
        self.reviews.append(review.toDictionary())
        reviewRef.setValue(self.reviews)
    }
    
    
    //MARK: PickerView Setup
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return imageArray.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let myImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 130, height: 25))
        
        switch row {
        case 0:
            myImageView.image = self.imageArray[0]
        case 1:
            myImageView.image = self.imageArray[1]
        case 2:
            myImageView.image = self.imageArray[2]
        case 3:
            myImageView.image = self.imageArray[3]
        case 4:
            myImageView.image = self.imageArray[4]
        default:
            myImageView.image = nil
        }
        return myImageView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedRowIndex = ratingPickerView.selectedRow(inComponent: 0)
    }
    
    //MARK: Delegates for keyboard to return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @IBAction func cencelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
