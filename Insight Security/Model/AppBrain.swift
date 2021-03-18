//
//  AppBrain.swift
//  Insight Security
//
//  Created by Richard Basdeo on 3/18/21.
//

import Foundation
import Firebase
import Photos

class AppBrain {
    
    let storage = Storage.storage()
    
    func updloadImage (photo: AVCapturePhoto) {
        
        let storageReference = storage.reference()
        
        let imagesRef = storageReference.child("securityTriggers")
        
        let fileName = "\(NSTimeIntervalSince1970).jpg"
        
        let spaceRef = imagesRef.child(fileName)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        var temp: UIImage?
        // Try getting preview photo
          if let previewPixelBuffer = photo.previewPixelBuffer {
            var previewCiImage = CIImage(cvPixelBuffer: previewPixelBuffer)
            // If we managed to get the oreintation, update the image
            if let previewCgImage = CIContext().createCGImage(previewCiImage, from: previewCiImage.extent) {
              temp = UIImage(cgImage: previewCgImage)
            }
          }
        
        guard let temp2 = temp?.pngData() else {return}

        
        
        // Upload data and metadata
        imagesRef.putData(temp2, metadata: nil)

        // Upload file and metadata
        //imagesRef.putFile(from: temp2, metadata: metadata)
        
    }
}
