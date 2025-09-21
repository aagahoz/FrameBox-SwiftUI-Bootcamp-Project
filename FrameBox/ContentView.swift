//
//  ContentView.swift
//  FrameBox
//
//  Created by Agah Ozdemir on 19.09.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MoviesViewModel()
    
    var body: some View {
        TabView {
            
            // MARK: - Filmler Sekmesi
            VStack {
                Button("Filmleri Getir") {
                    viewModel.loadMovies()
                }
                .padding()
                
                List(viewModel.movies) { movie in
                    HStack(spacing: 12) {
                        // Film posteri
                        if let imageName = movie.image,
                           let url = viewModel.imageURL(for: imageName) {
                            
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 60, height: 90)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 90)
                                        .clipped()
                                        .cornerRadius(8)
                                case .failure:
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 90)
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                        
                        // Film bilgileri + Sepete ekle butonu
                        VStack(alignment: .leading, spacing: 6) {
                            Text(movie.name ?? "İsimsiz")
                                .font(.headline)
                            Text("\(movie.year ?? 0)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button {
                                viewModel.addToCart(movie: movie)
                            } label: {
                                Label("Sepete Ekle", systemImage: "cart.badge.plus")
                                    .font(.subheadline)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                            .padding(.top, 4)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .tabItem {
                Label("Filmler", systemImage: "film")
            }
            
            // MARK: - Sepet Sekmesi
            VStack {
                Button("Sepeti Getir") {
                    viewModel.loadCartMovies()
                }
                .padding()
                
                List(viewModel.cartMovies) { cartMovie in
                    HStack(spacing: 12) {
                        if let url = viewModel.imageURL(for: cartMovie.image) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 50, height: 75)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 75)
                                        .clipped()
                                        .cornerRadius(6)
                                case .failure:
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 75)
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(cartMovie.name)
                                .font(.headline)
                            Text("Adet: \(cartMovie.orderAmount)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("\(cartMovie.price) ₺")
                            .font(.headline)
                            .foregroundColor(.green)
                        
                        // MARK: - Sil Butonu
                        Button {
                            viewModel.deleteFromCart(cartMovie: cartMovie)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.borderless) // Liste içinde butonun düzgün çalışması için
                    }
                    .padding(.vertical, 4)
                }
            }
            .tabItem {
                Label("Sepet", systemImage: "cart")
            }
        }
    }
}

#Preview {
    ContentView()
}
