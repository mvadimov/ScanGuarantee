struct EditCertificateView: View {
    @Bindable var item: CertificateModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("Product name", text: $item.productName)

                TextField("Serial number", text: Binding(
                    get: { item.serialNumber ?? "" },
                    set: { item.serialNumber = $0.isEmpty ? nil : $0 }
                ))

                DatePicker("Valid until", selection: $item.validTo, displayedComponents: .date)

                if let buyDate = item.buyDate {
                    DatePicker(
                        "Buy date",
                        selection: Binding(
                            get: { buyDate },
                            set: { item.buyDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                }

                TextField("Seller", text: Binding(
                    get: { item.sellerName ?? "" },
                    set: { item.sellerName = $0.isEmpty ? nil : $0 }
                ))

                TextField("Email", text: Binding(
                    get: { item.sellerEmail ?? "" },
                    set: { item.sellerEmail = $0.isEmpty ? nil : $0 }
                ))

                TextField("Phone", text: Binding(
                    get: { item.sellerPhone ?? "" },
                    set: { item.sellerPhone = $0.isEmpty ? nil : $0 }
                ))
            }
            .navigationTitle("Edit certificate")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        item.updatedAt = Date()
                        dismiss()
                    }
                }
            }
        }
    }
}