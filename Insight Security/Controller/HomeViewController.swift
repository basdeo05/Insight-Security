//
//  ViewController.swift
//  Insight Security
//
//  Created by Richard Basdeo on 3/10/21.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    //outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var forgotPasswordOutlet: UIButton!
    @IBOutlet weak var loginOutlet: UIButton!
    @IBOutlet weak var signUpOutlet: UIButton!
    
    //control for animation
    var turnTransformation:CGFloat = 4
    
    //When amount of login is set two 3 the forgot password will no longer be set to hidden
    var amountOfLogin = 0
    
    //delegate used to inform homeViewController the amount of time there was a failed login attempt
    var delegate: loginAttempts?
    
    //access to constants file
    let k = K()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //hide forgot password button until they put in wrong password 3 times
        forgotPasswordOutlet.isHidden = true
        
        //animate the logo image
        animateImage()
        
        //listen for when there is a failed login attempt
        delegate = self
        
        //Styling my outlets
        Styling.customButton(for: loginOutlet)
        Styling.customButton(for: signUpOutlet)
        Styling.customButton(for: forgotPasswordOutlet)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //If user is already signed in send straigh to the user home page
        if (UserDefaults.standard.bool(forKey: k.successSignIn)){
            performSegue(withIdentifier: k.homeToUserHome, sender: self)
        }
        
        
    }
    
    //animation function to rotate image
    func animateImage() {
        UIView.animate(withDuration: 2) {
            self.logoImage.transform = self.logoImage.transform.rotated(by: .pi / self.turnTransformation)
        } completion: { (_) in
            UIView.animate(withDuration: 2) {
                self.logoImage.transform = self.logoImage.transform.rotated(by: -.pi / 2)
            } completion: { (_) in
                self.turnTransformation = 2
                self.animateImage()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == k.homeSignIn){
            let destinationVC = segue.destination as! LoginViewController
            destinationVC.delegate = self
        }
        else if (segue.identifier == k.homeSignUp) {
            _ = segue.destination as! SignUpViewController
        }
    }
}

//Listen to when delegate method is called in loginViewController.
//If this delegate method is called increase the failed login attempts count
//If failed login equals 3 animate in the forgor password button
extension HomeViewController: loginAttempts {
    func showForgotPassword() {
        
        amountOfLogin += 1
        
        if (amountOfLogin == 3){
            UIView.animate(withDuration: 2) {
                self.forgotPasswordOutlet.isHidden = false
            }
        }
    }
}

