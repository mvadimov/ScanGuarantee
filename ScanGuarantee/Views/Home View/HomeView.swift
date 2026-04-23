//
//  HomeView.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 15.04.26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Query private var items: [CertificateModel]
    @Environment(\.modelContext) private var context

    @State private var isSearchExpanded: Bool = false
    @State private var isSearchActivated: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    
    @State private var showCameraPicker: Bool = false
    @State private var cameraImage: UIImage?
    @State private var showCameraUnavailableAlert: Bool = false

    @State private var showAddOptions: Bool = false
    @State private var showPhotoPicker: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            if !isSearchActivated {
                HStack(spacing: 20) {
                    Image("logo")
                        .resizable()
                        .frame(width: 45, height: 45)

                    Text("Scan Guarantee")
                        .font(Font.custom("PlayfairDisplay-ExtraBold", size: 23))
                        .foregroundStyle(Color.mainYellow)

                    Spacer()

                    Button {
                        HapticManager.impact(.light)
                        showAddOptions = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 45, height: 45)
                            .fontWeight(.light)
                            .foregroundStyle(Color.mainYellow)
                    }
                    .confirmationDialog("", isPresented: $showAddOptions, titleVisibility: .visible) {
                        Button("Сфотографировать") {
                            HapticManager.impact(.light)

                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                showCameraPicker = true
                            } else {
                                showCameraUnavailableAlert = true
                            }
                        }

                        Button("Выбрать из галереи") {
                            HapticManager.impact(.light)
                            showPhotoPicker = true
                        }

                        Button("Добавить вручную") {
                            HapticManager.impact(.light)
                            viewModel.openManualAdd()
                        }

                        Button("Отмена", role: .cancel) { }
                    }
                }
                .padding(.horizontal, 15)
            }

            VStack {
                CustomTabBar(
                    selection: $viewModel.selectedFilterRaw,
                    searchText: $viewModel.searchText,
                    isSearchExpanded: $isSearchExpanded
                ) { isKeyboardActive in
                    withAnimation(.snappy) {
                        isSearchActivated = isKeyboardActive
                    }
                }
            }

            ScrollView(.vertical) {
                VStack(spacing: 15) {
                    ForEach(viewModel.filteredItems(items)) { item in
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.openCertificate(item)
                            }
                        } label: {
                            ItemView(item)
                                .contextMenu {
                                    Button {
                                        HapticManager.impact(.light)
                                        viewModel.openCertificate(item)
                                    } label: {
                                        Label("Открыть", systemImage: "eye")
                                    }

                                    Button(role: .destructive) {
                                        delete(item)
                                    } label: {
                                        Label("Удалить", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 15)
            }
            .scrollDisabled(viewModel.filteredItems(items).count < 7)
            .scrollClipDisabled()
            .scrollIndicators(.hidden)
        }
        .background(Color.mainDarkBlue)
        .overlay {
            if let selectedCertificate = viewModel.selectedCertificate {
                DetailView(
                    item: selectedCertificate,
                    onClose: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.closeCertificate()
                        }
                    }
                )
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }
        }
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedPhotoItem,
            matching: .images
        )
        .sheet(isPresented: $showCameraPicker) {
            CameraPicker(image: $cameraImage)
                .ignoresSafeArea()
        }
        .sheet(item: $viewModel.addRoute) { route in
            switch route {
            case .manual:
                AddCertificateView()
                    .presentationDetents([.large])

            case .ocr(let productName, let validTo, let imageData):
                AddCertificateView(
                    productName: productName,
                    validTo: validTo,
                    selectedImageData: imageData
                )
                .presentationDetents([.large])
            }
        }
        .onChange(of: cameraImage) { _, newImage in
            Task {
                await viewModel.handleCameraImage(newImage)
                cameraImage = nil
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                await viewModel.handlePhotoPickerItem(newItem)
                selectedPhotoItem = nil
            }
        }
        .alert("Камера недоступна", isPresented: $showCameraUnavailableAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("На этом устройстве камера недоступна.")
        }
        .alert("Ошибка распознавания", isPresented: $viewModel.showOCRError) {
            Button("Попробовать снова") {
                showPhotoPicker = true
                viewModel.dismissAlert()
            }

            Button("Добавить вручную") {
                viewModel.openManualAdd()
                viewModel.dismissAlert()
            }

            Button("Отмена", role: .cancel) {
                viewModel.dismissAlert()
            }
        } message: {
            Text(viewModel.ocrErrorText)
        }
    }

    @ViewBuilder
    private func ItemView(_ item: CertificateModel) -> some View {
        HStack {
            Image(systemName: imageForData(item.validTo))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundStyle(colorForDate(item.validTo))
                .padding(10)
                .padding(.leading, 15)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.productName)
                    .font(Font.custom("PlayfairDisplay-Bold", size: 21))
                    .foregroundStyle(Color.mainYellow)

                Text("До: \(item.validTo.ruDate())")
                    .font(Font.custom("PlayfairDisplay-SemiBold", size: 17))
                    .foregroundStyle(colorForDate(item.validTo))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .frame(width: 40, height: 40)
                .foregroundStyle(Color.mainYellow)
        }
        .frame(height: 60)
        .background(Color.mainYellow.opacity(0.15))
        .cornerRadius(15)
    }

    private func delete(_ item: CertificateModel) {
        context.delete(item)
    }

    private func colorForDate(_ date: Date) -> Color {
        let now = Date()
        let days7 = Calendar.current.date(byAdding: .day, value: 7, to: now)!

        if date < now {
            return .red
        } else if date <= days7 {
            return .orange
        } else {
            return .green
        }
    }

    private func imageForData(_ date: Date) -> String {
        let now = Date()
        let days7 = Calendar.current.date(byAdding: .day, value: 7, to: now)!

        if date < now {
            return "xmark.circle.fill"
        } else if date <= days7 {
            return "hourglass"
        } else {
            return "checkmark.circle.fill"
        }
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


