//
//  ViewController.swift
//  Omarview
//
//  Created by Lucy Chai on 9/10/16.
//  Copyright © 2016 Lucy Chai. All rights reserved.
//

import UIKit
import EventKitUI
import AVFoundation
import TesseractOCR


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, EKEventEditViewDelegate, G8TesseractDelegate {
    
    @IBOutlet weak var ImageDisplay: UIImageView!
    
    var shouldDisplayCamera = true;
    var audioPlayer = AVAudioPlayer()
    let tapCamera = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (self.shouldDisplayCamera) {
            self.launchCameraPicker()
            self.shouldDisplayCamera = false;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func moooer(_ recognizer: UITapGestureRecognizer) {
        let mooSound = URL(fileURLWithPath: Bundle.main.path(forResource: "moo", ofType: "m4a")!)
        do{
            audioPlayer = try AVAudioPlayer(contentsOf:mooSound)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }catch {
            print("Error getting the audio file")
        }
    }
    
    @IBAction func openCameraPicker(_ recognizer: UITapGestureRecognizer) {
        self.launchCameraPicker()
    }
    
    @IBAction func openImagePicker(_ recognizer: UITapGestureRecognizer) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func launchCameraPicker() {
        if UIImagePickerController.isCameraDeviceAvailable( UIImagePickerControllerCameraDevice.rear) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // adds event to calendar
    func addToCalendar(_ title: String, dateResult: NSTextCheckingResult?, location: String, description: String, url: URL?) {
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
            
            event.url = urlObj
        }
        
        if let drObj = dateResult {
            assert(drObj.resultType == NSTextCheckingResult.CheckingType.date)
            
            event.startDate = drObj.date!
            event.endDate = drObj.date!.addingTimeInterval(drObj.duration)
        }
        
        eventController.event = event
        
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .authorized:
            //self.setNavBarAppearanceStandard()
            DispatchQueue.main.async(execute: { () -> Void in
                self.present(eventController, animated: true, completion: nil)
            })
            
        case .notDetermined:
            store.requestAccess(to: .event, completion: { (granted, error) -> Void in
                if granted == true {
                    //self.setNavBarAppearanceStandard()
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.present(eventController, animated: true, completion: nil)
                    })
                }
            })
        case .denied, .restricted:
            let alert = UIAlertController(title: "Access Denied", message:"Permission is needed to access the " +
                "calendar. Go to Settings > Privacy > Calendars to allow access for the CalPal app.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
            self.present(alert, animated: true){}
            return
        }
    }
    
    // called after image has been picked
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String :
        Any]) {
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                
                // Save to library if camera
                if (picker.sourceType == .camera) {
                    UIImageWriteToSavedPhotosAlbum(pickedImage, nil, nil, nil)
                }
                
                //let img = UIImage(named: "Image")
                let img = pickedImage
                
                if let tesseract = G8Tesseract(language: "eng") {

                    // run OCR in background
                    backgroundThread(background: {
                        tesseract.delegate = self
                        tesseract.image = img.g8_grayScale()
                        tesseract.recognize()
                    },
                    completion: {
                        LoadingIndicatorView.hide()
                        
                        let info = tesseract.recognizedBlocks(by: G8PageIteratorLevel.textline)
                        
                        let text = tesseract.recognizedText
                        
                        var maxHeight = 0
                        var title = ""
                        for item in info! {
                            let b = item as? G8RecognizedBlock
                            let height = b?.boundingBox(atImageOf: (img.size)).height
                            if Int(height!) > maxHeight {
                                maxHeight = Int(height!)
                                title = (b?.text)!
                            }
                        }

                        self.populateCalendarEvent(text!, title: title)
                    })
                }
                LoadingIndicatorView.show()
                
            }
            dismiss(animated: true, completion: nil)
    }

    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction){
        self.dismiss(animated: true, completion: nil)
    }
    
    // prints progress to debugging console
    func progressImageRecognition(for tesseract: G8Tesseract!) {
        print("Recognition Progress \(tesseract.progress) %")
    }
    
    
    // parse info from OCR text and add calendar event
    func populateCalendarEvent(_ str: String, title: String) {
        let urlObj = parseUrlFromStr(str)
        let addrObj = parseAddrFromStr(str)
        let dateObj = parseDateFromStr(str)
        
        var addrStr = ""

        if let addr = addrObj {
            assert(addrObj?.resultType == NSTextCheckingResult.CheckingType.address)
            for (_, name) in addr.components! {
                addrStr = addrStr + name + " "
            }
        }
        
        self.addToCalendar(title, dateResult: dateObj, location: addrStr, description: str, url: urlObj)
    }
    
    
    // create a background thread and callback
    func backgroundThread(background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        
        DispatchQueue.global(qos: .background).async {
            if(background != nil){ background!(); }
            
            DispatchQueue.main.async {
                if(completion != nil){ completion!(); }
            }
        }
    }
    
    // hard-coded string for testing parsing
    func testAddCalendar() {
        let str = "BORDER CANTOS RICHARD MISRACH & GUILLERMO GALINDO TUESDAY, SEPTEMBER 27 AT 7:30-9:00PM MCCORMICK 101 Join us for an evening of photography by Richard Mis- rach, who has spent years documenting thet.S Mexican border, and music by Guillermo Galindo who has made musical instruments out of remains left bymigrants trying to cross the www.hackerswift.com border. WILSON COLLEGE SIGNATURE LECTURE SERIES FALL 2016 GABY MORENO LATIN GRAMMY AWARD WINNER WEDNESDAY OCTOBER 26 AT 8:00PM RICHARDSON AUDITORIUM Guatemalan singer Gaby Moreno is the winnerof the 2013 Latin Grammy for Best NewArtist, and will be performing a wonderful program with herband in Richardson. "
        
        let dateObj = parseDateFromStr(str)
        let urlObj = parseUrlFromStr(str)
        
        self.addToCalendar("Test", dateResult: dateObj, location: "Test 1", description: "Omar 4 life", url: urlObj)
        
    }

}


