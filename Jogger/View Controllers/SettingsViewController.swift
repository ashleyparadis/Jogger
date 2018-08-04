//
//  SettingsViewController.swift
//  Jogger
//
//  Created by Ashley Paradis on 2018-05-23.
//  Copyright © 2018 Ashley Paradis. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class SettingsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorPickerButton: UIButton!
    
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var purpleButton: UIButton!
    @IBOutlet weak var pinkButton: UIButton!
    @IBOutlet weak var greyButton: UIButton!
    @IBOutlet weak var blackButton: UIButton!
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userDefaults = UserDefaults.standard
    var user: User?
    var refUser:DatabaseReference!
    var refProfilePic:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refUser = Database.database().reference().child("user")
        
        user = appDelegate.users[0]

        profilePic.layer.cornerRadius = profilePic.frame.height/2
        profilePic.clipsToBounds = true
        profilePic.contentMode = .scaleAspectFill
        name.text = appDelegate.users[0].name
        logOutButton.layer.borderColor = UIColor.red.cgColor
        logOutButton.layer.borderWidth = 1.0
        logOutButton.layer.cornerRadius = logOutButton.frame.height/2
        
        self.profilePic.clipsToBounds = true
        
        redButton.layer.cornerRadius = redButton.frame.height/2
        orangeButton.layer.cornerRadius = orangeButton.frame.height/2
        yellowButton.layer.cornerRadius = yellowButton.frame.height/2
        greenButton.layer.cornerRadius = greenButton.frame.height/2
        blueButton.layer.cornerRadius = blueButton.frame.height/2
        purpleButton.layer.cornerRadius = purpleButton.frame.height/2
        pinkButton.layer.cornerRadius = pinkButton.frame.height/2
        greyButton.layer.cornerRadius = greyButton.frame.height/2
        blackButton.layer.cornerRadius = blackButton.frame.height/2
        colorPickerButton.backgroundColor = self.appDelegate.colorChoice
        colorPickerButton.layer.cornerRadius = colorPickerButton.frame.height/2
        colorView.layer.borderColor = UIColor.black.cgColor
        colorView.layer.borderWidth = 1
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.profileView.backgroundColor = self.appDelegate.colorChoice
        self.colorView.isHidden = true
        
