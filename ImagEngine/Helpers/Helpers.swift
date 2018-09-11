//
//  Helpers.swift
//  ImagEngine
//
//  Created by Melissa Zellhuber on 9/10/18.
//  Copyright © 2018 mzellhuber. All rights reserved.
//

import Foundation
import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func downloadImageWith(string:String) {
        let url = URL(string: string)
        
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: string as AnyObject) as? UIImage {
            self.image = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: url!) {
            data, response, error in
            
            if error != nil{
                //print(error!)
                return
            }
            
            DispatchQueue.main.async {
                let imageToCache = UIImage(data: data!)
                imageCache.setObject(imageToCache!, forKey: string as AnyObject)
                self.image = imageToCache
            }
            }.resume()
    }
}
