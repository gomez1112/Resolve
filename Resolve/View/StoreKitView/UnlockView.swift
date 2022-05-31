//
//  UnlockView.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/30/22.
//

import SwiftUI
import StoreKit

struct UnlockView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var unlockManager: UnlockManager
    var body: some View {
        VStack {
            switch unlockManager.requestState {
                case .loaded(let product):
                    ProductView(product: product)
                case .failed(_):
                    Text("Sorry, there was an error loading the store, Please try again later.")
                case .loading:
                    ProgressView("Loading...")
                case .purchased:
                    Text("Thank you!")
                case .deferred:
                    Text("Thank you! Your request is pending approval, but you can carry on using the app in the meantime.")
            }
            Button("Dismiss") {
                dismiss()
            }
        }
        .padding()
        .onReceive(unlockManager.$requestState) { value in
            if case .purchased = value {
                dismiss()
            }
        }
    }
}

