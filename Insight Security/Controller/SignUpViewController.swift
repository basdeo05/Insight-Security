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
    let alert = MyAlert()
    
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
    
    
    //make sure email and password fields are not nil
    //If not try to login
    //show alert if describing error if any
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
        if let userEmail = emailTextField.text, let userPassword = passwordTextField.text {
                
                Auth.auth().createUser(withEmail: userEmail, password: userPassword) { (authResult, error) in
                    
                    if let e = error {
                        //Alert that an error occured when signing in
                        print (e.localizedDescription)
                        self.alert.showAlert(with: "Sign Up Failed",
                                             message: e.localizedDescription,
                                             on: self, wasSuccess: false) {
                            
                        }
                    }
                    else {
                        self.alert.showAlert(with: "Sign Up Successful",
                                             message: "You Have signed Up",
                                             on: self, wasSuccess: true) {
                            
                            UserDefaults.standard.set(true, forKey: self.k.successSignIn)
                            //perform segue
                            self.performSegue(withIdentifier: self.k.signUpSegue, sender: self)
                        
                        }
                    }
                }
            }
        }
    }
