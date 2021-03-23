//
//  ViewTriggersViewController.swift
//  Insight Security
//
//  Created by Richard Basdeo on 3/22/21.
//

import UIKit
import Firebase

class ViewTriggersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var imageURLS = [String]()
    let db = Firestore.firestore()
    var viewImages = ViewImages()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        viewImages.delegate = self
        
        tableView.register(UINib(nibName: "TriggerCellTableViewCell", bundle: nil), forCellReuseIdentifier: "TriggerCell")
        
        getImagesURLS()
        
        
    }
    
    func getImagesURLS() {
        
        guard let userEmail = Auth.auth().currentUser?.email else {return}
        
        let doesDocumentExists = self.db.collection("securityEvents").document(userEmail)
        
        doesDocumentExists.getDocument { (returnDocument, error) in
            
            
            if let document = returnDocument {
                
                if document.exists {
                    
                    self.imageURLS = document["noiseSpike"] as! [String]
                    self.viewImages.populateObjects(theURLS: self.imageURLS)
                }
            }
        }
    }
}

extension ViewTriggersViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewImages.noiseSpikeObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TriggerCell") as! TriggerCellTableViewCell
        cell.securityImage.image = viewImages.noiseSpikeObjects[indexPath.row].theImage
        cell.dateLabel.text = viewImages.noiseSpikeObjects[indexPath.row].theDate
        return cell
    }
}

extension ViewTriggersViewController: imagesProtocol {
    func updateUI() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
