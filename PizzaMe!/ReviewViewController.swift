//
//  ReviewViewController.swift
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


class ReviewViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addReviewButton: UIButton!
    
    var locationDetail = LocationDetail()
    var locationPlace_id :String!
    var accumulatedFireBaseRatings = 0
    var numberOfFirebaseRatings = 0
    var newRating :Double!
    var reviewsRx :Variable<[Review]> = Variable([])
    
    private let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 175
        
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        
        self.getFireBaseReviews()
        self.bindUI()
    }
    
    
    //MARK: Get FireBase Data and add it to the Google reviews
    private func getFireBaseReviews() {
        
        let ref = FIRDatabase.database().reference(withPath: "reviews")
        ref.observe(.value) { (snapshot :FIRDataSnapshot) in
            
            let locationInDB = snapshot.childSnapshot(forPath: self.locationPlace_id!)
            
            if locationInDB.exists() == true {
                
                for item in locationInDB.children {
                    
                    let snapshotDictionary = (item as! FIRDataSnapshot).value as! [String:Any]
                    
                    let duplicateReview = snapshotDictionary["text"] as? String
                    let duplicateName = snapshotDictionary["author_name"] as? String
                    let duplicateTime = snapshotDictionary["relative_time_description"] as? String
                    
                    if self.reviewsRx.value.contains ( where: {$0.text == duplicateReview} ) && self.reviewsRx.value.contains ( where: {$0.author_name == duplicateName} ) && self.reviewsRx.value.contains ( where: {$0.relative_time_description == duplicateTime} ) {
                        //Do not add to array of reviews
                    } else {
                        
                        let review = Review()
                        review.author_name = snapshotDictionary["author_name"] as? String
                        review.isTacoMeReview = snapshotDictionary["isTacoMeReview"] as? Bool
                        review.rating = snapshotDictionary["rating"] as? Int
                        
                        self.accumulatedFireBaseRatings += review.rating!
                        self.numberOfFirebaseRatings += 1
                        
                        review.text = snapshotDictionary["text"] as? String
                        review.relative_time_description = snapshotDictionary["relative_time_description"] as? String
                        
                        self.reviewsRx.value.insert(review, at: 0)
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.newRating = (Double(self.accumulatedFireBaseRatings) + self.locationDetail.rating!) / Double(self.numberOfFirebaseRatings + 1)
                    self.populateView()
                }
            } else {
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.populateView()
                }
            }
        }
    }
    
    
    func populateView() {
        
        self.nameLabel.text = self.locationDetail.name
        
        if self.numberOfFirebaseRatings == 0 {
            self.ratingLabel.text = String(describing: self.locationDetail.rating!)
            
            if self.locationDetail.rating! >= 0.0 && self.locationDetail.rating! < 0.5 {
                self.imageView.image = UIImage(named: "0_stars.png")
            } else if self.locationDetail.rating! >= 0.5 && self.locationDetail.rating! < 1.0 {
                self.imageView.image = UIImage(named: "0_5_stars.png")
            } else if self.locationDetail.rating! >= 1.0 && self.locationDetail.rating! < 1.5 {
                self.imageView.image = UIImage(named: "1_stars.png")
            } else if self.locationDetail.rating! >= 1.5 && self.locationDetail.rating! < 2.0 {
                self.imageView.image = UIImage(named: "1_5_stars.png")
            } else if self.locationDetail.rating! >= 2.0 && self.locationDetail.rating! < 2.5 {
                self.imageView.image = UIImage(named: "2_stars.png")
            } else if self.locationDetail.rating! >= 2.5 && self.locationDetail.rating! < 3.0 {
                self.imageView.image = UIImage(named: "2_5_stars.png")
            } else if self.locationDetail.rating! >= 3.0 && self.locationDetail.rating! < 3.5 {
                self.imageView.image = UIImage(named: "3_stars.png")
            } else if self.locationDetail.rating! >= 3.5 && self.locationDetail.rating! < 4.0 {
                self.imageView.image = UIImage(named: "3_5_stars.png")
            } else if self.locationDetail.rating! >= 4.0 && self.locationDetail.rating! < 4.5 {
                self.imageView.image = UIImage(named: "4_stars.png")
            } else if self.locationDetail.rating! >= 4.5 && self.locationDetail.rating! < 5.0 {
                self.imageView.image = UIImage(named: "4_5_stars.png")
            } else if self.locationDetail.rating! == 5.0 {
                self.imageView.image = UIImage(named: "5_stars.png")
            } else if self.locationDetail.rating == nil {
                
            }
        } else {
            
            let ratingString = String(format: "%.1f", self.newRating!)
            
            self.ratingLabel.text = ratingString
            
            if self.newRating! >= 0.0 && self.newRating! < 0.5 {
                self.imageView.image = UIImage(named: "0_stars.png")
            } else if self.newRating! >= 0.5 && self.newRating! < 1.0 {
                self.imageView.image = UIImage(named: "0_5_stars.png")
            } else if self.newRating! >= 1.0 && self.newRating! < 1.5 {
                self.imageView.image = UIImage(named: "1_stars.png")
            } else if self.newRating! >= 1.5 && self.newRating! < 2.0 {
                self.imageView.image = UIImage(named: "1_5_stars.png")
            } else if self.newRating! >= 2.0 && self.newRating! < 2.5 {
                self.imageView.image = UIImage(named: "2_stars.png")
            } else if self.newRating! >= 2.5 && self.newRating! < 3.0 {
                self.imageView.image = UIImage(named: "2_5_stars.png")
            } else if self.newRating! >= 3.0 && self.newRating! < 3.5 {
                self.imageView.image = UIImage(named: "3_stars.png")
            } else if self.newRating! >= 3.5 && self.newRating! < 4.0 {
                self.imageView.image = UIImage(named: "3_5_stars.png")
            } else if self.newRating! >= 4.0 && self.newRating! < 4.5 {
                self.imageView.image = UIImage(named: "4_stars.png")
            } else if self.newRating! >= 4.5 && self.newRating! < 5.0 {
                self.imageView.image = UIImage(named: "4_5_stars.png")
            } else if self.newRating! == 5.0 {
                self.imageView.image = UIImage(named: "5_stars.png")
            } else if self.newRating == nil {
                
            }
        }
        
    }
    //MARK: Rx Bind UI
    //MARK: Binding UI
    
    private func bindUI() {
        self.bindTableView()
        self.bindAddReviewButtonTap()
    }
    
    private func bindTableView() {
        
        reviewsRx.asObservable()
            .bindTo(self.tableView.rx.items(cellIdentifier: "ReviewCell", cellType: ReviewTableViewCell.self)) { (row, element, cell) in
                
                cell.nameLabel?.text = element.author_name
                
                if element.rating == 1 {
                    cell.ratingLabel?.text = "\(element.rating!) star"
                    cell.reviewTextLabel?.text = element.text
                    cell.reviewTextLabel?.sizeToFit()
                    cell.timeLabel?.text = element.relative_time_description
                } else {
                    cell.ratingLabel?.text = "\(element.rating!) stars"
                    cell.reviewTextLabel?.text = element.text
                    cell.reviewTextLabel?.sizeToFit()
                    cell.timeLabel?.text = element.relative_time_description
                }
            }.disposed(by: disposeBag)
    }
    
    private func bindAddReviewButtonTap() {
        self.addReviewButton.rx.tap
            .throttle(0.5, latest: false, scheduler: MainScheduler.instance)
            .subscribe { [weak self] _ in
                
                guard let strongSelf = self else { return }
                
                //show the AddReviewViewController
                
                guard let addReviewVC = strongSelf.storyboard?.instantiateViewController(withIdentifier: "AddReviewViewController") as? AddReviewViewController else {
                    
                    fatalError("Could not find AddReviewViewController")
                }
                
                addReviewVC.tacoLocationPlace_id = self?.locationPlace_id
                addReviewVC.tacoLocationDetail = (self?.locationDetail)!
                
                strongSelf.present(addReviewVC, animated: true, completion: nil)
                
            }.addDisposableTo(disposeBag)
    }
    
}
