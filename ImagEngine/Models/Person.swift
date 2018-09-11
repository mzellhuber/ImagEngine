//
//  Person.swift
//  ImagEngine
//
//  Created by Melissa Zellhuber on 9/11/18.
//  Copyright © 2018 mzellhuber. All rights reserved.
//

import Foundation

struct GetUserResponse : Codable {
    let person : Person?
}


struct Person : Codable {
    let id : String?
    let nsid : String?
    let username : Username?
    let photos : Photos?
    
}

struct Username : Codable {
    let _content : String?
}
