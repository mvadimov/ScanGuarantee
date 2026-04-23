//
//  DetailView.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 16.04.26.
//

import SwiftUI
import SwiftData

struct DetailView: View {
    let item: CertificateModel
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @Environment(\.modelContext) private var context
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 20){
            HStack {
                Button(action: {
                    HapticManager.impact(.light)
                    onClose()
                }) {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .frame(width: 14, height: 24)
                        .foregroundStyle(.mainYellow)
                }
                
                Spacer()
                
                Text("Гарантийный талон: ")
                    .font(Font.custom("PlayfairDisplay-ExtraBold", size: 22))
                    .foregroundStyle(.mainYellow)
                
                Spacer()
                Button(action: {
                    HapticManager.impact(.light)
                    showEditSheet = true
                }) {
                    Image(systemName: "pencil")
                        .resizable()
                        .frame(width: 23, height: 23)
                        .foregroundStyle(.mainYellow)
                }
            }
            .padding(.horizontal, 20)
            
            ScrollView{
                VStack(spacing: 20) {
                    if let imageData = item.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .frame(height: 400)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal, 20)
                    }
                    
                    VStack(spacing: 10) {
                        detailRow(title: "Товар:", value: item.productName, valueColor: .mainYellow)
                        
                        detailRow(
                            title: "Действительный до:",
                            value: item.validTo.ruDate() + daysUntil(item.validTo),
                            valueColor: colorForDate(item.validTo)
                        )
                        
                        if let serialNumber = item.serialNumber, !serialNumber.isEmpty {
                            detailRow(title: "Серийный номер:", value: serialNumber, valueColor: .mainYellow)
                        }
                        
                        if let buyDate = item.buyDate {
                            detailRow(
                                title: "Дата покупки:",
                                value: buyDate.ruDate(),
                                valueColor: .mainYellow
                            )
                        }
                        
                        if let sellerName = item.sellerName, !sellerName.isEmpty {
                            detailRow(title: "Продавец:", value: sellerName, valueColor: .mainYellow)
                        }
                        
                        if let sellerEmail = item.sellerEmail, !sellerEmail.isEmpty {
                            detailRow(title: "Email:", value: sellerEmail, valueColor: .mainYellow)
                        }
                        
                        if let sellerPhone = item.sellerPhone, !sellerPhone.isEmpty {
                            detailRow(title: "Телефон:", value: sellerPhone, valueColor: .mainYellow)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 20)
                    
                    Button {
                        HapticManager.impact(.light)
                        showDeleteAlert = true
                    } label: {
                        Text("Удалить талон")
                            .font(Font.custom("PlayfairDisplay-ExtraBold", size: 18))
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.red.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mainDarkBlue)
        .sheet(isPresented: $showEditSheet) {
            EditCertificateView(item: item)
                .presentationBackground(.mainDarkBlue)
        }
        .alert("Хотите удалить?", isPresented: $showDeleteAlert) {
            Button("Отмена", role: .cancel) {
                print(showDeleteAlert)
            }
            
            Button("Удалить талон") {
                HapticManager.impact(.light)
                deleteCertificate()
            }
        }
    }
    
    @ViewBuilder
    private func detailRow(title: String, value: String, valueColor: Color) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(Font.custom("PlayfairDisplay-Medium", size: 17))
                .foregroundStyle(.mainYellow.opacity(0.7))
            
            Text(value)
                .font(Font.custom("PlayfairDisplay-Medium", size: 20))
                .foregroundStyle(valueColor)
                .underline()
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
    
    private func deleteCertificate() {
        NotificationService.shared.removeNotification(for: item)
        context.delete(item)
        onClose()
    }
    
    private func daysUntil(_ date: Date) -> String {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let startOfTargetDate = calendar.startOfDay(for: date)
        
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfTargetDate)
        let days = components.day ?? 0
        
        if days < 0 {
            return "\n (истек \(abs(days)) д. назад)"
        } else if days == 0 {
            return " (сегодня)"
        } else {
            return " (\(days) д.)"
        }
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
}

#Preview {
    DetailView(
        item: CertificateModel(
            productName: "iPhone 17 Pro Max",
            serialNumber: "SN-123456789",
            buyDate: Calendar.current.date(byAdding: .day, value: -30, to: .now),
            validTo: Calendar.current.date(byAdding: .month, value: 11, to: .now)!,
            sellerName: "Apple Store",
            sellerEmail: "support@apple.com",
            sellerPhone: "+1 800 275 2273",
            imageData: UIImage(named: "test")?.pngData(),
            rawText: """
            iPhone 17 Pro Max
            Serial: SN-123456789
            Date of purchase: 10.02.2026
            Warranty: 12 months
            Apple Store
            """
        ), onClose: {}
    )
}
