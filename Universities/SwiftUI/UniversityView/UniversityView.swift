//
//  UniversityView.swift
//  Universities
//
//  Created by Trent Hamilton on 10/28/25.
//

import SwiftUI

struct UniversityView: View {
    
    @StateObject var viewModel: UniversityViewModel = UniversityViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                universitiesList
                stateView
            }
        }
    }
    
    var universitiesList: some View {
        List {
            ForEach(viewModel.universities) { rowModel in
                UniversityRow(rowModel: rowModel)
                    .onAppear {
                        Task {
                            await viewModel.loadMoreIfNeeded(currentItem: rowModel)
                        }
                    }
            }
            
            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .searchable(
            text: $viewModel.query,
            placement: .navigationBarDrawer,
            prompt: viewModel.placeHolder
        )
        .navigationTitle(viewModel.navigationTitle)
        .scrollDismissesKeyboard(.immediately)
        .onChange(of: viewModel.debouncedQuery) {
            Task {
                await viewModel.search(query: viewModel.debouncedQuery)
            }
        }
        .task {
            await viewModel.search()
        }
    }
    
    var stateView: some View {
        Group {
            switch viewModel.viewState {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView()
            case .empty:
                unavailableView(title: "No Results", message: "No results found for \"\(viewModel.debouncedQuery).\"")
            case .failure(let error):
                unavailableView(title: "Error", message: error)
            }
        }
    }
    
    func unavailableView(title: String, message: String) -> some View {
        ContentUnavailableView(
            title,
            systemImage: "exclamationmark.triangle",
            description: Text(message)
        )
    }
}

struct UniversityRow: View {
    
    let rowModel: UniversityRowModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3.0) {
            Text(rowModel.name)
                .font(.headline)
            if let webPage = rowModel.webPage,
               let url = URL(string: webPage) {
                Link(webPage, destination: url)
                    .font(.caption)
                    .foregroundStyle(Color.blue)
            }
            if let location = rowModel.location {
                Text("🌐 \(location)")
                    .font(.caption2)
            }
        }
    }
}

#Preview {
    UniversityView(viewModel: UniversityViewModel.mock)
}
