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
            // MoviesView içindeki navigationTitle kısmını şu şekilde güncelle:

            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("FrameBox")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                        .shadow(color: AppColors.accent.opacity(0.6), radius: 2, x: 0, y: 1)
                }
            }
            .background(
                // Üst kısım için hafif blur/gradient
                LinearGradient(
                    colors: [AppColors.background.opacity(0.9), AppColors.background.opacity(0.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea(edges: .top)
            )
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
                // Poster
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
                
                // Bilgi Alanı
                VStack(alignment: .leading, spacing: 6) {
                    // 1. satır → İsim
                    Text(movie.name ?? "İsimsiz")
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    // 2. satır → Kategori
                    if let category = movie.category {
                        Text(category)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // 3. satır → Yıl
                    Text("\(movie.year ?? 0)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // 4. satır → Rating + Price
                    HStack(spacing: 8) {
                        if let rating = movie.rating {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.subheadline)
                                Text(String(format: "%.1f", rating))
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                            }
                        }
                        
                        if let price = movie.price {
                            Text("$\(price)")
                                .bold()
                                .foregroundColor(AppColors.accent)
                                .font(.subheadline)
                        }
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Page View İçin Kart
struct MovieCardView: View {
    let movie: MovieModel
    let imageURL: URL?
    
    var body: some View {
        NavigationLink(destination: AddMovieToCartView(movie: movie)) {
            GeometryReader { geo in
                let cardWidth = geo.size.width * 0.70
                
                ZStack(alignment: .bottomLeading) {
                    // Poster
                    if let url = imageURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Color.gray.opacity(0.3)
                                    .frame(width: cardWidth)
                                    .aspectRatio(2/3, contentMode: .fit) // 📌 Oranı koru
                            case .success(let image):
                                image.resizable()
                                    .aspectRatio(2/3, contentMode: .fit) // 📌 Poster oranı
                                    .frame(width: cardWidth)
                                    .clipped()
                            case .failure:
                                Color.gray.opacity(0.3)
                                    .frame(width: cardWidth)
                                    .aspectRatio(2/3, contentMode: .fit)
                            @unknown default:
                                Color.gray.opacity(0.3)
                                    .frame(width: cardWidth)
                                    .aspectRatio(2/3, contentMode: .fit)
                            }
                        }
                    } else {
                        Color.gray.opacity(0.3)
                            .frame(width: cardWidth)
                            .aspectRatio(2/3, contentMode: .fit)
                    }
                    
                    // Gradient + Metinler
                    VStack(alignment: .leading, spacing: 6) {
                        // Film adı
                        Text(movie.name ?? "İsimsiz")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                            .lineLimit(2)
                        
                        // Alt bilgiler → eşit boşluk
                        HStack {
                            Text("\(movie.year ?? 0)")
                            Spacer()
                            if let category = movie.category {
                                Text(category)
                            }
                            Spacer()
                            if let price = movie.price {
                                Text("$\(price)")
                                    .bold()
                                    .foregroundColor(AppColors.accent)
                            }
                            Spacer()
                            if let rating = movie.rating {
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text(String(format: "%.1f", rating))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                    }
                    .padding()
                    .frame(width: cardWidth, alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.95),
                                Color.black.opacity(0.7),
                                Color.clear
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
                }
                .frame(width: cardWidth)
                .aspectRatio(2/3, contentMode: .fit) // 📌 Kartın tamamı poster oranında
                .cornerRadius(16)
                .shadow(color: AppColors.accent.opacity(0.6), radius: 30, x: 0, y: 0)
                .shadow(color: .black.opacity(0.8), radius: 20, x: 0, y: 10)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
        }
        .padding(.vertical, 12)
    }
}

// CornerRadius sadece alt köşeler için extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 16
    var corners: UIRectCorner = [.allCorners]
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Grid Hücresi
struct MovieGridCell: View {
    let movie: MovieModel
    let imageURL: URL?
    
    var body: some View {
        NavigationLink(destination: AddMovieToCartView(movie: movie)) {
            
            VStack(alignment: .leading, spacing: 6) {
                // Poster
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
                
                // 1. satır → Film adı
                Text(movie.name ?? "İsimsiz")
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                // 2. satır → Kategori
                if let category = movie.category {
                    Text(category)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                // 3. satır → Yıl
                Text("\(movie.year ?? 0)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // 4. satır → Rating + Price
                HStack(spacing: 8) {
                    if let rating = movie.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.subheadline)
                            Text(String(format: "%.1f", rating))
                                .foregroundColor(.white)
                                .font(.subheadline)
                        }
                    }
                    
                    if let price = movie.price {
                        Text("$\(price)")
                            .bold()
                            .foregroundColor(AppColors.accent)
                            .font(.subheadline)
                    }
                }
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    MoviesView()
}
