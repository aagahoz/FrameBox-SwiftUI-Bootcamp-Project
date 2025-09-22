//
//  MovieDetailView.swift
//  FrameBox
//
//  Created by Agah Ozdemir on 22.09.2025.
//

import SwiftUI

struct AddMovieToCartView: View {
    let movie: MovieModel
    
    @StateObject private var viewModel = AddMovieToCartViewModel()
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var quantity: Int = 1
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // MARK: - Poster with shadow & overlay
                if let imageURL = movie.image,
                   let url = URL(string: "http://kasimadalan.pe.hu/movies/images/\(imageURL)") {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            placeholderPoster
                        case .success(let image):
                            image.resizable()
                                .scaledToFill()
                                .frame(height: 320)
                                .clipped()
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
                                .overlay(
                                    LinearGradient(
                                        colors: [.black.opacity(0.6), .clear],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                    .cornerRadius(16)
                                )
                        case .failure:
                            placeholderPoster
                        @unknown default:
                            placeholderPoster
                        }
                    }
                } else {
                    placeholderPoster
                }
                
                // MARK: - Movie Info
                VStack(alignment: .leading, spacing: 12) {
                    Text(movie.name ?? "İsimsiz")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        infoBadge(text: "Yıl: \(movie.year ?? 0)")
                        infoBadge(text: "Kategori: \(movie.category ?? "-")")
                        infoBadge(text: "Fiyat: $\(movie.price ?? 0)")
                        if let rating = movie.rating {
                            infoBadge(text: "⭐️ \(String(format: "%.1f", rating))")
                        }
                    }
                    
                    if let desc = movie.description, !desc.isEmpty {
                        Text(desc)
                            .foregroundColor(.white.opacity(0.8))
                            .lineSpacing(5)
                    }
                }
                .padding(.horizontal, 16)
                
                // MARK: - Quantity Selector
                HStack(spacing: 24) {
                    Button {
                        if quantity > 1 { quantity -= 1 }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(AppColors.accent)
                    }
                    
                    Text("\(quantity)")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 50)
                    
                    Button {
                        quantity += 1
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(AppColors.accent)
                    }
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(16)
                .shadow(radius: 10)
                .padding(.horizontal, 16)
                
                // MARK: - Sepete Ekle Butonu
                Button(action: {
                    viewModel.addToCart(movie: movie, amount: quantity)
                }) {
                    HStack {
                        if viewModel.isAdding {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "cart.fill.badge.plus")
                                .font(.title2)
                            Text("Sepete Ekle")
                                .font(.headline)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isAdding ? AppColors.accent.opacity(0.7) : AppColors.accent)
                    .cornerRadius(16)
                    .shadow(radius: 5)
                }
                .padding(.horizontal, 16)
                .disabled(viewModel.isAdding)
                
                Spacer()
            }
            .padding(.vertical)
        }
        .background(AppColors.background.ignoresSafeArea())
        // MARK: - Alert
        .onReceive(viewModel.$successMessage.compactMap { $0 }) { message in
            alertMessage = message
            showAlert = true
        }
        .onReceive(viewModel.$errorMessage.compactMap { $0 }) { message in
            alertMessage = message
            showAlert = true
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Bilgi"), message: Text(alertMessage), dismissButton: .default(Text("Tamam")))
        }
        .navigationTitle("Film Detayı")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Helpers

private extension AddMovieToCartView {
    var placeholderPoster: some View {
        Color.gray.opacity(0.3)
            .frame(height: 320)
            .cornerRadius(16)
    }
    
    func infoBadge(text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppColors.cardBackground.opacity(0.8))
            .cornerRadius(12)
    }
}
