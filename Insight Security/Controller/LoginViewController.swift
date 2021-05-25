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

    //outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var cancelButtonOutlet: UIButton!
    
    //inform the home view controller of failed login attempts
    var delegate: loginAttempts?
    
    //access to constants file
    let k = K()
    
    //show user alerts using custom alert classb
    var myAlert = MyAlert()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Set placeholder text color so they can be visible
        emailTextField.attributedPlaceholder =  NSAttributedString(string: "Email",
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        passwordTextField.attributedPlaceholder =  NSAttributedString(string: "Password",
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        
        //Styling outlets
        Styling.customButton(for: cancelButtonOutlet)
        Styling.customButton(for: loginButtonOutlet)
        Styling.customTextField(for: emailTextField)
        Styling.customTextField(for: passwordTextField)
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
                        self.myAlert.showAlert(with: "Error Trying To Login",
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
