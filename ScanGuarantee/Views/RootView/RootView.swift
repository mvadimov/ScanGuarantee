//
//  RootView.swift
//  ScanGarant
//
//  Created by Mark Vadimov on 14.04.26.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @StateObject private var viewModel = RootViewModel()
    var body: some View {
        if viewModel.hasSeenOnboarding {
            EmptyView()
        } else {
            OnboardingTabsView(onFinish: {
                viewModel.completeOnboarding()
            })
        }
    }
}

#Preview {
    RootView()
}
