//
//  ScanGarantApp.swift
//  ScanGarant
//
//  Created by Mark Vadimov on 14.04.26.
//

import SwiftUI
import SwiftData

@main
struct ScanGuaranteeApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: CertificateModel.self)
    }
}
