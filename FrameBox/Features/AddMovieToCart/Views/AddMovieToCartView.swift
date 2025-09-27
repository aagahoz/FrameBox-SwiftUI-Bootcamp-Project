//
//  MovieDetailView.swift
//  FrameBox
//
//  Created by Agah Ozdemir on 22.09.2025.
//

import SwiftUI

// MARK: - Movie Detail
struct AddMovieToCartView: View {
    let movie: MovieModel
    
    @StateObject private var viewModel = AddMovieToCartViewModel()
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var quantity: Int = 0
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Hero Poster
                    if let imageURL = movie.image,
                       let url = URL(string: "http://kasimadalan.pe.hu/movies/images/\(imageURL)") {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                placeholderPoster
                            case .success(let image):
                                ZStack {
                                    // 🔹 Blur arka plan (yan boşluk doldurma)
                                    image.resizable()
                                        .scaledToFill()
                                        .blur(radius: 10)
                                        .opacity(0.6)
                                        .ignoresSafeArea(edges: .top)

                                    // 🔹 Asıl poster (tam görünsün)
                                    image.resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 360)
                                        .shadow(radius: 8)
                                }
                                .overlay(
                                    LinearGradient(
                                        colors: [.black.opacity(0.6), .clear],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
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
                    
                    // MARK: - Info Section
                    VStack(spacing: 16) {
                        
                        // Başlık
                        Text(movie.name ?? "İsimsiz")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        
                        // Yıl + Rating (yan yana eşit genişlikte)
                        HStack(spacing: 12) {
                            if let director = movie.director {
                                infoCard(title: "Yönetmen", value: director)
                            }
                            // Kategori (tek başına satır)
                            if let category = movie.category {
                                infoCard(title: "Kategori", value: category)
                            }
                        }

                        // Yıl + Rating (yan yana eşit genişlikte)
                        HStack(spacing: 12) {
                            infoCard(title: "Yıl", value: "\(movie.year ?? 0)")
                            if let rating = movie.rating {
                                infoCard(title: "Rating", value: "⭐️ \(String(format: "%.1f", rating))")
                            }
                        }
                        
                        

                        // Açıklama
                        if let desc = movie.description, !desc.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Açıklama")
                                    .font(.headline)
                                    .foregroundColor(AppColors.accent)
                                
                                Text(desc)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineSpacing(6)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.05))
                                    .overlay(
                                        Rectangle()
                                            .fill(AppColors.accent)
                                            .frame(width: 4)
                                            .padding(.vertical, 8)
                                        , alignment: .leading
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(Color.white.opacity(0.1))
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    Spacer(minLength: 100) // Floating alan için boşluk
                }
                .padding(.bottom, 120)
            }
            
            // MARK: - Floating Bottom Panel (Refined Apple-like)
            VStack {
                Spacer()
                
                VStack(spacing: 10) {
                    // Quantity Selector (Compact)
                    HStack(spacing: 10) {
                        Button {
                            if quantity > 0 {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    quantity -= 1
                                }
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(.red)
                        }
                        
                        Text("\(quantity)")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(minWidth: 36)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.08))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(Color.white.opacity(0.15))
                            )
                            .animation(.easeInOut, value: quantity)
                        
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                quantity += 1
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(.green)
                        }
                    }
                    
                    // Pricing Section (Refined UI)
                    if let unitPrice = movie.price {
                        let total = unitPrice * quantity
                        
                        HStack(spacing: 12) {
                            // Birim
                            Text("$\(unitPrice) / adet")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.75))
                            
                            Spacer()
                            
                            // Çarpı Adet
                            Text("×\(quantity)")
                                .font(.subheadline.bold())
                                .foregroundColor(AppColors.accent)
                            
                            // Toplam
                            Text("$\(total)")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 4)
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: quantity)
                    }
                    
                    // Add to Cart Button
                    Button(action: {
                        viewModel.addToCart(movie: movie, amount: quantity)
                    }) {
                        HStack {
                            if viewModel.isAdding {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "cart.fill.badge.plus")
                                Text("Sepete Ekle")
                                    .font(.headline)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppColors.accent.opacity((viewModel.isAdding || quantity == 0) ? 0.5 : 1.0)) // Opaklık değişimi
                        )
                        .shadow(color: AppColors.accent.opacity(0.4), radius: 10, y: 4)
                    }
                    .disabled(viewModel.isAdding || quantity == 0) // quantity 0 ise disable
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 22)
                .background(.ultraThinMaterial)
                .cornerRadius(24)
                .shadow(color: .black.opacity(0.2), radius: 15, y: -3)
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .onReceive(viewModel.$successMessage.compactMap { $0 }) { message in
            alertMessage = message; showAlert = true
        }
        .onReceive(viewModel.$errorMessage.compactMap { $0 }) { message in
            alertMessage = message; showAlert = true
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Bilgi"), message: Text(alertMessage), dismissButton: .default(Text("Tamam")))
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        
    }
}

// MARK: - Helpers
private extension AddMovieToCartView {
    var placeholderPoster: some View {
        Color.gray.opacity(0.3)
            .frame(height: 360)
    }
    
    func infoCard(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.white)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .center) // Satırın tamamı
        .background(AppColors.cardBackground.opacity(0.8))
        .cornerRadius(12)
    }
}
