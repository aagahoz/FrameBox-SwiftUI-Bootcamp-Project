//
//  MoviesViewModel.swift
//  FrameBox
//
//  Created by Agah Ozdemir on 20.09.2025.
//

import SwiftUI

final class MoviesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var movies: [MovieModel] = []
    @Published var cartMovies: [CartMovieModel] = []
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    private let networkManager = MoviesNetworkManager()
    
    // MARK: - Public Methods
    
    /// Tüm filmleri çek
    func loadMovies() {
        networkManager.fetchMovies { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let movies):
                    self?.movies = movies
                    print("✅ Movies fetched: \(movies.count)")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Sepetteki filmleri çek
    func loadCartMovies() {
        networkManager.fetchCartMovies { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let cartItems):
                    self?.cartMovies = cartItems
                    print("🛒 Cart fetched: \(cartItems.count)")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ Cart fetch error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Görsel URL
    func imageURL(for fileName: String?) -> URL? {
        guard let fileName else { return nil }
        return networkManager.imageURL(fileName: fileName)
    }
    
    /// Sepete film ekle
    func addToCart(movie: MovieModel) {
        networkManager.insertMovie(movie: movie, orderAmount: 1) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    print("🛒 Insert Success:", message)
                    // Opsiyonel: Sepeti otomatik güncelle
                    self.loadCartMovies()
                case .failure(let error):
                    print("❌ Insert Error:", error.localizedDescription)
                }
            }
        }
    }
    
    /// Sepetten film sil
    func deleteFromCart(cartMovie: CartMovieModel) {
        networkManager.deleteCartMovie(cartId: cartMovie.cartId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    print("🗑️ Delete Success:", message)
                    // Sepeti otomatik güncelle
                    self?.loadCartMovies()
                case .failure(let error):
                    print("❌ Delete Error:", error.localizedDescription)
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
