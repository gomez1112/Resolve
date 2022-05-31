//
//  ProductView.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/30/22.
//

import SwiftUI
import StoreKit

struct ProductView: View {
    @EnvironmentObject private var unlockManager: UnlockManager
    let product: SKProduct
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Get unlimited Goals")
                    .font(.headline)
                    .padding(.top, 20)
                Text("You can add three goals for free, or pay \(product.localizedPrice) to add unlimited goals.")
                Text("If you already bought the unlock on another device, press Restore Purchases.")
                
                Button("Buy: \(product.localizedPrice)", action: unlock)
                    .buttonStyle(PurchaseButton())
                Button("Restore Purchases", action: unlockManager.restore)
                    .buttonStyle(PurchaseButton())
            }
        }
    }
    
    func unlock() {
        unlockManager.buy(product: product)
    }
}


