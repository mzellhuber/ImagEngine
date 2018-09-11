//
//  Photo.swift
//  ImagEngine
//
//  Created by Melissa Zellhuber on 9/10/18.
//  Copyright © 2018 mzellhuber. All rights reserved.
//

import Foundation

struct Photo : Codable {
    let id : String?
    let owner : String?
    let secret : String?
    let server : String?
    let farm : Int?
    let title : String?
    let ispublic : Int?
    let isfamily : Int?
    let tags : String?
}
