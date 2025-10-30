//
//  APIRequest.swift
//  Universities
//
//  Created by Trent Hamilton on 10/28/25.
//

import Foundation

enum APIRequestMethod: String {
    case GET, POST, PUT, DELETE
}

enum APIRequestError: LocalizedError {
    case invalidBaseURL
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .invalidBaseURL: return "Base URL is not configured"
        case .invalidURL: return "Failed to construct valid URL"
        }
    }
}

protocol APIRequest {
    associatedtype Response: Decodable
    
    var path: String { get }
    var method: APIRequestMethod { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Data? { get }
    var headers: [String: String]? { get }
}

extension APIRequest {

    var method: APIRequestMethod { .GET }
    var queryItems: [URLQueryItem]? { nil }
    var body: Data? { nil }
    var headers: [String: String]? { nil }
    
    func build() throws -> URLRequest {
        guard let baseURL = Constants.baseURL else {
            throw APIRequestError.invalidBaseURL
        }
        var url = baseURL.appendingPathComponent(path)
        if let queryItems = queryItems {
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw APIRequestError.invalidURL
            }
            components.queryItems = queryItems
            guard let finalURL = components.url else {
                throw APIRequestError.invalidURL
            }
            url = finalURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        return request
    }
}
