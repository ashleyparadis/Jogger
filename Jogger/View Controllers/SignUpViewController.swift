//
//  SignUpViewController.swift
//  Jogger
//
//  Created by Ashley Paradis on 2018-06-07.
//  Copyright © 2018 Ashley Paradis. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var mismatchedPasswordLabel: UILabel!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTF.isSecureTextEntry = true
        confirmPasswordTF.isSecureTextEntry = true
        // Do any additional setup after loading the view.
        
        for code in NSLocale.isoCountryCodes as [String] {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            self.appDelegate.countryList.append(name)
        }
        print(self.appDelegate.countryList)
        
        signUpBtn.layer.borderColor = UIColor.blue.cgColor
        signUpBtn.layer.borderWidth = 1.0
        signUpBtn.layer.cornerRadius = signUpBtn.frame.height/2
        signUpBtn.setTitleColor(.blue, for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        mismatchedPasswordLabel.isHidden = true
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
    @IBAction func signUpButton(_ sender: Any) {
        let email: String!
        let password: String!
        if emailTF.text != "" && passwordTF.text != "" && confirmPasswordTF.text != "" && passwordTF.text == confirmPasswordTF.text{
            email = emailTF.text
            password = passwordTF.text
        }
        else {
            mismatchedPasswordLabel.isHidden = false
            print("Code 10: Email and/or password are required!")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if error == nil {
                //print authResult content
                print(authResult!)
                self.performSegue(withIdentifier: "signUpToInfoVC", sender: self)
            }
            else { //there is an error
                print("Error creating user: " + (error?.localizedDescription)!)
            }
        }
    }
    
    @IBOutlet var tappedOut: UITapGestureRecognizer!
    
    @IBAction func tappedOut(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    
}
