//
//  ViewImages.swift
//  Insight Security
//
//  Created by Richard Basdeo on 3/22/21.
//

import Foundation
import UIKit

struct noiseSpikeObject {
    var theImage: UIImage
    var theDate: String
}

protocol imagesProtocol {
    func updateUI()
}

class ViewImages {
    
    var noiseSpikeObjects = [noiseSpikeObject]()
    
    var delegate: imagesProtocol?
    
    
    
    
    
    
    func populateObjects (object: notificationTriggerUpdate){
        
        print(object.theURL.count)
        var counter = 0
        
        for url in object.theURL {
            
            let session = URLSession(configuration: .default)
            
            let aURL = URL(string: url)
            
            if let theURL = aURL {
                
                let task = session.dataTask(with: theURL) { (data, response, error) in
                    
                    if let e = error {
                        print ("There was an error getting image: \(e.localizedDescription)")
                    }
                    else {
                        
                        if let imageData = data {
                            
                            if let image = UIImage(data: imageData){
                                
                                let newObject = noiseSpikeObject(theImage: image,
                                                                 theDate: object.theDate[counter])
                                
                                self.noiseSpikeObjects.append(newObject)
                                counter += 1
                                
                                self.delegate?.updateUI()
                                
                            }
                            else {
                                print ("Error converting data")
                            }
                        }
                    }
                }
                task.resume()
            }
        }
    }
}
