//
//  ViewController.swift
//  CableModemScanner
//
//  Created by Sheik Tajudeen  on 12/9/16.
//  Copyright © 2016 Sheik Tajudeen . All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate ,CLLocationManagerDelegate{
    
    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var barcode: String!
    var accountNumber = ""
    let locationManager = CLLocationManager()
    
    private var rest: DiscoveredBarCodeModel = DiscoveredBarCodeModel()
    
    
    @IBOutlet var viewAreaScan: UIView!
    @IBOutlet var lblMTN: UILabel!
    @IBOutlet var txtMTN: UITextField!
    @IBOutlet var lblAccountTN: UILabel!
    @IBOutlet var lblBarcodeScanned: UILabel!
    @IBOutlet var btnActivate: UIButton!
    @IBOutlet var btnOpt: UIButton!
    
    @IBAction func mtnBtnClick(_ sender: UIButton) {
        lblMTN.isHidden = false
        txtMTN.isHidden = false
        btnOpt.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view loaded")
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        btnActivate.isEnabled = false
        btnActivate.backgroundColor = UIColor.darkGray
        session = AVCaptureSession()
        let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let videoInput: AVCaptureDeviceInput?
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        if (session.canAddInput(videoInput)) {
            session.addInput(videoInput)
            print("input added")
        } else {
            scanningNotPossible()
        }
        let metadataOutput = AVCaptureMetadataOutput()
        if (session.canAddOutput(metadataOutput)) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeInterleaved2of5Code,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeCode128Code]
            print("Metadata captured")
        }
        else {
            scanningNotPossible()
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: session);
        previewLayer.frame = viewAreaScan.layer.bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        viewAreaScan.layer.addSublayer(previewLayer);
        session.startRunning()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view will appear")
        if (session?.isRunning == false) {
            session.startRunning()
        }
        lblMTN.isHidden = true
        txtMTN.isHidden = true
        btnActivate.isEnabled = false
        btnActivate.backgroundColor = UIColor.darkGray
        //btnActivate.setTitle("Start Activation", for: .normal)
        self.lblBarcodeScanned.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("view will disappear")
        if (session?.isRunning == true) {
            session.stopRunning()
        }
    }
    
    func scanningNotPossible() {
        let alert = UIAlertController(title: "Can't Scan.", message: "Let's try a device equipped with a camera.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        session = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            var placeMark: CLPlacemark!
            self.lblAccountTN.text = "Your approximate location is "
            placeMark = placemarks?[0]
            if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                self.lblAccountTN.text = self.lblAccountTN.text! + " " + (locationName as String) as String
            }
            //if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                
            //}
            if let city = placeMark.addressDictionary!["City"] as? NSString {
                self.lblAccountTN.text = self.lblAccountTN.text! + " " + (city as String) as String
            }
            if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                self.lblAccountTN.text = self.lblAccountTN.text! + " " + (zip as String) as String
            }
            
        })
        locationManager.stopUpdatingLocation()
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        session.stopRunning()
        print("inside capture output")
        for metadata in metadataObjects {
            let readableObject = metadata as! AVMetadataMachineReadableCodeObject;
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            barcodeDetected(code: readableObject.stringValue);
        }
        dismiss(animated: true)
    }
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    @IBAction func activateDevice(_ sender: UIButton) {
        rest.makePostCall(macAddress: barcode){jsonString in
            if let parseData = try? JSONSerialization.jsonObject(with: jsonString.data(using: .utf8)!) as! [String:Any]{
                DispatchQueue.main.async(execute: { () -> Void in
                    if (parseData["activationSuccess"] as! String) == "Success"{
                        self.lblBarcodeScanned.text = "Your Device has been successfully activated"
                        self.btnActivate.isEnabled = false
                        self.btnActivate.backgroundColor = UIColor.green
                        //self.btnActivate.setTitle("Activation Successful", for: .normal)
                        self.accountNumber = parseData["accountNumber"] as! String
                        //self.btnActivate.isHidden = true
                   // self.lblAccountTN.text = "Account # \(parseData["accountNumber"] as! String) and TN \(parseData["telephoneNumber"] as! String)"
                    }
                    else
                    {
                        self.lblBarcodeScanned.text = "Error in Activation"
                    }
                })

            }
        }
    }
    
    func barcodeDetected(code: String) {
        print("barcode detected")
        barcode = code
        lblBarcodeScanned.text = "Your mac address is \(code), touch Activate button to activate device"
        btnActivate.backgroundColor = UIColor.yellow
        btnActivate.isEnabled = true
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationSvc = segue.destination
        if let uidVvc = destinationSvc as? UIDViewController{
            if segue.identifier == "CreateUID"{
                uidVvc.accountNumber = self.accountNumber
            
            }
        }
        
    }
}

