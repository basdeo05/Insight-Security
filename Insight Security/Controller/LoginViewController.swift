//
//  LoginViewController.swift
//  Insight Security
//
//  Created by Richard Basdeo on 3/11/21.
//

import UIKit
import Firebase

protocol loginAttempts {
    func showForgotPassword ()
}

class LoginViewController: UIViewController{

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var delegate: loginAttempts?
    let k = K()
    var myAlert = MyAlert()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Set placeholder text color so they can be visible
        emailTextField.attributedPlaceholder =  NSAttributedString(string: "Email",
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        passwordTextField.attributedPlaceholder =  NSAttributedString(string: "Password",
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
    }
    
    //When cancel press go back to home screen
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        
    }
    
    //make sure email and password fields are not nil
    //If not try to login
    //show alert if describing error if any
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        if let userEmail = emailTextField.text, let userPassword = passwordTextField.text {
                
                Auth.auth().signIn(withEmail: userEmail, password: userPassword) { (authResult, error) in
                    
                    if let e = error {
                        //Alert that an error occured when signing in
                        self.myAlert.showAlert(with: "Error Trying To Login In",
                                               message: e.localizedDescription,
                                               on: self,
                                               wasSuccess: false, completionHandler: {
                                                
                                                self.delegate?.showForgotPassword()
                                                
                                               })
                    }
                    
                    else {
                        //perform segue
                        self.myAlert.showAlert(with: "Signed In",
                                               message: "Successfully Login",
                                               on: self,
                                               wasSuccess: true, completionHandler: {
                                                
                                                UserDefaults.standard.set(true, forKey: self.k.successSignIn)
                                                DispatchQueue.main.async {
                                                    
                                                    self.performSegue(withIdentifier: self.k.signInSegue, sender: self)
                                                    
                                                }
                                        })
                    }
                    
                }
            }
        }
    }

extension LoginViewController: loginAttempts {
    func showForgotPassword() {
    }
}
