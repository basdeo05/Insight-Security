//
//  SignUpViewController.swift
//  Insight Security
//
//  Created by Richard Basdeo on 3/11/21.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    let k = K()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        emailTextField.attributedPlaceholder =  NSAttributedString(string: "Email",
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        passwordTextField.attributedPlaceholder =  NSAttributedString(string: "Password",
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
    
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
        if let userEmail = emailTextField.text {
            
            if let userPassword = passwordTextField.text {
                
                Auth.auth().createUser(withEmail: userEmail, password: userPassword) { (authResult, error) in
                    
                    if let e = error {
                        //Alert that an error occured when signing in
                        print (e.localizedDescription)
                    }
                    else {
                        //perform segue
                        self.performSegue(withIdentifier: self.k.signUpSegue, sender: self)
                        
                    }
                }
            }
            else {
                //Create alert user needs to enter a Password
                print ("No password provided")
            }
        }
        else {
            //Create alert user need to enter a email
            print ("No email Provided")
        }
    }
        
}
