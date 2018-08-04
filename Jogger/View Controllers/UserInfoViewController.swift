//
//  UserInfoViewController.swift
//  Jogger
//
//  Created by Ashley Paradis on 2018-06-29.
//  Copyright © 2018 Ashley Paradis. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class UserInfoViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var refUsers:DatabaseReference!
    var locationPickerView = UIPickerView()
    var selectedCountry:String?
    
    @IBOutlet weak var fullNameTF: UITextField!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var confirmBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.refUsers = Database.database().reference().child("user")
        self.fetchData()
        
        self.locationPickerView.delegate = self
        self.locationPickerView.dataSource = self
        self.configureLocationPicker()
        
        confirmBtn.layer.borderColor = UIColor.blue.cgColor
        confirmBtn.layer.borderWidth = 1.0
        confirmBtn.layer.cornerRadius = confirmBtn.frame.height/2
        confirmBtn.setTitleColor(.blue, for: .normal)
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
    
    func save(user:User){
        let data = [
            "id": user.id,
            "name": user.name,
            "location": user.location
        ]
        self.refUsers.child((Auth.auth().currentUser?.uid)!).child(user.id).setValue(data)
    }
    
    func fetchData(){
        self.refUsers.child((Auth.auth().currentUser?.uid)!).observe(DataEventType.value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.appDelegate.users.removeAll()
                for users in snapshot.children.allObjects as! [DataSnapshot] {
                    //getting values
                    let userObject = users.value as? [String:AnyObject]
                    let userName = userObject?["name"]
                    let userId = userObject?["id"]
                    let userLocation = userObject?["location"]
                    
                    //creating artist object with model and fetched vaclues
                    let user = User(id: (userId as! String?)!, image: nil, name: (userName as! String?)!, location: (userLocation as! String?)!)
                    self.appDelegate.users.append(user)
                }
            }
        }
    }
    
    @IBAction func confirm(_ sender: Any) {
        let id = self.refUsers.childByAutoId().key
        
        //getting new values
        let name = fullNameTF.text
        let location = locationTF.text
        let image:UIImage? = nil
        
        if name != "" && location != "" {
            let user = User(id: id, image: image, name: name!, location: location!)
            self.save(user: user)
            appDelegate.users.append(user)
            self.performSegue(withIdentifier: "signUpToMainVC", sender: self)
        }
    }
    
    @IBAction func tappedOut(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    func configureLocationPicker(){
        //toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done"), style: .done, target: self, action: #selector(donePickingCountry))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .done, target: self, action: #selector(cancelPickingCountry))
        toolbar.setItems([cancelButton,spaceButton,doneButton], animated: false)
        
        locationTF.inputAccessoryView = toolbar
        locationTF.inputView = self.locationPickerView
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.appDelegate.countryList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.appDelegate.countryList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedCountry = self.appDelegate.countryList[row]
    }
    
    @objc func donePickingCountry(){
        if selectedCountry != nil {
            self.locationTF.text = self.selectedCountry
        }else {
            self.locationTF.text = self.appDelegate.countryList[0]
        }
        self.view.endEditing(true)
    }
    
    @objc func cancelPickingCountry(){
        self.view.endEditing(true)
    }
}
