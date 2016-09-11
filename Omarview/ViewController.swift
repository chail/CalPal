//
//  ViewController.swift
//  Omarview
//
//  Created by Lucy Chai on 9/10/16.
//  Copyright © 2016 Lucy Chai. All rights reserved.
//

import UIKit
import EventKitUI
import SwiftyJSON

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, EKEventEditViewDelegate {
    
    @IBOutlet weak var ImageDisplay: UIImageView!
    
    var shouldDisplayCamera = true;
    let tapCamera = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        if (self.shouldDisplayCamera) {
            self.launchCameraPicker()
            self.shouldDisplayCamera = false;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openCameraPicker(recognizer: UITapGestureRecognizer) {
        self.launchCameraPicker()
    }
    
    @IBAction func openImagePicker(recognizer: UITapGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func launchCameraPicker() {
        if UIImagePickerController.isCameraDeviceAvailable( UIImagePickerControllerCameraDevice.Rear) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func addToCalendar(title: String, dateResult: NSTextCheckingResult?, location: String, description: String, url: NSURL?) {
        let eventController = EKEventEditViewController()
        
        let store = EKEventStore()
        eventController.eventStore = store
        eventController.editViewDelegate = self
        
        // Create event
        let event = EKEvent(eventStore: store)
        event.title = title
        event.location = location
        event.notes = description
        
        if let urlObj = url {
            
            event.URL = urlObj
        }
        
        if let drObj = dateResult {
            assert(drObj.resultType == NSTextCheckingType.Date)
            
            event.startDate = drObj.date!
            event.endDate = drObj.date!.dateByAddingTimeInterval(drObj.duration)
        }
        
        eventController.event = event
        
        let status = EKEventStore.authorizationStatusForEntityType(.Event)
        switch status {
        case .Authorized:
            //self.setNavBarAppearanceStandard()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.presentViewController(eventController, animated: true, completion: nil)
            })
            
        case .NotDetermined:
            store.requestAccessToEntityType(.Event, completion: { (granted, error) -> Void in
                if granted == true {
                    //self.setNavBarAppearanceStandard()
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.presentViewController(eventController, animated: true, completion: nil)
                    })
                }
            })
        case .Denied, .Restricted:
            let alert = UIAlertController(title: "Access Denied", message:"Permission is needed to access the " +
                "calendar. Go to Settings > Privacy > Calendars to allow access for the CalPal app.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
            self.presentViewController(alert, animated: true){}
            return
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String :
        AnyObject]) {
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                // CloudVision call
                let vision = CloudVision(callbackObject: self)
                // Base64 encode the image and create the request
                let binaryImageData = vision.base64EncodeImage(pickedImage)
                vision.createRequest(binaryImageData)
                LoadingIndicatorView.show()
                
            }
            dismissViewControllerAnimated(true, completion: nil)
            
    }
    
    func eventEditViewController(controller: EKEventEditViewController, didCompleteWithAction action: EKEventEditViewAction){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func testAddCalendar() {
        let str = "BORDER CANTOS RICHARD MISRACH & GUILLERMO GALINDO TUESDAY, SEPTEMBER 27 AT 7:30-9:00PM MCCORMICK 101 Join us for an evening of photography by Richard Mis- rach, who has spent years documenting thet.S Mexican border, and music by Guillermo Galindo who has made musical instruments out of remains left bymigrants trying to cross the www.hackerswift.com border. WILSON COLLEGE SIGNATURE LECTURE SERIES FALL 2016 GABY MORENO LATIN GRAMMY AWARD WINNER WEDNESDAY OCTOBER 26 AT 8:00PM RICHARDSON AUDITORIUM Guatemalan singer Gaby Moreno is the winnerof the 2013 Latin Grammy for Best NewArtist, and will be performing a wonderful program with herband in Richardson. "
        
        let dateObj = parseDateFromStr(str)
        let urlObj = parseUrlFromStr(str)
        
        self.addToCalendar("Test", dateResult: dateObj, location: "Test 1", description: "Omar 4 life", url: urlObj)

    }
    
    func populateCalendarEvent(str: String, title: String) {
        let urlObj = parseUrlFromStr(str)
        let addrObj = parseAddrFromStr(str)
        let dateObj = parseDateFromStr(str)
        
        var addrStr = ""

        if let addr = addrObj {
            assert(addrObj?.resultType == NSTextCheckingType.Address)
            for (_, name) in addr.components! {
                addrStr = addrStr + name + " "
            }
        }
        
        self.addToCalendar(title, dateResult: dateObj, location: addrStr, description: str, url: urlObj)
    }
    
    func dataParseCallback(dataToParse: NSData) {
        LoadingIndicatorView.hide()
        // Use SwiftyJSON to parse results
        let json = JSON(data: dataToParse)
        let errorObj: JSON = json["error"]
        
        // Check for errors
        if (errorObj.dictionaryValue != [:]) {
            print("Error")
        } else {
            // Parse the response
            
            var maxHeight = 0
            var title = ""
            for line in parseLines(json) {
                if line.height() > maxHeight {
                    maxHeight = line.height()
                    title = line.text
                }
            }
            
            let responses: JSON = json["responses"][0]
            
            let textAnnotations: JSON = responses["textAnnotations"]
            let numLabels: Int = textAnnotations.count
            //var labels: Array<String> = []
            if numLabels > 0 {
                let text = textAnnotations[0]["description"].stringValue
                self.populateCalendarEvent(text, title: title)
                
            } else {
                let alert = UIAlertController(title: "No Results", message:"We were unable to parse any text. However, feel free to add the content yourself.", preferredStyle: .Alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                    // ...
                }
                alert.addAction(cancelAction)
                
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    self.populateCalendarEvent("", title:"")
                }
                alert.addAction(OKAction)

                self.presentViewController(alert, animated: true){}
            }
            //TODO: stub for kelly's function
            
        }
        
    }

}


