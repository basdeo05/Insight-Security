//
//  SecurityImageCollectionViewCell.swift
//  Insight Security
//
//  Created by Richard Basdeo on 5/25/21.
//

import UIKit

class SecurityImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    
    func setCellImage(theURL: String){
        if let url = URL(string: theURL){
                
                let session = URLSession(configuration: .default)
                
                let task = session.dataTask(with: url) { (data, response, error) in
                    
                    
                    if let e = error {
                        print("Could not convert url to a image: \(e.localizedDescription)")
                        
                        //Can also call the error delegate here
                        
                        
                        
                        
                    }
                    else {
                        
                        if let imageData = data {
                            let tempImage = UIImage(data: imageData)
                            
                            if let unwrappedImage = tempImage {
                                
                                
                                DispatchQueue.main.async {
                                    
                                    self.cellImageView.image = unwrappedImage
                                }
                                
                            }
                        }
                    }
                }
                task.resume()
            }
    }
    
}
