//
//  UniversityViewModel.swift
//  Universities
//
//  Created by Trent Hamilton on 10/28/25.
//

import Combine
import SwiftUI
import Foundation

class UniversityViewModel: ObservableObject {
    
    enum LoadingState {
        case empty, idle, loading, failure(String)
    }
    
    let navigationTitle: String = "Universities"
    let placeHolder: String = "Search ..."
    
    @Published var universities: [UniversityRowModel] = []
    @Published var viewState: LoadingState = .idle
    @Published var query: String = ""
    @Published var debouncedQuery: String = ""
    @Published var isLoadingMore: Bool = false
    
    private var page: Int = 1
    private var canLoadMore: Bool = true
    private var isCurrentlyLoading: Bool = false
    
    init() {
        $query
            .debounce(for: .seconds(0.75), scheduler: RunLoop.main)
            .assign(to: &$debouncedQuery)
    }
    
    @MainActor
    func search(query: String = "") async {
        viewState = .loading
        page = 1
        canLoadMore = true
        isCurrentlyLoading = true
        do {
            let result = try await request(query: query, page: page)
            universities = result
            viewState = (result.isEmpty) ? .empty : .idle
            canLoadMore = !result.isEmpty
        } catch {
            viewState = .failure(error.localizedDescription)
        }

        isCurrentlyLoading = false
    }
    
    @MainActor
    func loadMoreIfNeeded(currentItem: UniversityRowModel) async {
        guard let index = universities.firstIndex(where: { $0.id == currentItem.id }) else { return }
        let threshold = universities.count - 5
        guard index >= threshold else { return }
        await loadMore()
    }
    
    @MainActor
    func loadMore() async {
        guard canLoadMore, !isCurrentlyLoading, !isLoadingMore else { return }
        isLoadingMore = true
        isCurrentlyLoading = true
        page += 1
        do {
            let result = try await request(query: debouncedQuery, page: page)
            universities.append(contentsOf: result)
            canLoadMore = !result.isEmpty
        } catch {
            print("Error loading more: \(error.localizedDescription)")
            page -= 1
        }
        isLoadingMore = false
        isCurrentlyLoading = false
    }
    
    private func request(query: String, page: Int) async throws -> [UniversityRowModel] {
        let request = GetUniversitiesSearchRequest(name: query, page: page)
        let result = try await UniversitiesService.shared.requestUniversities(request)
        return result.map { UniversityRowModel(university: $0) }
    }
}

extension UniversityViewModel {
    
    static var mock: UniversityViewModel = UniversityViewModel(rowModels: [])
    
    convenience init(rowModels: [UniversityRowModel]) {
        self.init()
        self.universities = rowModels
    }
}

struct UniversityRowModel: Identifiable {
    let id: UUID
    let name: String
    let webPage: String?
    let location: String?
    
    init(university: University) {
        id = UUID(uuidString: university.name.hashValue.description) ?? UUID()
        name = university.name
        webPage = university.webPages.first
        location = Self.buildLocation(university: university)
    }
    
    static func buildLocation(university: University) -> String? {
        guard var location: String = university.country else { return nil }
        if let stateProvince = university.stateProvince {
            location = "\(stateProvince), \(location)"
        }
        return location
    }
}
