//
//  MoviesView.swift
//  FrameBox
//
//  Created by Agah Ozdemir on 21.09.2025.
//

import SwiftUI

struct AppColors {
    static let background = Color(red: 18/255, green: 18/255, blue: 18/255) // koyu arka plan (nötr siyah)
    static let cardBackground = Color(red: 28/255, green: 28/255, blue: 28/255) // kartlar için biraz daha açık gri
    static let accent = Color(red: 0.0, green: 200/255, blue: 120/255) // canlı yeşil accent
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 160/255, green: 160/255, blue: 160/255) // daha soft gri
    static let searchBarBackground = Color(red: 35/255, green: 45/255, blue: 40/255) // yeşilimsi koyu ton
}

// MARK: - Görünüm Modları
enum ViewMode: String, CaseIterable, Identifiable {
    case page = "Page"
    case list = "Liste"
    case grid = "Grid"
    
    var id: String { rawValue }
}

// MARK: - MoviesView
struct MoviesView: View {
    @StateObject private var viewModel = MoviesViewModel()
    @State private var viewMode: ViewMode = .page
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 16) { // VStack içi ana spacing
                    // MARK: - Picker (Görünüm Modu)
                    Picker("Görünüm", selection: $viewMode) {
                        ForEach(ViewMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    // MARK: - Arama Alanı
                    TextField(
                        "",
                        text: $viewModel.searchText,
                        prompt: Text("Film ara...")
                            .foregroundColor(AppColors.textSecondary)
                    )
                    .padding(12)
                    .background(AppColors.searchBarBackground)
                    .cornerRadius(10)
                    .foregroundColor(AppColors.textPrimary)
                    .tint(AppColors.accent)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(AppColors.accent.opacity(0.4), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    
                    // MARK: - İçerik
                    contentView
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("FrameBox")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
// MARK: - İçerik Görünümleri
extension MoviesView {
    @ViewBuilder
    private var contentView: some View {
        if viewModel.movies.isEmpty {
            ProgressView("Filmler Yükleniyor...")
                .onAppear { viewModel.loadMovies() }
        } else {
            if viewModel.searchText.isEmpty {
                switch viewMode {
                case .page:
                    TabView {
                        ForEach(viewModel.filteredMovies) { movie in
                            MovieCardView(
                                movie: movie,
                                imageURL: viewModel.imageURL(for: movie.image ?? "")
                            )
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                    .ignoresSafeArea(edges: .top)
                    
                case .list:
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredMovies) { movie in
                                SearchResultRow(
                                    movie: movie,
                                    imageURL: viewModel.imageURL(for: movie.image ?? "")
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    
                case .grid:
                    ScrollView {
                        let columns = [GridItem(.flexible()), GridItem(.flexible())]
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.filteredMovies) { movie in
                                MovieGridCell(
                                    movie: movie,
                                    imageURL: viewModel.imageURL(for: movie.image ?? "")
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    }
                }
            } else {
                // Arama modunda → liste
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredMovies) { movie in
                            SearchResultRow(
                                movie: movie,
                                imageURL: viewModel.imageURL(for: movie.image ?? "")
                            )
                            .padding(.horizontal, 16)
                        }
                    }
                }
            }
        }
    }
}


// MARK: - Liste Satırı (Search / List görünümü için)
struct SearchResultRow: View {
    let movie: MovieModel
    let imageURL: URL?
    
    var body: some View {
        NavigationLink(destination: AddMovieToCartView(movie: movie)) {
            HStack(spacing: 12) {
                if let url = imageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Color.gray.opacity(0.3)
                                .frame(width: 80, height: 120)
                                .cornerRadius(8)
                        case .success(let image):
                            image.resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 120)
                                .clipped()
                                .cornerRadius(8)
                        case .failure:
                            Color.gray.opacity(0.3)
                                .frame(width: 80, height: 120)
                                .cornerRadius(8)
                        @unknown default:
                            Color.gray.opacity(0.3)
                                .frame(width: 80, height: 120)
                                .cornerRadius(8)
                        }
                    }
                } else {
                    Color.gray.opacity(0.3)
                        .frame(width: 80, height: 120)
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(movie.name ?? "İsimsiz")
                        .font(.headline)
                    Text("\(movie.year ?? 0)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle()) // default link stilini kaldırır
    }
}
// MARK: - Page View İçin Kart
struct MovieCardView: View {
    let movie: MovieModel
    let imageURL: URL?
    
    var body: some View {
        
        NavigationLink(destination: AddMovieToCartView(movie: movie)) {
            
            GeometryReader { geo in
                let cardWidth = geo.size.width * 0.85
                let cardHeight = geo.size.height * 0.75
                
                ZStack(alignment: .bottomLeading) {
                    if let url = imageURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Color.gray.opacity(0.3)
                            case .success(let image):
                                image.resizable()
                                    .scaledToFill()
                                    .frame(width: cardWidth, height: cardHeight)
                                    .clipped()
                            case .failure:
                                Color.gray.opacity(0.3)
                                    .frame(width: cardWidth, height: cardHeight)
                            @unknown default:
                                Color.gray.opacity(0.3)
                                    .frame(width: cardWidth, height: cardHeight)
                            }
                        }
                    } else {
                        Color.gray.opacity(0.3)
                            .frame(width: cardWidth, height: cardHeight)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(movie.name ?? "İsimsiz")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        
                        Text("\(movie.year ?? 0)")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .frame(width: cardWidth)
                    .background(
                        LinearGradient(
                            colors: [.black.opacity(0.7), .clear],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                }
                .frame(width: cardWidth, height: cardHeight)
                .cornerRadius(16)
                .shadow(color: AppColors.accent.opacity(0.6), radius: 30, x: 0, y: 0) // dışarıya yayılma
                .shadow(color: .black.opacity(0.8), radius: 20, x: 0, y: 10) // sinematik derinlik
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Grid Hücresi
struct MovieGridCell: View {
    let movie: MovieModel
    let imageURL: URL?
    
    var body: some View {
        NavigationLink(destination: AddMovieToCartView(movie: movie)) {
            
            VStack(alignment: .leading, spacing: 8) {
                if let url = imageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Color.gray.opacity(0.3)
                                .frame(height: 180)
                                .cornerRadius(8)
                        case .success(let image):
                            image.resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .clipped()
                                .cornerRadius(8)
                        case .failure:
                            Color.gray.opacity(0.3)
                                .frame(height: 180)
                                .cornerRadius(8)
                        @unknown default:
                            Color.gray.opacity(0.3)
                                .frame(height: 180)
                                .cornerRadius(8)
                        }
                    }
                } else {
                    Color.gray.opacity(0.3)
                        .frame(height: 180)
                        .cornerRadius(8)
                }
                
                Text(movie.name ?? "İsimsiz")
                    .font(.headline)
                    .lineLimit(1)
                
                Text("\(movie.year ?? 0)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    MoviesView()
}
