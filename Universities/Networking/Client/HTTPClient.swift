//
//  HTTPClient.swift
//  Universities
//
//  Created by Trent Hamilton on 10/28/25.
//

import Foundation
import Network

enum HTTPError: LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case badStatusCode(Int)
    case decodingFailed(Error)
    case noConnection

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed:
            return "Network request failed. Please check your connection."
        case .invalidResponse:
            return "Invalid response from server"
        case .badStatusCode(let code):
            return "Server error (\(code))"
        case .decodingFailed:
            return "Failed to process server response"
        case .noConnection:
            return "No internet connection available"
        }
    }
    
    var underlyingError: Error? {
        switch self {
        case .requestFailed(let error), .decodingFailed(let error):
            return error
        default:
            return nil
        }
    }
}

final class HTTPClient {
    static let shared = HTTPClient()
    
    private let decoder: JSONDecoder
    private let monitor: NWPathMonitor
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    private var isConnected: Bool = true
    
    private init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
        self.monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: monitorQueue)
    }
    
    deinit {
        monitor.cancel()
    }

    func send<R: APIRequest>(_ request: R) async throws -> R.Response {
        guard isConnected else {
            throw HTTPError.noConnection
        }        
        let urlRequest: URLRequest
        do {
            urlRequest = try request.build()
        } catch {
            throw HTTPError.invalidURL
        }
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: urlRequest)
        } catch {
            throw HTTPError.requestFailed(error)
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw HTTPError.badStatusCode(httpResponse.statusCode)
        }
        do {
            return try decoder.decode(R.Response.self, from: data)
        } catch {
            throw HTTPError.decodingFailed(error)
        }
    }
}
