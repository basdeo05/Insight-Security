//
//  UserHomePageViewController.swift
//  Insight Security
//
//  Created by Richard Basdeo on 3/11/21.
//

import UIKit
import Firebase

class UserHomePageViewController: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    
    let k = K()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let userEmail = Auth.auth().currentUser?.email {
            emailLabel.text = userEmail
        }
    }
    
    @IBAction func signOutButtonPressed(_ sender: Any) {
        
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.set(false, forKey: k.successSignIn)
            dismiss(animated: true, completion: nil)
        }
        catch{
            //create an alert saying singout failed
            print ("Error signing out")
        }
    }
}
