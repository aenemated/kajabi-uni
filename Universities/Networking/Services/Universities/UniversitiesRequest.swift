//
//  UniversitiesRequest.swift
//  Universities
//
//  Created by Trent Hamilton on 10/28/25.
//

import Foundation

struct GetUniversitiesSearchRequest: APIRequest {
    
    typealias Response = [University]
    
    let path = "/search"
    let method: APIRequestMethod = .GET
    var name: String?
    var page: Int = 1
    
    private let limit: Int = 20
    
    var queryItems: [URLQueryItem]? {
        var items: [URLQueryItem] = []
        if let name { items.append(URLQueryItem(name: "name", value: name)) }
        let offset: Int = ((page - 1) * limit)
        items.append(URLQueryItem(name: "offset", value: String(offset)))
        items.append(URLQueryItem(name: "limit", value: String(limit)))
        return items.isEmpty ? nil : items
    }
    
}
