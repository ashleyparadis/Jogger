//
//  HistoryDetailViewController.swift
//  Jogger
//
//  Created by Ashley Paradis on 2018-05-23.
//  Copyright © 2018 Ashley Paradis. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class HistoryDetailViewController: UIViewController {
    
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var runImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var runTime: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var run:Run!
    var progressView:UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftView.layer.borderWidth = 1
        leftView.layer.borderColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1).cgColor
        rightView.layer.borderWidth = 1
        rightView.layer.borderColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1).cgColor
        runImage.contentMode = .scaleToFill
        runImage.clipsToBounds = true
        
        progressView = UIActivityIndicatorView(frame: CGRect(x: (runImage.frame.width)/2, y: (runImage.frame.height)/2, width: 10, height: 10))
        progressView.activityIndicatorViewStyle = .white
        progressView.color = UIColor.black
        runImage.addSubview(progressView)
        progressView.startAnimating()
        
        if self.appDelegate.segueFromTableView == true {
            if self.appDelegate.runHistoryList.count > 0 {
                if self.appDelegate.unitKm == true {
                    dateLabel.text = run?.runDate
                    let runInts:Int = Int(run.runDuration)!
                    let runString = String(format: "%02d:%02d:%02d", runInts / 3600, (runInts % 3600) / 60, (runInts % 3600) % 60)
                    runTime.text = runString
                    distanceLabel.text = run?.runDistance
                    speedLabel.text = run?.runSpeed
                    if run?.runImage != nil {
                        runImage.image = self.run?.runImage
                    } else {
                        let imageRef = Storage.storage().reference().child("runImages").child((Auth.auth().currentUser?.uid)!).child((run?.runId)!)
                        imageRef.downloadURL { url, error in
                            if error != nil {
                                print("error downloading image")
                            } else {
                                do {
                                    self.progressView.stopAnimating()
                                    let imageData = try Data(contentsOf: url!)
                                    let image = UIImage(data: imageData)
                                    DispatchQueue.main.async {
                                        self.run?.runImage = image
                                        self.runImage.image = image
                                    }
                                    
                                } catch {
                                    
                                }
                            }
                        }
                    }
                } else {
                    dateLabel.text = run?.runDate
                    let runInts:Int = Int(run.runDuration)!
                    let runString = String(format: "%02d:%02d:%02d", runInts / 3600, (runInts % 3600) / 60, (runInts % 3600) % 60)
                    runTime.text = runString
                    var runDistanceInMiles = Double(run.runDistance)!
                    runDistanceInMiles = runDistanceInMiles/0.621371
                    distanceLabel.text = String(format: "%.2f", runDistanceInMiles)
                    var runSpeedInMiles = Double(run.runSpeed)!
                    runSpeedInMiles = runSpeedInMiles/0.621371
                    speedLabel.text = String(format: "%.2f", runSpeedInMiles)
                    if run?.runImage != nil {
                        runImage.image = self.run?.runImage
                    } else {
                        let imageRef = Storage.storage().reference().child("runImages").child((Auth.auth().currentUser?.uid)!).child((run?.runId)!)
                        imageRef.downloadURL { url, error in
                            if error != nil {
                                print("error downloading image")
                            } else {
                                do {
                                    self.progressView.stopAnimating()
                                    let imageData = try Data(contentsOf: url!)
                                    let image = UIImage(data: imageData)
                                    DispatchQueue.main.async {
                                        self.run?.runImage = image
                                        self.runImage.image = image
                                    }
                                    
                                } catch {
                                    
                                }
                            }
                        }
                    }
                }
            }
            
        } else {
            if self.appDelegate.unitKm == true {
                self.progressView.stopAnimating()
                run = self.appDelegate.runHistoryList.last
                dateLabel.text = run?.runDate
                let runInts:Int = Int(run.runDuration)!
                let runString = String(format: "%02d:%02d:%02d", runInts / 3600, (runInts % 3600) / 60, (runInts % 3600) % 60)
                runTime.text = runString
                distanceLabel.text = run.runDistance
                speedLabel.text = run.runSpeed
                self.runImage.image = self.appDelegate.snapshotArray.last
            } else {
                self.progressView.stopAnimating()
                run = self.appDelegate.runHistoryList.last
                dateLabel.text = run?.runDate
                let runInts:Int = Int(run.runDuration)!
                let runString = String(format: "%02d:%02d:%02d", runInts / 3600, (runInts % 3600) / 60, (runInts % 3600) % 60)
                runTime.text = runString
                var runDistanceInMiles = Double(run.runDistance)!
                runDistanceInMiles = runDistanceInMiles/0.621371
                distanceLabel.text = String(format: "%.2f", runDistanceInMiles)
                var runSpeedInMiles = Double(run.runSpeed)!
                runSpeedInMiles = runSpeedInMiles/0.621371
                speedLabel.text = String(format: "%.2f", runSpeedInMiles)
                self.runImage.image = self.appDelegate.snapshotArray.last
            }
        }
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
}
