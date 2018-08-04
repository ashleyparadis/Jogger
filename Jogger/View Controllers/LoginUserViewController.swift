//
//  LoginViewController.swift
//  Jogger
//
//  Created by Ashley Paradis on 2018-06-07.
//  Copyright © 2018 Ashley Paradis. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginUserViewController: UIViewController {
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTF.isSecureTextEntry = true
        messageLabel.isHidden = true
        // Do any additional setup after loading the view.
        
        signInBtn.layer.borderColor = UIColor.blue.cgColor
        signInBtn.layer.borderWidth = 1.0
        signInBtn.layer.cornerRadius = signInBtn.frame.height/2
        signInBtn.setTitleColor(.blue, for: .normal)
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
    
    @IBAction func signIn(_ sender: Any) {
        let email: String!
        let password: String!
        if emailTF.text != "" && passwordTF.text != "" {
            email = emailTF.text
            password = passwordTF.text
        }
        else {
            print("Code 10: Email and/or password are required!")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil {
                //print authResult content
                print(user!)
                print("User Status: \(self.isUserLoggedIn())")
                self.dismiss(animated: true, completion: nil)
            }
            else { //there is an error
                self.messageLabel.isHidden = false
                print("Error logging in: " + (error?.localizedDescription)!)
            }
        }
    }
    
    func isUserLoggedIn() -> Bool {
        if Auth.auth().currentUser != nil{
            return true
        } else {
            return false
        }
    }
    
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    @IBAction func tappedOut(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    
}
