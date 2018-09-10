//
//  Helpers.swift
//  ImagEngine
//
//  Created by Melissa Zellhuber on 9/10/18.
//  Copyright © 2018 mzellhuber. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func downloadImageWith(string:String) {
        let url = URL(string: string)
        
        image = nil
        
        URLSession.shared.dataTask(with: url!) {
            data, response, error in
            
            if error != nil{
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
            }.resume()
    }
}
