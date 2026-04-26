//
//  CustomTabBar.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 15.04.26.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selection: String
    @Binding var searchText: String
    @Binding var isSearchExpanded: Bool
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewSize: CGSize = .zero
    @FocusState private var isKeyboardActive: Bool
    var searchHint: String = "Поиск предмета"
    var onSearchActivated: (Bool) -> ()
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(HomeFilter.allCases, id: \.self) { filter in
                    FilterView(filter.rawValue)
                }
                ExpandableSearchBar()
            }
            .padding(.horizontal, 15)
            .visualEffect{ [isSearchExpanded] content, proxy in
                let rect = proxy.frame(in: .scrollView)
                let maxX = rect.maxX - viewSize.width
                
                return content
                    .offset(x: isSearchExpanded ? -maxX : 0)
            }
        }
        .frame(height: 50)
        .animation(animation, value: selection)
        .animation(animation, value: isKeyboardActive)
        .scrollDisabled(isSearchExpanded)
        .onChange(of: isKeyboardActive) { oldValue, newValue in
            onSearchActivated(newValue)
        }
        .scrollClipDisabled()
        .scrollIndicators(.hidden)
        .onGeometryChange(for: CGSize.self) {
            $0.size
        } action: { newValue in
            viewSize = newValue
        }
    }
    
    @ViewBuilder
    private func FilterView(_ item: String) -> some View {
        let isSelected = selection == item
        let backgroundColor: Color = isSelected ? Color.mainYellow.opacity(0.2) : Color.mainYellow
        let foregroundColor: Color = isSelected ? Color.mainYellow : Color.mainDarkBlue
        let isLast = HomeFilter.last.rawValue == item && isSearchExpanded
        
        ZStack {
            if isLast {
                Image(systemName: "circle.grid.2x2.fill")
                    .frame(width: 60, height: 45)
                    .foregroundStyle(foregroundColor)
                    .background(Color.mainYellow)
                    .clipShape(Capsule())
                    .onTapGesture {
                        HapticManager.impact(.light)
                        isKeyboardActive = false
                        withAnimation(animation) {
                            isSearchExpanded = false
                            selection = HomeFilter.first.rawValue
                            searchText = ""
                        }
                    }
                    .padding(.leading, 12)
                
            } else {
                Text(item)
                    .font(Font.custom("PlayfairDisplay-SemiBold", size: 18))
                    .padding(.horizontal, 15)
                    .frame(height: 45)
                    .foregroundStyle(foregroundColor)
                    .background(backgroundColor)
                    .clipShape(Capsule())
                    .onTapGesture {
                        HapticManager.impact(.light)
                        selection = item
                    }
                    .disabled(isSearchExpanded)
            }
        }
    }
    
    @ViewBuilder
    private func ExpandableSearchBar() -> some View {
        let fitSearchBarWidth: CGFloat = viewSize.width - 102
        ZStack(alignment: .trailing) {
            HStack(spacing: 0) {
                Image(systemName: "magnifyingglass")
                    .font(.title3)
                    .frame(width: 60)
                    .foregroundStyle(Color.mainDarkBlue)
                
                if isSearchExpanded {
                    TextField(searchHint, text: $searchText)
                        .font(Font.custom("PlayfairDisplay-SemiBold", size: 18))
                        .foregroundStyle(Color.mainDarkBlue)
                        .textContentType(.none)
                        .focused($isKeyboardActive)
                        .colorMultiply(.black)
                        .accessibilityIdentifier("home_search_textfield")
                }
            }
            .padding(.leading, isSearchExpanded ? 5 : 0)
            .padding(.trailing, isSearchExpanded ? 15 : 0)
            .frame(height: 45)
            .background(Color.mainYellow)
            .clipShape(Capsule())
            .gesture(
                TapGesture(count: 1).onEnded { _ in
                    withAnimation(animation) {
                        HapticManager.impact(.light)
                        isSearchExpanded = true
                        selection = HomeFilter.first.rawValue
                    }
                },
                isEnabled: !isSearchExpanded
            )
            .zIndex(1)
            .padding(.trailing, isKeyboardActive ? 57 : 0)
            
            Image(systemName: "xmark")
                .frame(width: 45, height: 45)
                .foregroundStyle(Color.mainDarkBlue)
                .background(Color.mainYellow)
                .clipShape(Capsule())
                .onTapGesture {
                    HapticManager.impact(.light)
                    isKeyboardActive = false
                }
                .opacity(isKeyboardActive ? 1 : 0)
                .offset(x: isKeyboardActive ? 0 : 70)
                .zIndex(0)
        }
        .frame(width: isSearchExpanded ? fitSearchBarWidth : nil)
    }
    
    var animation: Animation = .interpolatingSpring(duration: 0.3, bounce: 0, initialVelocity: 0)
}
