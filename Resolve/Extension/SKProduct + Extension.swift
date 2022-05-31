//
//  SKProduct + Extension.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/30/22.
//

import StoreKit

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
