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
    let stat : String?
    
    enum CodingKeys: String, CodingKey {
        
        case person = "person"
        case stat = "stat"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        person = try values.decodeIfPresent(Person.self, forKey: .person)
        stat = try values.decodeIfPresent(String.self, forKey: .stat)
    }
}


struct Person : Codable {
    let id : String?
    let nsid : String?
    let username : Username?
    let photos : Photos?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case nsid = "nsid"
        case username = "username"
        case photos = "photos"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        nsid = try values.decodeIfPresent(String.self, forKey: .nsid)
        username = try values.decodeIfPresent(Username.self, forKey: .username)
        photos = try values.decodeIfPresent(Photos.self, forKey: .photos)
    }
}

struct Username : Codable {
    let _content : String?
    
    enum CodingKeys: String, CodingKey {
        
        case _content = "_content"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        _content = try values.decodeIfPresent(String.self, forKey: ._content)
    }
}
