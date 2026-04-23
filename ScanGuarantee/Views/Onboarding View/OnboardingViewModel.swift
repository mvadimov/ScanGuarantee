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
    
    private var views: [OnboardingModel] = [
        OnboardingModel(imageName: "SnapSave",title: "Щёлк - и сохранено", text: "Один кадр - и гарантия под защитой. Камера сама распознаёт дату покупки и окончания срока!"),
        OnboardingModel(imageName: "SmartRacks", title: "Умные полки", text: "Все гарантийные талоны рассортированы по категориям и датам. Ничего не теряется и не путается!"),
        OnboardingModel(imageName: "CareReminder", title: "Заботливое напоминание", text: "Уведомление придёт за неделю до окончания гарантии — самое время обратиться в поддержку!")
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
