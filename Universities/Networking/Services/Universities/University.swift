//
//  University.swift
//  Universities
//
//  Created by Trent Hamilton on 10/28/25.
//

import Foundation

struct University: Codable {
    
    let alphaTwoCode: String
    let name: String
    let stateProvince: String?
    let webPages: [String]
    let domains: [String]
    let country: String?

    enum CodingKeys: String, CodingKey {
        case alphaTwoCode = "alpha_two_code"
        case name
        case stateProvince = "state-province"
        case webPages = "web_pages"
        case domains
        case country
    }
}
