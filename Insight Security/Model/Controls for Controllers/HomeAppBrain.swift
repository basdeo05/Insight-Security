//
//  HomeAppBrain.swift
//  Insight Security
//
//  Created by Richard Basdeo on 5/25/21.
//

import Foundation

protocol HomeProtocol {
    func updateUI(returnedData: [SecurityImageObject])
}

struct HomeAppBrain {
    
    //Array used to populate collectionView
    var securityObjects = [SecurityImageObject]()
    
    //access to my network calls
    let firebase = FirebaseHelper()
    
    //Communicate back to the viewController using homeProtocols
    var delegate: HomeProtocol?
    
    //viewController will call this method when it needs to update the collectionView.
    //I will make this class the delegate of netoworking protocol so it can be updated when I received all the secuirty images from the database
    func updateCollectionView() {
        firebase.delegate = self
        
        //make networking request to recieven the security images for a particular user
        firebase.getSecurityObjects()
    }
}

//Netoworking call has been completed
//If there is a error print it
//Otherwise provide the viewController with the data it needs
extension HomeAppBrain: FirebaseProtocols {
    
    mutating func securityObjectsReturned(returnedData: [SecurityImageObject]) {
        
        securityObjects.removeAll()
        securityObjects.append(contentsOf: returnedData)
        
        //provide viewController with the data it needs
        delegate?.updateUI(returnedData: securityObjects)
    }
    
    func pictureUploaded() {}
    
    func error(aError: Error) {
        print(aError.localizedDescription)
    }
}
