//
//  ProfileViewController.swift
//  Jogger
//
//  Created by Ashley Paradis on 2018-05-23.
//  Copyright © 2018 Ashley Paradis. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var avgPace: UILabel!
    @IBOutlet weak var avgSpeed: UILabel!
    @IBOutlet weak var totalDistance: UILabel!
    @IBOutlet weak var totalDuration: UILabel!
    @IBOutlet weak var profileView: UIView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var user:User?
    var progressView:UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePic.clipsToBounds = true
        profilePic.contentMode = .scaleAspectFill
        profilePic.layer.cornerRadius = profilePic.frame.height/2
        name.text = appDelegate.users[0].name
        countryName.text = appDelegate.users[0].location
        
        user = appDelegate.users[0]
        
        progressView = UIActivityIndicatorView(frame: CGRect(x: (profilePic.frame.height)/2, y: (profilePic.frame.width)/2, width: 10, height: 10))
        progressView.activityIndicatorViewStyle = .white
        progressView.color = UIColor.black
        profilePic.addSubview(progressView)
        progressView.startAnimating()
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.profileView.backgroundColor = self.appDelegate.colorChoice
        
        var image2:UIImage!
        
        if image2 != nil {
            profilePic.image = user?.image
        } else {
            let imageRef = Storage.storage().reference().child("profilePictures").child((Auth.auth().currentUser?.uid)!).child((user?.id)!)
            imageRef.downloadURL { url, error in
                if error != nil {
                    print("error downloading image")
                    self.profilePic.image = #imageLiteral(resourceName: "imagePlaceholder")
                    self.progressView.stopAnimating()
                } else {
                    do {
                        let imageData = try Data(contentsOf: url!)
                        let image = UIImage(data: imageData)
                        DispatchQueue.main.async {
                            self.progressView.stopAnimating()
                            self.user?.image = image
                            image2 = image
                            self.profilePic.image = image
                            self.appDelegate.users.remove(at: 0)
                            self.appDelegate.users.insert((self.user)!, at: 0)
                            self.appDelegate.profilePic.append(image!)
                        }
                        
                    } catch {
                        
                    }
                }
            }
        }
        
        getInfo()
        setStats()
    
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
    @IBAction func settingsButton(_ sender: Any) {
        performSegue(withIdentifier: "showSettingsVC", sender: self)
    }
    
    func getInfo(){
        self.appDelegate.paceArray.removeAll()
        self.appDelegate.speedArray.removeAll()
        self.appDelegate.totalDistance = 0
        self.appDelegate.totalDuration = 0
        
        for run in self.appDelegate.runHistoryList {
            self.appDelegate.paceArray.append(Double(run.runPace)!)
            self.appDelegate.speedArray.append(Double(run.runSpeed)!)
            let newDistance:Double = Double(run.runDistance)!
            self.appDelegate.totalDistance += newDistance
            let newDuration:Int = Int(run.runDuration)!
            self.appDelegate.totalDuration += newDuration
        }
        
        
    }
    
    func setStats(){
        
        if self.appDelegate.unitKm == true {
            print("stats in km")
            self.totalDistance.text = "\(self.appDelegate.totalDistance) km"

            let runString = String(format: "%02d:%02d:%02d", self.appDelegate.totalDuration / 3600, (self.appDelegate.totalDuration % 3600) / 60, (self.appDelegate.totalDuration % 3600) % 60)
            self.totalDuration.text = runString
            
            //set speed
            var additionSpeed = 0.0
            var finalSpeed = 0.0
            print("Speed array Count: \(self.appDelegate.speedArray.count)")
            for speed in self.appDelegate.speedArray{
                additionSpeed += speed
                print(additionSpeed)
            }
            finalSpeed = additionSpeed/Double(self.appDelegate.speedArray.count)
            self.avgSpeed.text = String(format: "%.2f km/h", finalSpeed)
            
            //set pace
            var additionPace = 0.0
            var finalPace = 0.0
            for pace in self.appDelegate.paceArray{
                additionPace += pace
            }
            finalPace = additionPace/Double(self.appDelegate.paceArray.count)
            self.avgPace.text = "\(finalPace) min/km"
        } else {
            print("stats in miles")
            var totalDistance:Double = Double(self.appDelegate.totalDistance)
            totalDistance = totalDistance/0.621371
            self.totalDistance.text = String(format:"%.2f miles", totalDistance)
            
            //set speed
            var additionSpeed = 0.0
            var finalSpeed = 0.0
            print("Speed array Count: \(self.appDelegate.speedArray.count)")
            for speed in self.appDelegate.speedArray{
                additionSpeed += speed
                print(additionSpeed)
            }
            finalSpeed = additionSpeed/Double(self.appDelegate.speedArray.count)
            finalSpeed = finalSpeed/0.621371
            self.avgSpeed.text = String(format: "%.2f mph", finalSpeed)
            
            //set pace
            var additionPace = 0.0
            var finalPace = 0.0
            for pace in self.appDelegate.paceArray{
                additionPace += pace
            }
            finalPace = additionPace/Double(self.appDelegate.paceArray.count)
            finalPace = finalPace/0.621371
            self.avgPace.text = "\(finalPace) min/mile"
        }
        if self.appDelegate.speedArray.count == 0 {
            if self.appDelegate.unitKm == true {
                avgPace.text = "0.0 min/km"
                avgSpeed.text = "0.0 km/h"
            } else {
                avgPace.text = "0.0 min/mile"
                avgSpeed.text = "0.0 mph"
            }
        }
    }
    
}
