//
//  OnboardingViewModel.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 15.04.26.
//

import Foundation
import Combine

final class OnboardingViewModel: ObservableObject {
    @Published var currentIndex = 0
    
    var views: [OnboardingModel] = [
        OnboardingModel(image: "SnapSave",title: "Snap and Save", text: "One shot and the warranty is saved. The camera automatically captures the purchase date and expiry!"),
        OnboardingModel(image: "SmartRacks", title: "Smart Racks", text: "All warranty cards are sorted by category and expiry date. Nothing gets lost or mixed up!"),
        OnboardingModel(image: "CareReminder", title: "Care Reminder", text: "You’ll get a notification one day before the warranty ends — just in time to contact support!")
    ]
    
    var currentView: OnboardingModel {
        views[currentIndex]
    }
    
    var isLastPage: Bool {
        currentIndex == views.count - 1
    }
    
    func nextPage() {
        if currentIndex < views.count - 1 {
            currentIndex += 1
        }
    }
    
    func reset() {
        currentIndex = 0
    }
}
