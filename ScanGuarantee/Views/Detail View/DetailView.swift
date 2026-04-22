//
//  DetailView.swift
//  ScanGuarantee
//
//  Created by Mark Vadimov on 16.04.26.
//

import SwiftUI

struct DetailView: View {
    let item: CertificateModel
    @State private var showEditSheet = false
    
    var body: some View {
        VStack(spacing: 20){
            HStack{
                Text("Warranty details: ")
                    .font(Font.custom("PlayfairDisplay-ExtraBold", size: 23))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.mainYellow)
                    
                
                Button {
                    showEditSheet = true
                } label: {
                    Image(systemName: "pencil")
                        .resizable()
                        .frame(width: 23, height: 23)
                        .foregroundStyle(Color.mainYellow)
                }
            }
            .padding(.horizontal, 20)
            
            ScrollView {
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
                        detailRow(title: "Product:", value: item.productName, valueColor: .mainYellow)
                        
                        detailRow(
                            title: "Valid until:",
                            value: item.validTo.formatted(date: .abbreviated, time: .omitted) + daysUntil(item.validTo),
                            valueColor: colorForDate(item.validTo)
                        )
                        
                        if let serialNumber = item.serialNumber, !serialNumber.isEmpty {
                            detailRow(title: "Serial number:", value: serialNumber, valueColor: .mainYellow)
                        }
                        
                        if let buyDate = item.buyDate {
                            detailRow(
                                title: "Buy date:",
                                value: buyDate.formatted(date: .abbreviated, time: .omitted),
                                valueColor: .mainYellow
                            )
                        }
                        
                        if let sellerName = item.sellerName, !sellerName.isEmpty {
                            detailRow(title: "Seller:", value: sellerName, valueColor: .mainYellow)
                        }
                        
                        if let sellerEmail = item.sellerEmail, !sellerEmail.isEmpty {
                            detailRow(title: "Email:", value: sellerEmail, valueColor: .mainYellow)
                        }
                        
                        if let sellerPhone = item.sellerPhone, !sellerPhone.isEmpty {
                            detailRow(title: "Phone:", value: sellerPhone, valueColor: .mainYellow)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 20)
                }
                .padding(.top, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mainDarkBlue)
        .sheet(isPresented: $showEditSheet) {
            EditCertificateView(item: item)
        }
    }
    
    @ViewBuilder
    private func detailRow(title: String, value: String, valueColor: Color) -> some View {
        HStack(alignment: .bottom) {
            Text(title)
                .font(Font.custom("PlayfairDisplay-Medium", size: 17))
                .foregroundStyle(.mainYellow.opacity(0.7))
            
            Text(value)
                .font(Font.custom("PlayfairDisplay-Medium", size: 21))
                .foregroundStyle(valueColor)
                .underline()
            
            Spacer()
        }
    }
    
    private func daysUntil(_ date: Date) -> String {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let startOfTargetDate = calendar.startOfDay(for: date)
        
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfTargetDate)
        let days = components.day ?? 0
        
        if days < 0 {
            return " (expired on \(abs(days)) d.)"
        } else if days == 0 {
            return " (today)"
        } else {
            return " (\(days) d.)"
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
        )
    )
}