//        if appDelegate.profilePic.count == 1 {
//            profilePic.image = appDelegate.profilePic[0]
//        } else {
//            profilePic.image = appDelegate.profilePic.last
//        }
        profilePic.image = appDelegate.profilePic.last
        
        if self.appDelegate.unitKm == true {
            self.segmentedControl.selectedSegmentIndex = 0
        } else {
            self.segmentedControl.selectedSegmentIndex = 1
        }
        
        colorView.layer.shadowColor = UIColor.black.cgColor
        colorView.layer.shadowOpacity = 0.5
        colorView.layer.shadowOffset = CGSize.zero
        colorView.layer.shadowRadius = 5
        colorView.layer.cornerRadius = 10
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
    
    @IBAction func logoutButton(_ sender: Any) {
        try! Auth.auth().signOut()
        self.appDelegate.runHistoryList.removeAll()
        self.appDelegate.users.removeAll()
        self.appDelegate.profilePic.removeLast()
        self.appDelegate.paceArray.removeAll()
        self.appDelegate.speedArray.removeAll()
        self.appDelegate.totalDistance = 0.0
        performSegue(withIdentifier: "logOutBackToMainVC", sender: self)
    }
    
    @IBAction func changeImage(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("Choose Image", comment: "Choose Image"), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Take a new photo", comment: "Take a new photo"), style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Choose from camera roll", comment: "Choose from camera roll"), style: .default, handler: { _ in
            self.openLibrary()
        }))
        
        alert.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(){
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = UIImagePickerControllerSourceType.camera
        cameraPicker.allowsEditing = true
        self.present(cameraPicker, animated: true, completion: nil)
    }
    
    func openLibrary(){
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var newImage: UIImage
        
        if let pickedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            print("image was edited")
            newImage = pickedImage
        } else if let pickedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            print("image is original")
            newImage = pickedImage
        } else {
            return
        }
        self.appDelegate.profilePic.append(newImage)
        self.profilePic.image = newImage
        self.saveImageToDatabase(image: newImage, user: user!)
        dismiss(animated: true)
    }
    
    func saveImageToDatabase(image: UIImage, user:User){
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        let storageRef = Storage.storage().reference().child("profilePictures").child((Auth.auth().currentUser?.uid)!).child((self.user?.id)!)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        storageRef.putData(imageData!, metadata: metaData) { (strMetaData, error) in
            if error == nil {
                //print(strMetaData)
                print("Image Uploaded Successfully")
                self.dismiss(animated: true, completion: nil)
            } else {
                print("Error uploading image: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    @IBAction func unitChanged(_ sender: Any) {
        let indexSelected = self.segmentedControl.selectedSegmentIndex
        let unitSelected = self.segmentedControl.titleForSegment(at: indexSelected)!
        
        if unitSelected == "km"{
            self.appDelegate.unitKm = true
            print("true")
        } else {
            self.appDelegate.unitKm = false
            print("false")
        }
        userDefaults.set(unitSelected, forKey: "kUnitSelected")
    }
    
    //MARK: - Color Choice
    @IBAction func redSelected(_ sender: Any) {
        self.colorView.isHidden = true
        self.profileView.backgroundColor = self.appDelegate.redColor
        self.appDelegate.colorChoice = self.appDelegate.redColor
        self.colorPickerButton.backgroundColor = self.appDelegate.redColor
        userDefaults.set("red", forKey: "kColorSelected")
    }
    @IBAction func orangeSelected(_ sender: Any) {
        self.colorView.isHidden = true
        self.profileView.backgroundColor = self.appDelegate.orangeColor
        self.appDelegate.colorChoice = self.appDelegate.orangeColor
        self.colorPickerButton.backgroundColor = self.appDelegate.orangeColor
        userDefaults.set("orange", forKey: "kColorSelected")
    }
    @IBAction func yellowSelected(_ sender: Any) {
        self.colorView.isHidden = true
        self.profileView.backgroundColor = self.appDelegate.yellowColor
        self.appDelegate.colorChoice = self.appDelegate.yellowColor
        self.colorPickerButton.backgroundColor = self.appDelegate.yellowColor
        userDefaults.set("yellow", forKey: "kColorSelected")
    }
    @IBAction func greenSelected(_ sender: Any) {
        self.colorView.isHidden = true
        self.profileView.backgroundColor = self.appDelegate.greenColor
        self.appDelegate.colorChoice = self.appDelegate.greenColor
        self.colorPickerButton.backgroundColor = self.appDelegate.greenColor
        userDefaults.set("green", forKey: "kColorSelected")
    }
    @IBAction func blueSelected(_ sender: Any) {
        self.colorView.isHidden = true
        self.profileView.backgroundColor = self.appDelegate.blueColor
        self.appDelegate.colorChoice = self.appDelegate.blueColor
        self.colorPickerButton.backgroundColor = self.appDelegate.blueColor
        userDefaults.set("blue", forKey: "kColorSelected")
    }
    @IBAction func purpleSelected(_ sender: Any) {
        self.colorView.isHidden = true
        self.profileView.backgroundColor = self.appDelegate.purpleColor
        self.appDelegate.colorChoice = self.appDelegate.purpleColor
        self.colorPickerButton.backgroundColor = self.appDelegate.purpleColor
        userDefaults.set("purple", forKey: "kColorSelected")
    }
    @IBAction func pinkSelected(_ sender: Any) {
        self.colorView.isHidden = true
        self.profileView.backgroundColor = self.appDelegate.pinkColor
        self.appDelegate.colorChoice = self.appDelegate.pinkColor
        self.colorPickerButton.backgroundColor = self.appDelegate.pinkColor
        userDefaults.set("pink", forKey: "kColorSelected")
    }
    @IBAction func greySelected(_ sender: Any) {
        self.colorView.isHidden = true
        self.profileView.backgroundColor = self.appDelegate.greyColor
        self.appDelegate.colorChoice = self.appDelegate.greyColor
        self.colorPickerButton.backgroundColor = self.appDelegate.greyColor
        userDefaults.set("grey", forKey: "kColorSelected")
    }
    @IBAction func blackSelected(_ sender: Any) {
        self.colorView.isHidden = true
        self.profileView.backgroundColor = self.appDelegate.blackColor
        self.appDelegate.colorChoice = self.appDelegate.blackColor
        self.colorPickerButton.backgroundColor = self.appDelegate.blackColor
        userDefaults.set("black", forKey: "kColorSelected")
    }
    
    
    @IBAction func colorPicker(_ sender: Any) {
        self.colorView.isHidden = false
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.colorView.isHidden = true
    }
    
}
