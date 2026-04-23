//
//  AddCertificateView.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 16.04.26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddCertificateView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isKeyboardActive: Bool
    
    @StateObject private var viewModel: AddCertificateViewModel
    @State private var isDatePickerVisible: Bool = true
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    init(
        productName: String = "",
        validTo: Date = Date(),
        selectedImageData: Data? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: AddCertificateViewModel(
                productName: productName,
                validTo: validTo,
                selectedImageData: selectedImageData
            )
        )
    }
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Добавить новую гарантию")
                .font(Font.custom("PlayfairDisplay-ExtraBold", size: 23))
                .foregroundStyle(Color.mainYellow)
                .padding(.bottom, 20)
            
            HStack {
                Image(systemName: "pencil")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(viewModel.isValidColorOfName)
                
                TextField("Название товара", text: $viewModel.productName)
                    .font(Font.custom("PlayfairDisplay-SemiBold", size: 20))
                    .foregroundStyle(Color.mainYellow)
                    .textContentType(.none)
                    .focused($isKeyboardActive)
                    .onChange(of: viewModel.productName) { _, _ in
                        viewModel.resetValidationColorIfNeeded()
                    }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "calendar")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color.mainYellow)
                    
                    Text("Гарантия до:")
                        .font(Font.custom("PlayfairDisplay-Bold", size: 20))
                        .foregroundStyle(Color.mainYellow)
                }
                
                VStack {
                    if isDatePickerVisible {
                        DatePicker("", selection: $viewModel.validTo, displayedComponents: .date)
                            .datePickerStyle(.wheel)
                            .preferredColorScheme(.dark)
                            .colorMultiply(.mainYellow)
                    } else {
                        Button {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                HapticManager.impact(.light)
                                isDatePickerVisible = true
                            }
                        } label: {
                            HStack(alignment: .center, spacing: 15) {
                                Text(viewModel.validTo.ruDate())
                                    .font(Font.custom("PlayfairDisplay-Medium", size: 18))
                                    .foregroundColor(.mainYellow)
                                
                                Image(systemName: "chevron.down")
                                    .resizable()
                                    .frame(width: 15, height: 10)
                                    .foregroundStyle(Color.mainYellow)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.mainYellow, lineWidth: 1)
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 10)
            
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    Image(systemName: "photo")
                        .resizable()
                        .frame(width: 20, height: 18)
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color.mainYellow)
                    
                    Text("Фото талона:")
                        .font(Font.custom("PlayfairDisplay-Bold", size: 20))
                        .foregroundStyle(Color.mainYellow)
                }
                
                if let selectedImageData = viewModel.selectedImageData,
                   let uiImage = UIImage(data: selectedImageData) {
                    if !isDatePickerVisible {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: 220)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                            
                            Button {
                                HapticManager.impact(.light)
                                viewModel.removeSelectedImage()
                                selectedPhotoItem = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .resizable()
                                    .frame(width: 28, height: 28)
                                    .foregroundStyle(.white, .red)
                                    .padding(8)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: 220)
                    } else {
                        Button {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                HapticManager.impact(.light)
                                isDatePickerVisible = false
                                isKeyboardActive = false
                            }
                        } label: {
                            HStack(alignment: .center, spacing: 15) {
                                Text("Выбранное фото")
                                    .font(Font.custom("PlayfairDisplay-Medium", size: 18))
                                    .foregroundColor(.mainYellow)
                                
                                Image(systemName: "chevron.down")
                                    .resizable()
                                    .frame(width: 15, height: 10)
                                    .foregroundStyle(Color.mainYellow)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.mainYellow, lineWidth: 1)
                            )
                        }
                    }
                }
                
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.mainDarkBlue)
                        
                        Text(viewModel.selectedImageData == nil ? "Выбрать фото" : "Заменить фото")
                            .font(Font.custom("PlayfairDisplay-SemiBold", size: 18))
                            .foregroundStyle(.mainDarkBlue)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.mainYellow)
                    .clipShape(Capsule())
                }
                .onTapGesture {
                    HapticManager.impact(.light)
                    isDatePickerVisible = false
                }
            }
            .padding(.bottom, 20)
            
            HStack(spacing: 50) {
                Button {
                    HapticManager.impact(.light)
                    dismiss()
                } label: {
                    Text("Отмена")
                        .font(Font.custom("PlayfairDisplay-SemiBold", size: 18))
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.mainDarkBlue)
                        .background(.mainYellow)
                        .clipShape(Capsule())
                }
                
                Button {
                    handleSaveTap()
                } label: {
                    Text("Добавить")
                        .font(Font.custom("PlayfairDisplay-SemiBold", size: 18))
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.mainDarkBlue)
                        .background(.mainYellow)
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .padding([.top, .horizontal], 20)
        .background(Color.mainDarkBlue.ignoresSafeArea())
        .onAppear {
            isKeyboardActive = true
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                await viewModel.handleSelectedPhotoItem(newItem)
                selectedPhotoItem = nil
            }
        }
        .alert("Уведомления выключены", isPresented: $viewModel.showNotificationAlert) {
            Button("Открыть настройки") {
                openSettings()
            }
            
            Button("Позже", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Включите уведомления, чтобы получать напоминания о гарантии.")
        }
    }
    
    private func handleSaveTap() {
        if !viewModel.isFormValid {
            HapticManager.notify(.error)
            viewModel.markInvalidName()
        } else {
            HapticManager.impact(.light)
            Task {
                let shouldDismiss = await viewModel.save(context: context)
                if shouldDismiss {
                    dismiss()
                }
            }
        }
    }
    
    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CertificateModel.self, configurations: config)
    
    let context = container.mainContext
    
    context.insert(
        CertificateModel(
            productName: "iPhone 15",
            validTo: Calendar.current.date(byAdding: .month, value: 12, to: .now)!
        )
    )
    
    context.insert(
        CertificateModel(
            productName: "MacBook Air",
            validTo: Calendar.current.date(byAdding: .day, value: 3, to: .now)!
        )
    )
    
    context.insert(
        CertificateModel(
            productName: "AirPods Pro",
            validTo: Calendar.current.date(byAdding: .day, value: -5, to: .now)!
        )
    )
    
    return HomeView()
        .modelContainer(container)
}
