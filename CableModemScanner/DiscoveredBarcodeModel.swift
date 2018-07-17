//
//  DiscoveredBarcodeView.swift
//  CableModemScanner
//
//  Created by Sheik Tajudeen  on 12/9/16.
//  Copyright © 2016 Sheik Tajudeen . All rights reserved.
//

import Foundation

class DiscoveredBarCodeModel {
    
    private var actStatus = "";
    private var accountNumber = "";
    private var teleNumber = ""
    
    var activationStatus: String {
        get{
            return self.actStatus
        }
    }
    var acntNumber: String {
        get{
            return self.accountNumber
        }
    }
    var tN: String {
        get{
            return self.teleNumber
        }
    }
    
    func makeGetCall() -> (String,String,String){
        let parseData = parseJSON(inputData: getJSON(urlToRequest: "https://app-mobile-activation.b2.app.cloud.comcast.net/MobileCall/getAccount/test"))
        let actStatusGet = parseData.value(forKey: "activationSuccess")
        let accountNumberGet = parseData.value(forKey: "accountNumber")
        let teleNumberGet = parseData.value(forKey: "telephoneNumber")
        return (actStatusGet as! String,accountNumberGet as! String,teleNumberGet as! String)
    }
    
    func makePostCall(macAddress: String, callback: @escaping (String) -> ()){
        let urlString = "https://app-mobile-activation.b2.app.cloud.comcast.net/MobileCall/doActivation/" + macAddress
        print(urlString)
        var request = URLRequest(url: URL(string: urlString)!)
        
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(error)")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            if let responseString = String(data: data, encoding: .utf8){
                print("responseString = \(responseString)")
                callback(responseString)
                //let dataNew = responseString.data(using: .utf8)!
                //if let parseData = try? JSONSerialization.jsonObject(with: dataNew) as! [String:Any]{
                //    print("Inside")
                //    self.actStatus = parseData["activationSuccess"] as! String//parseData.value(forKey: "activationSuccess") as! String
                //    self.accountNumber = parseData["activationSuccess"] as! String//parseData.value(forKey: "accountNumber") as! String
                //    self.teleNumber = parseData["telephoneNumber"] as! String//parseData.value(forKey: "telephoneNumber") as! String
                //}
            }
        }
        task.resume()
    }
    
    func parseResponseJSON(responseJson: String){
        let dataNew = responseJson.data(using: .utf8)!
        if let parseData = try? JSONSerialization.jsonObject(with: dataNew) as! [String:Any]{
            self.actStatus = parseData["activationSuccess"] as! String
            self.accountNumber = parseData["accountNumber"] as! String
            self.teleNumber = parseData["telephoneNumber"] as! String
            print("actStatus \(activationStatus) acntNo \(acntNumber) TN \(tN)")
        }
    }
    private func getJSON(urlToRequest:String) -> NSData
    {
        return NSData(contentsOf: NSURL(string: urlToRequest)! as URL)!
    }
    
    private func parseJSON(inputData:NSData) -> NSDictionary{
        let dictData = (try! JSONSerialization.jsonObject(with: inputData as Data, options: .mutableContainers)) as! NSDictionary
        return dictData
    }
    
    private func parseJSONPOST(inputData: Data) -> NSDictionary{
        let dictData = (try! JSONSerialization.jsonObject(with: inputData as Data, options: .mutableContainers)) as! NSDictionary
        return dictData
    }
}

