//
//  FirebaseHelper.swift
//  Insight Security
//
//  Created by Richard Basdeo on 5/25/21.
//

import UIKit
import Photos
import Firebase
protocol FirebaseProtocols {
    func pictureUploaded()
    func error (aError: Error)
}
class FirebaseHelper {
    
    let storage = Storage.storage()
    let db = Firestore.firestore()
    var delegate: FirebaseProtocols?
    
    
    
    func uploadImage(photo: AVCapturePhoto){
        
        //First need to upload image to storage
        
        //Get reference to the storage
        let storageReference = storage.reference()
        
        //Determine which document to store image
        let imagesRef = storageReference.child("securityTriggers")
        
        //Give a file name
        let fileName = "\(String(Timestamp.init().seconds)).jpg"
        
        
        //Configuration
        let spaceRef = imagesRef.child(fileName)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        
        guard let photoData = photo.fileDataRepresentation() else {
                return
            }
        guard let photoImage = UIImage(data: photoData) else {return}
        
        guard let temp2 = photoImage.pngData() else {return}
        
        
        // Upload the file to the path created
        let uploadTask = spaceRef.putData(temp2, metadata: nil) { (metadata, error) in
          guard let metadata = metadata else {
            print ("Error uploading file")
            return
          }
            
        //get the download url for image uploaded
        spaceRef.downloadURL { (url, error) in
            guard let downloadURL = url else {return}
              
              
              
              if let email = Auth.auth().currentUser?.email{
                  
                let documentReference = self.db.collection("securityEvents").document(email)
                
                let theDownloadURL = downloadURL.absoluteString
                let theDate = self.getCurrentDateAndTime()
                let time = Date().timeIntervalSince1970
                
                documentReference.getDocument { doc, error in
                
                    if let document = doc {
                        
                        if (document.exists){
                            
                            self.updateDatabase(reference: documentReference,
                                        url: theDownloadURL,
                                        date: theDate,
                                        time: time)
                            
                        }
                        else {
                            
                            self.db.collection("securityEvents")
                                .document(email)
                                .setData(["creation": [time],
                                                       "dates": [theDate],
                                                       "urls": [theDownloadURL]], merge: true) { error in
                                if let e = error {
                                    self.delegate?.error(aError: e)
                                }
                                else {
                                    self.delegate?.pictureUploaded()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

}
    
    func createInitialPosting(reference: DocumentReference,
                              url: String,
                              date: String,
                              time: TimeInterval ){
        
        reference.setData(["creation": [time],
                           "dates": [date],
                           "urls": [url]], merge: true) { error in
            
            if let e = error {
                self.delegate?.error(aError: e)
            }
            else {
                self.delegate?.pictureUploaded()
        }
    }
 
}
    
    func updateDatabase(reference: DocumentReference,
                     url: String,
                     date: String,
                     time: TimeInterval ) {
        
        
        reference.updateData(["creation": FieldValue.arrayUnion([time]),
                              "dates": FieldValue.arrayUnion([date]),
                              "urls": FieldValue.arrayUnion([url])]) { error in
            if let e = error {
                self.delegate?.error(aError: e)
            }
            else {
                self.delegate?.pictureUploaded()
            }
        }
    }
    
    
    func getCurrentDateAndTime () -> String {
        
        let currentDateTime = Date()
        
        let formatter = DateFormatter()
        
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        
        let dateTimeString = formatter.string(from: currentDateTime)
        
        return dateTimeString
    }

}

