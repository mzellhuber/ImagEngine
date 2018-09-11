//
//  Photos.swift
//  ImagEngine
//
//  Created by Melissa Zellhuber on 9/10/18.
//  Copyright © 2018 mzellhuber. All rights reserved.
//

import Foundation

struct Photos : Codable {
    let page : Int?
    let pages : Int?
    let perpage : Int?
    let photos : [Photo]?
    
    enum CodingKeys: String, CodingKey {
        
        case page = "page"
        case pages = "pages"
        case perpage = "perpage"
        case photos = "photo"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        page = try values.decodeIfPresent(Int.self, forKey: .page)
        pages = try values.decodeIfPresent(Int.self, forKey: .pages)
        perpage = try values.decodeIfPresent(Int.self, forKey: .perpage)
        photos = try values.decodeIfPresent([Photo].self, forKey: .photos)
    }
    
}
