//
//  RootViewModel.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 15.04.26.
//

import Foundation
import Combine

final class RootViewModel: ObservableObject {
    @Published var hasSeenOnboarding: Bool = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    
    func completeOnboarding() {
        hasSeenOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
    }
}
