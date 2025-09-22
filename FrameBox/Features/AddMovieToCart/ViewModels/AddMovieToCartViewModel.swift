//
//  CartViewModel.swift
//  FrameBox
//
//  Created by Agah Ozdemir on 22.09.2025.
//

import Foundation
import SwiftUI

final class AddMovieToCartViewModel: ObservableObject {
    private let networkManager = MoviesNetworkManager()
    
    @Published var isAdding: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    /// Sepete film ekle
    func addToCart(movie: MovieModel, amount: Int = 1) {
        isAdding = true
        networkManager.insertMovie(movie: movie, orderAmount: amount) { [weak self] result in
            DispatchQueue.main.async {
                self?.isAdding = false
                switch result {
                case .success(let message):
                    self?.successMessage = message
                    print("🛒 Insert Success:", message)
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ Insert Error:", error.localizedDescription)
                }
            }
        }
    }
}
