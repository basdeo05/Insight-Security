//
//  UserHomePageViewController.swift
//  Insight Security
//
//  Created by Richard Basdeo on 3/11/21.
//

import UIKit
import Firebase

class UserHomePageViewController: UIViewController {

    //outlets
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var securityImageCollectionView: UICollectionView!
    @IBOutlet weak var cameraModeOutlet: UIButton!
    
    //access to constants file
    let k = K()
    
    //connect this controller to the model
    var control = HomeAppBrain()
    
    var counter = 0
    var viewDidLoadCalled = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        securityImageCollectionView.delegate = self
        securityImageCollectionView.dataSource = self
        control.delegate = self
        
        
        // Do any additional setup after loading the view.
        if let userEmail = Auth.auth().currentUser?.email {
            emailLabel.text = "Welcome \n \(userEmail)"
        }
        
        //Model handles calling database to populate the collectionView
        //Will update the collectionView in the delegate function when network called has been completed
        control.updateCollectionView()
        
        //Styling
        Styling.customButton(for: cameraModeOutlet)
        emailLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 2) {
            self.emailLabel.isHidden = false
        }
        
        if (viewDidLoadCalled == false){
            control.updateCollectionView()
        }
    }
    
    //Signout user when sign out button is pressed
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

//Network call has been made successfully
//Delegate method is returning us the information neeeded to populate the collectionView.
//Call reloadData in matin thread
extension UserHomePageViewController: HomeProtocol {
    func updateUI(returnedData: [SecurityImageObject]) {
        counter = returnedData.count
        viewDidLoadCalled = false

        
        if (counter != control.securityObjects.count){
            control.securityObjects.removeAll()
            control.securityObjects = returnedData
            DispatchQueue.main.async {
                self.securityImageCollectionView.reloadData()
            }
        }
    }
}

extension UserHomePageViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        control.securityObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: k.securityCell, for: indexPath) as! SecurityImageCollectionViewCell
        cell.cellLabel.text = control.securityObjects[indexPath.row].theDate
        cell.setCellImage(theURL: control.securityObjects[indexPath.row].theImage)
        return cell
    }
    
    func collectionView( _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: (securityImageCollectionView.frame.size.width/2) - 3,
                          height: (securityImageCollectionView.frame.size.width/2) - 3)
        }

    func collectionView( _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 1
        }

    func collectionView( _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 1
        }

    func collectionView( _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        }
}
