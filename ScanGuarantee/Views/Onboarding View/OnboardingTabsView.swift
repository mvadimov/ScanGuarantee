//
//  OnboardingTabsView.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 15.04.26.
//

import SwiftUI

struct OnboardingTabsView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var isToggle = true
    let onFinish: () -> Void
    var body: some View {
        VStack(spacing: 50){
            HStack(spacing: 20) {
                Image("logo")
                    .resizable()
                    .frame(width: 60, height: 60)
                
                Text("Scan Guarantee")
                    .font(Font.custom("PlayfairDisplay-ExtraBold", size: 27))
                    .foregroundStyle(Color.mainYellow)
            }

            Spacer()
            
            OnboardingViewItem(viewModel.currentView)
            
            Spacer()
            
            HStack{
                HStack(spacing: 10){
                    ForEach(0..<3, id: \.self) { index in
                        if index == viewModel.currentIndex {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.mainYellow)
                                .frame(width: 20, height: 8)
                                .transition(.asymmetric(insertion: .scale, removal: .scale))
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    isToggle = false
                    Task {
                        if viewModel.isLastPage {
                            _ = await NotificationService.shared.requestAuthorization()
                        }
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if viewModel.isLastPage {
                                HapticManager.notify(.success)
                                onFinish()
                            } else {
                                viewModel.nextPage()
                                HapticManager.impact(.light)
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            isToggle = true
                        }
                    }
                }) {
                    Text(viewModel.isLastPage ? "Начать" : "Дальше")
                        .frame(width: 200, height: 50)
                        .font(Font.custom("PlayfairDisplay-SemiBold", size: 20))
                        .foregroundStyle(Color.mainDarkBlue)
                        .background(Color.mainYellow)
                        .cornerRadius(25)
                }
                .disabled(!isToggle)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 30)
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentIndex)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 50)
        .background(Color.mainDarkBlue)
    }
    
    @ViewBuilder func OnboardingViewItem(_ item: OnboardingModel) -> some View {
        VStack(spacing: 30){
            Image(item.imageName)
                .resizable()
                .frame(width: 275, height: 245)
            
            VStack(alignment: .leading, spacing: 20){
                Text(item.title)
                    .font(Font.custom("PlayfairDisplay-SemiBold", size: 25))
                    .foregroundStyle(Color.mainYellow)
                
                Text(item.text)
                    .font(Font.custom("PlayfairDisplay-Medium", size: 20))
                    .foregroundStyle(Color.white)
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    OnboardingTabsView(onFinish: {})
}
