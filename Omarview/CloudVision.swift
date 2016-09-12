//
//  CloudVision.swift
//  imagepicker
//
//  Created by Lucy Chai on 9/10/16.
//  Copyright © 2016 Sara Robinson. All rights reserved.
//

import UIKit
import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class CloudVision: NSObject {
    
    let callbackObject: ViewController
    
    init(callbackObject :ViewController) {
        // set the controller to callback object
        self.callbackObject = callbackObject
    }
    
    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata?.count > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    func createRequest(_ imageData: String) {
        
        // Create our request URL
        let request = NSMutableURLRequest(
            url: URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(API_KEY)")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(
            Bundle.main.bundleIdentifier ?? "",
            forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API request
        let jsonRequest: [String: Any] = [
            "requests": [
                "image": [
                    "content": imageData
                ],
                "features": [
                    [
                        "type": "TEXT_DETECTION",
                        "maxResults": 1
                    ]
                ]
            ]
        ]
        
        // Serialize the JSON
        request.httpBody = try! JSONSerialization.data(withJSONObject: jsonRequest, options: [])
        
        // Run the request on a background thread
        DispatchQueue.main.async {
            self.runRequestOnBackgroundThread(request as URLRequest)
        }
        //DispatchQueue.main.async(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
        //    self.runRequestOnBackgroundThread(request as URLRequest)
        //});
    }
    
    func runRequestOnBackgroundThread(_ request: URLRequest) {
        
        let session = URLSession.shared
        
        // run the request
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            self.analyzeResults(data, error: error)
        })
        task.resume()
    }
    
    func analyzeResults(_ dataToParse: Data?, error: Error?) {
        guard error == nil else {
            print("Error")
            DispatchQueue.main.async(execute: {
                self.callbackObject.connectionError()
            })
            return
        }
            //DispatchQueue.main.async(execute: {
             //   self.callbackObject.dataParseCallback(dataToParse!)
            //})
        
        // Update UI on the main thread
        DispatchQueue.main.async(execute: {
            self.callbackObject.dataParseCallback(dataToParse!)
        })
        
    }
    
}
