//
//  UniversitiesService.swift
//  Universities
//
//  Created by Trent Hamilton on 10/28/25.
//

final class UniversitiesService {
    
    static let shared: UniversitiesService = UniversitiesService()
    private let client: HTTPClient = HTTPClient.shared
    
    init() {}
    
    func requestUniversities(_ request: GetUniversitiesSearchRequest) async throws -> [University] {
        do {
            return try await client.send(request)
        } catch {
            throw error
        }
    }
}
