//
//  TabBarRootView.swift
//  FrameBox
//
//  Created by Agah Ozdemir on 22.09.2025.
//

import SwiftUI

struct TabBarRootView: View {
    var body: some View {
        TabView {
            NavigationStack {
                MoviesView()
            }
            .tabItem {
                Label("Filmler", systemImage: "film")
            }

            NavigationStack {
                GetMoviesAtCartView()
            }
            .tabItem {
                Label("Sepet", systemImage: "cart")
            }
        }
        .accentColor(AppColors.accent) // seçili tab rengi
        .background(AppColors.background.ignoresSafeArea())
    }
}
