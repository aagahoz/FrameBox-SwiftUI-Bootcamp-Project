//
//  GetMoviesAtCartViewModel.swift
//  FrameBox
//
//  Created by Agah Ozdemir on 22.09.2025.
//

import Foundation
import SwiftUI

final class GetMoviesAtCartViewModel: ObservableObject {
    @Published var cartMovies: [CartMovieModel] = []
    @Published var errorMessage: String?

    private let networkManager = MoviesNetworkManager()
    
    init() {
        loadCartMovies()
    }
    
    /// Sepetteki filmleri çek
    func loadCartMovies() {
        print("Load Cart Movies")
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

    /// Sepetten film sil
    func deleteFromCart(cartMovie: CartMovieModel) {
        networkManager.deleteCartMovie(cartId: cartMovie.cartId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    print("🗑️ Delete Success:", message)
                    self?.loadCartMovies() // otomatik güncelle
                case .failure(let error):
                    print("❌ Delete Error:", error.localizedDescription)
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
