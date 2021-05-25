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
    var securityObjects = [SecurityImageObject]()
    let firebase = FirebaseHelper()
    var delegate: HomeProtocol?
    
    func updateCollectionView() {
        firebase.delegate = self
        firebase.getSecurityObjects()
    }
}

extension HomeAppBrain: FirebaseProtocols {
    
    mutating func securityObjectsReturned(returnedData: [SecurityImageObject]) {
        securityObjects.append(contentsOf: returnedData)
        delegate?.updateUI(returnedData: securityObjects)
    }
    
    func pictureUploaded() {}
    
    func error(aError: Error) {
        print(aError.localizedDescription)
    }
}
