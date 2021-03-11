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
    
    //control for animation
    var turnTransformation:CGFloat = 4
    
    //When set to 3 will show forgot password
    var amountOfLogin = 0
    var delegate: loginAttempts?
    
    //access to constants file
    let k = K()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //hide forgot password button until they put in wrong password 3 times
        forgotPasswordOutlet.isHidden = true
        
        //animate image
        animateImage()
        
        //show forgot password button after three login attempts
        delegate = self
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
        else {
            _ = segue.destination as! SignUpViewController
        }
    }
}

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

