//
//  Networking.swift
//  ImagEngine
//
//  Created by Melissa Zellhuber on 9/10/18.
//  Copyright © 2018 mzellhuber. All rights reserved.
//

import Foundation

import UIKit

class Networking{
    
    func getData(url:String, params:[String : String], onSuccess: @escaping (Data) -> Void, onError: @escaping (Error) -> Void){
        
        var urlComponents = URLComponents(string: url)
        
        var queryItems = [URLQueryItem]()
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        urlComponents?.queryItems = queryItems
        
        var request = URLRequest(url: (urlComponents?.url!)!)
        //print(request)
        request.httpMethod = "GET"
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                onError(error)
                return
            }
            
            guard let _data = data else {
                onError(error!)
                return
            }
            
            onSuccess(_data)
            }.resume()
    }
}
