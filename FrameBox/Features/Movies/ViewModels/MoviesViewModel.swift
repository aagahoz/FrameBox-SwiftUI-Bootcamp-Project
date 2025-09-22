//
//  MoviesViewModel.swift
//  FrameBox
//
//  Created by Agah Ozdemir on 21.09.2025.
//

import Foundation

@MainActor
final class MoviesViewModel: ObservableObject {
    @Published var movies: [MovieModel] = []
    @Published var searchText: String = ""

    private let network = MoviesNetworkManager()
    
    func loadMovies() {
        network.fetchMovies { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movies):
                    self?.movies = movies
                case .failure(let error):
                    print("Filmler yüklenemedi:", error)
                }
            }
        }
    }
    
    func imageURL(for imageName: String) -> URL? {
        return network.imageURL(fileName: imageName)
    }

    var filteredMovies: [MovieModel] {
        if searchText.isEmpty {
            return movies
        } else {
            return movies.filter { ($0.name ?? "").localizedCaseInsensitiveContains(searchText) }
        }
    }
}
