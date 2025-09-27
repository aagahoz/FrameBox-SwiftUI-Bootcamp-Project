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

extension GetMoviesAtCartViewModel {
    /// Aynı filmden birden fazla varsa birleştir ve toplam adet hesapla
    var groupedCartMovies: [CartMovieModel] {
        let grouped = Dictionary(grouping: cartMovies, by: { $0.name })
        
        return grouped.map { (_, movies) in
            let first = movies.first!
            let totalAmount = movies.reduce(0) { $0 + $1.orderAmount }
            
            return CartMovieModel(
                cartId: first.cartId, // ilk cartId alıyoruz
                name: first.name,
                image: first.image,
                price: first.price,
                category: first.category,
                rating: first.rating,
                year: first.year,
                director: first.director,
                description: first.description,
                orderAmount: totalAmount, // tüm adetler toplandı
                userName: first.userName
            )
        }
        .sorted { $0.name < $1.name } // opsiyonel: alfabetik sıralama
    }
    
    /// Toplam tutar
    func totalAmount() -> Double {
        groupedCartMovies.reduce(0) { $0 + Double($1.price * $1.orderAmount) }
    }
}

extension GetMoviesAtCartViewModel {
    
    func increaseQuantity(for movie: CartMovieModel) {
        // 1️⃣ Tüm kayıtları sil
        let allMatches = cartMovies.filter { $0.name == movie.name }
        guard !allMatches.isEmpty else { return }

        let totalAmount = allMatches.reduce(0) { $0 + $1.orderAmount }

        let group = DispatchGroup()
        for item in allMatches {
            group.enter()
            networkManager.deleteCartMovie(cartId: item.cartId) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let message):
                        print("🗑️ Deleted cartId \(item.cartId):", message)
                    case .failure(let error):
                        print("❌ Delete Error cartId \(item.cartId):", error.localizedDescription)
                        self?.errorMessage = error.localizedDescription
                    }
                    group.leave()
                }
            }
        }

        // 2️⃣ Silme tamamlandıktan sonra, 1 artırılmış yeni kayıt ekle
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            let newAmount = totalAmount + 1
            let movieModel = movie.toMovieModel()
            self.networkManager.insertMovie(movie: movieModel, orderAmount: newAmount) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let message):
                        print("➕ Added increased movie:", message)
                        self.loadCartMovies()
                    case .failure(let error):
                        print("❌ Insert Error:", error.localizedDescription)
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

    func decreaseQuantity(for movie: CartMovieModel) {
        // 1️⃣ Önce ilgili tüm kayıtları bul
        let allMatches = cartMovies.filter { $0.name == movie.name }
        guard !allMatches.isEmpty else { return }

        // 2️⃣ Tüm mevcut adetleri topla
        let totalAmount = allMatches.reduce(0) { $0 + $1.orderAmount }

        // Eğer zaten 1 adet varsa, sadece tüm kayıtları silmek yeterli
        if totalAmount <= 1 {
            deleteAllOccurrences(of: movie)
            return
        }

        // 3️⃣ Önce tüm kayıtları sil
        let group = DispatchGroup()
        for item in allMatches {
            group.enter()
            networkManager.deleteCartMovie(cartId: item.cartId) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let message):
                        print("🗑️ Deleted cartId \(item.cartId):", message)
                    case .failure(let error):
                        print("❌ Delete Error cartId \(item.cartId):", error.localizedDescription)
                        self?.errorMessage = error.localizedDescription
                    }
                    group.leave()
                }
            }
        }

        // 4️⃣ Silme tamamlandıktan sonra, 1 azaltılmış yeni kayıt ekle
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            let newAmount = totalAmount - 1
            let movieModel = movie.toMovieModel() // CartMovieModel -> MovieModel dönüşümü
            self.networkManager.insertMovie(movie: movieModel, orderAmount: newAmount) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let message):
                        print("➖ Added reduced movie:", message)
                        self.loadCartMovies() // yenile
                    case .failure(let error):
                        print("❌ Insert Error:", error.localizedDescription)
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

    /// Tüm kopyaları sil
    func deleteAllOccurrences(of movie: CartMovieModel) {
        let allMatches = cartMovies.filter { $0.name == movie.name }
        guard !allMatches.isEmpty else { return }
        
        let group = DispatchGroup()
        for item in allMatches {
            group.enter()
            networkManager.deleteCartMovie(cartId: item.cartId) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let message):
                        print("🗑️ Deleted cartId \(item.cartId):", message)
                    case .failure(let error):
                        print("❌ Delete Error cartId \(item.cartId):", error.localizedDescription)
                        self?.errorMessage = error.localizedDescription
                    }
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.loadCartMovies()
        }
    }
    
    /// Tüm sepeti temizle
        func clearCart() {
            guard !cartMovies.isEmpty else { return }

            let group = DispatchGroup()
            for item in cartMovies {
                group.enter()
                networkManager.deleteCartMovie(cartId: item.cartId) { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let message):
                            print("🗑️ Deleted cartId \(item.cartId):", message)
                        case .failure(let error):
                            print("❌ Delete Error cartId \(item.cartId):", error.localizedDescription)
                            self?.errorMessage = error.localizedDescription
                        }
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) { [weak self] in
                self?.loadCartMovies()
            }
        }
}
