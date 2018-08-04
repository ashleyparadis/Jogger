//
//  LoginViewController.swift
//  Jogger
//
//  Created by Ashley Paradis on 2018-05-25.
//  Copyright © 2018 Ashley Paradis. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit

class StartScreenViewController: UIViewController {

    var userInfo = NSDictionary()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var refUsers:DatabaseReference!
    
    @IBOutlet weak var fbLoginButton: UIButton!
    @IBOutlet weak var emailLoginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fbLoginButton.backgroundColor = UIColor(red:0.24, green:0.35, blue:0.59, alpha:1.0)
        fbLoginButton.layer.cornerRadius = fbLoginButton.frame.height/2
        
        emailLoginButton.backgroundColor = UIColor.clear
        emailLoginButton.layer.borderWidth = 1.0
        emailLoginButton.layer.borderColor = UIColor.white.cgColor
        emailLoginButton.layer.cornerRadius = emailLoginButton.frame.height/2
        
        signupButton.backgroundColor = UIColor.clear
        signupButton.layer.borderWidth = 1.0
        signupButton.layer.borderColor = UIColor.white.cgColor
        signupButton.layer.cornerRadius = signupButton.frame.height/2

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
    
    @IBAction func fbLoginAction(_ sender: Any) {
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if error != nil {
                
            }
            else if result!.isCancelled{
                print("user cancelled login")
            }
            else {
                //lets get user info
                self.getUserInfo()
                self.useFirebaseLogin()
            }
        }
    }
    
    @IBAction func emailLoginButton(_ sender: Any) {
        if isUserLoggedIn() == true {
            dismiss(animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "signInVC", sender: self)
        }
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        
    }
    
    func isUserLoggedIn() -> Bool {
        if Auth.auth().currentUser != nil{
            return true
        } else {
            return false
        }
    }
    
    func useFirebaseLogin(){
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().signInAndRetrieveData(with: credential) { (authresult, error) in
            if error == nil {
                //user is logged in
                print("Email: \(String(describing: authresult?.user.email))")
                self.performSegue(withIdentifier: "showMainScreenVC", sender: self)
            }
            else {
                print("")
            }
        }
    }
    
    func getUserInfo(){
        let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, email, name, first_name, last_name, location, picture.type(large)"]);
        request?.start(completionHandler: { (connection, result, error) in
            if error == nil {
                self.userInfo = result as! NSDictionary
                
                var firstname = self.userInfo.value(forKey: "first_name")
                var lastname = self.userInfo.value(forKey: "last_name")
                if firstname == nil {
                    firstname = "Unknown"
                }
                if lastname == nil {
                    lastname = "Unknown"
                }
                let fullname = "\(firstname ?? "Unknown") \(lastname ?? "")"
                var location = self.userInfo.value(forKey: "location")
                if location == nil {
                    location = "Unknown Location"
                }
                
                
                let user = User(id: "", image: nil, name: fullname, location: location as! String)
                self.appDelegate.users.append(user)
                self.refUsers = Database.database().reference().child("user")
                
                let id = self.refUsers.childByAutoId()
                
                let data = [
                    "id": id,
                    "name": fullname,
                    "location": location
                ]
                
                //self.refUsers.childByAutoId().child(user.id).setValue(data)
                print("FB Result: \(self.userInfo)")
            }
            else {
                print("FB Error: \(String(describing: error?.localizedDescription))")
            }
        })
    }
    
    

    
    
}
