//
//  EditCertificateView.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 16.04.26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct EditCertificateView: View {
    @Bindable var item: CertificateModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showNotificationAlert = false
    
    private var isFormValid: Bool {
        !item.productName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mainDarkBlue
                    .ignoresSafeArea()
                
                Form {
                    Section {
                        TextField("Название товара", text: $item.productName)
                            .font(Font.custom("PlayfairDisplay-ExtraBold", size: 17))
                            .foregroundStyle(.mainYellow)
                            .tint(.mainYellow)
                        
                        TextField("Серийный номер", text: Binding(
                            get: { item.serialNumber ?? "" },
                            set: { item.serialNumber = $0.isEmpty ? nil : $0 }
                        ))
                        .font(Font.custom("PlayfairDisplay-ExtraBold", size: 17))
                        .foregroundStyle(.mainYellow)
                        .tint(.mainYellow)
                        
                        DatePicker(
                            "Действителеный до",
                            selection: $item.validTo,
                            displayedComponents: .date
                        )
                        .foregroundStyle(.mainYellow)
                        .tint(.mainYellow)
                        .colorMultiply(.mainYellow)
                                                
                        TextField("Продавец (имя/компания)", text: Binding(
                            get: { item.sellerName ?? "" },
                            set: { item.sellerName = $0.isEmpty ? nil : $0 }
                        ))
                        .font(Font.custom("PlayfairDisplay-ExtraBold", size: 17))
                        .foregroundStyle(.mainYellow)
                        .tint(.mainYellow)
                        
                        TextField("Email", text: Binding(
                            get: { item.sellerEmail ?? "" },
                            set: { item.sellerEmail = $0.isEmpty ? nil : $0 }
                        ))
                        .font(Font.custom("PlayfairDisplay-ExtraBold", size: 17))
                        .foregroundStyle(.mainYellow)
                        .tint(.mainYellow)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        
                        TextField("Телефон", text: Binding(
                            get: { item.sellerPhone ?? "" },
                            set: { item.sellerPhone = $0.isEmpty ? nil : $0 }
                        ))
                        .font(Font.custom("PlayfairDisplay-ExtraBold", size: 17))
                        .foregroundStyle(.mainYellow)
                        .tint(.mainYellow)
                        .keyboardType(.phonePad)
                    }
                    .listRowBackground(Color.mainYellow.opacity(0.08))
                    
                    Section {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Фото сертификата")
                                .font(Font.custom("PlayfairDisplay-ExtraBold", size: 17))
                                .foregroundStyle(.mainYellow)
                            
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                HStack {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .foregroundStyle(.mainDarkBlue)
                                    
                                    Text(item.imageData == nil ? "Choose photo" : "Заменить фото")
                                        .font(Font.custom("PlayfairDisplay-SemiBold", size: 17))
                                        .foregroundStyle(.mainDarkBlue)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(.mainYellow)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            
                            if let imageData = item.imageData,
                               let uiImage = UIImage(data: imageData) {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 220)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    
                                    Button {
                                        item.imageData = nil
                                        selectedPhotoItem = nil
                                        selectedImageData = nil
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .resizable()
                                            .frame(width: 28, height: 28)
                                            .foregroundStyle(.white, .red)
                                            .padding(8)
                                    }
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.mainYellow.opacity(0.08))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Изменить")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Отменить") {
                        dismiss()
                    }
                    .font(Font.custom("PlayfairDisplay-ExtraBold", size: 17))
                    .foregroundStyle(.mainYellow)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Подтвердить") {
                        handleDoneTap()
                    }
                    .font(Font.custom("PlayfairDisplay-ExtraBold", size: 17))
                    .foregroundStyle(.mainYellow)
                    .disabled(!isFormValid)
                }
            }
            .toolbarBackground(Color.mainDarkBlue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }
                
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            if let uiImage = UIImage(data: data),
                               let compressedData = uiImage.jpegData(compressionQuality: 0.75) {
                                selectedImageData = compressedData
                                item.imageData = compressedData
                            } else {
                                selectedImageData = data
                                item.imageData = data
                            }
                        }
                    }
                }
            }
            .alert("Уведомления выключены", isPresented: $showNotificationAlert) {
                Button("Открыть настройки") {
                    openSettings()
                }
                
                Button("Позже", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Включите уведомления в настройках, чтобы получать напоминания о гарантийном ремонте.")
            }
        }
    }
    
    private func handleDoneTap() {
        item.productName = item.productName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !item.productName.isEmpty else { return }
        
        item.updatedAt = Date()
        
        Task {
            let isAuthorized = await NotificationService.shared.isAuthorized()
            
            if isAuthorized {
                await NotificationService.shared.rescheduleNotification(for: item)
                await MainActor.run {
                    dismiss()
                }
            } else {
                await MainActor.run {
                    item.notifyEnabled = false
                    showNotificationAlert = true
                }
            }
        }
    }
    
    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
