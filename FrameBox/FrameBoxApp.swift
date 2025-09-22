//
//  FrameBoxApp.swift
//  FrameBox
//
//  Created by Agah Ozdemir on 19.09.2025.
//

import SwiftUI

@main
struct FrameBoxApp: App {
    
    init() {
        let appearance = UISegmentedControl.appearance()
        appearance.selectedSegmentTintColor = UIColor(AppColors.accent)
        appearance.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        appearance.setTitleTextAttributes([.foregroundColor: UIColor.lightGray], for: .normal)
    }
    
    var body: some Scene {
        WindowGroup {
            TabBarRootView()
        }
    }
}
