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
                    Text("Sepetiniz boş")
                        .foregroundColor(.white)
                        .font(.title2)
                } else {
                    List {
                        ForEach(viewModel.cartMovies) { movie in
                            HStack {
                                Text(movie.name)
                                    .foregroundColor(.white)
                                Spacer()
                                Button {
                                    viewModel.deleteFromCart(cartMovie: movie)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.vertical, 8)
                            .listRowBackground(AppColors.cardBackground)
                        }
                    }
                    .listStyle(.plain)
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
