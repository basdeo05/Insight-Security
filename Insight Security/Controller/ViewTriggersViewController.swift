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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
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
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension ViewTriggersViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageURLS.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TriggerCell") as! TriggerCellTableViewCell
        
        
        let session = URLSession(configuration: .default)
        
        let url = URL(string: imageURLS[indexPath.row])
        
        if let theURL = url {
            
            let task = session.dataTask(with: theURL) { (data, response, error) in
                
                if let e = error {
                    print ("There was an error getting image")
                }
                else {
                    
                    if let imageData = data {
                        DispatchQueue.main.async {
                            cell.securityImage.image = UIImage(data: imageData)
                            tableView.reloadData()
                        }
                    }
                }
            }
            task.resume()
        }
    
        
        cell.dateLabel.text = imageURLS[indexPath.row]
        return cell
    }
}
