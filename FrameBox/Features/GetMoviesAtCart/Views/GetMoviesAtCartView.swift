//
//  CartView.swift
//  FrameBox
//
//  Created by Agah Ozdemir on 22.09.2025.
//

import SwiftUI

struct GetMoviesAtCartView: View {
    @StateObject private var viewModel = GetMoviesAtCartViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                if viewModel.cartMovies.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "cart")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                        Text("Sepetiniz boş")
                            .foregroundColor(.white)
                            .font(.title2)
                            .bold()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.groupedCartMovies) { movie in
                                CartMovieRow(movie: movie, viewModel: viewModel)
                            }
                            Spacer(minLength: 100)
                        }
                        .padding(.vertical, 16)
                    }
                }
                
                // Floating Total Panel
                if !viewModel.cartMovies.isEmpty {
                    VStack {
                        Spacer()
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Toplam")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("$\(viewModel.totalAmount(), specifier: "%.2f")")
                                    .bold()
                                    .foregroundColor(AppColors.accent)
                            }
                            .padding(.horizontal)
                            
                            HStack(spacing: 12) {
                                // Sepeti Temizle
                                Button(action: {
                                    viewModel.clearCart()
                                }) {
                                    Text("Sepeti Temizle")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.red.opacity(0.9))
                                        )
                                }

                                // Eğer istersen checkout butonu da ekleyebilirsin
                                Button(action: {
                                    print("Checkout tapped")
                                }) {
                                    Text("Satın Al")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(AppColors.accent)
                                        )
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [AppColors.cardBackground.opacity(0.95), AppColors.cardBackground.opacity(0.85)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.6), radius: 10, x: 0, y: 4)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    }
                }
            }
            .navigationTitle("Sepet")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadCartMovies()
            }
        }
    }
}

struct CartMovieRow: View {
    let movie: CartMovieModel
    @ObservedObject var viewModel: GetMoviesAtCartViewModel
    
    var body: some View {
        NavigationLink(destination: AddMovieToCartView(movie: movie.toMovieModel())) {
            HStack(spacing: 12) {
                // Poster
                AsyncImage(url: MoviesNetworkManager.shared.imageURL(fileName: (movie.image))) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.3)
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        Color.gray.opacity(0.3)
                    @unknown default:
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(width: 70, height: 100)
                .cornerRadius(8)
                .clipped()
                
                // Film bilgileri
                VStack(alignment: .leading, spacing: 6) {
                    Text(movie.name)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    HStack(spacing: 6) {
                        Text("\(movie.year)")
                        Text("•")
                        Text(movie.category)
                        Text("•")
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption2)
                            Text(String(format: "%.1f", movie.rating))
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    
                    // Adet ve toplam fiyat
                    HStack(spacing: 12) {
                        // ⬇ Eksi: 1 azalt
                        Button {
                            viewModel.decreaseQuantity(for: movie)
                        } label: {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.red)
                                .font(.title3)
                        }
                        
                        Text("\(movie.orderAmount)")
                            .foregroundColor(.white)
                            .frame(width: 30)
                        
                        // ⬆ Artı: 1 artır
                        Button {
                            viewModel.increaseQuantity(for: movie)
                        } label: {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.green)
                                .font(.title3)
                        }
                        
                        Spacer()
                        
                        Text("$\(movie.price * movie.orderAmount)")
                            .bold()
                            .foregroundColor(AppColors.accent)
                    }
                }
                
                // Silme butonu
                Button {
                    viewModel.deleteAllOccurrences(of: movie)
                } label: {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                }
            }
            .padding()
            .background(AppColors.cardBackground.opacity(0.9))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.6), radius: 6, x: 0, y: 4)
            .padding(.horizontal, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
