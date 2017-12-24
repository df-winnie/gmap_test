//
//  WebService.swift
//  gmap_test
//
//  Created by Ziting Wei on 21/12/2017.
//  Copyright © 2017 df-dev. All rights reserved.
//

import Foundation

struct bikeSite {
    var name:String
    var lng:Double
    var lat:Double
    var addr:String
}

class WebService {
    
    class func bikeSites (urlStr:String, completion:((_ list:[bikeSite]?, _ error:Error?) -> Swift.Void)?) {
        //((_ list:[ReportRecord]?, _ errorType:StoreErrorType?) -> Swift.Void)?) {
       
        let defaultSession = URLSession(configuration: .default)
        var dataTask:URLSessionDataTask?
        
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: urlStr) {
            
            urlComponents.query = ""
            
            guard let url = urlComponents.url else { return }
            
            dataTask = defaultSession.dataTask(with: url, completionHandler: { (data, response, error) in
                defer { dataTask = nil }
                
                if let err = error {
//                    self.errorMessage += "DataTask error: " + error.localizedDescription  = "\n"
                    print("DataTask error" + err.localizedDescription)
                    completion!(nil, err)

                } else if let data = data,
                  let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    // success
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                        
                        var sArray = [bikeSite]()
                        
                        for (_, subJson) in json!["retVal"] as! [String:Any] {
                            let value = subJson as! [String:Any]
                            let site = bikeSite(
                                name: value["sna"] as! String,
                                lng: Double(value["lng"] as! String)!,
                                lat:  Double(value["lat"] as! String)!,
                                addr: value["ar"] as! String
                            )
                            sArray.append(site)
                        }
                        
                        completion!(sArray, nil)
                    } catch {
                        print(error)
                    }
                } 
            })
            
            dataTask?.resume()
        }
    }
}
