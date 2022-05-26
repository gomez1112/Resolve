//
//  Binding+Extension.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/25/22.
//

import SwiftUI

extension Binding {
    func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
        Binding {
            wrappedValue
        } set: { newValue in
            wrappedValue = newValue
            handler()
        }

    }
}
