//
//  Award.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/28/22.
//

import Foundation

struct Award: Codable, Identifiable {
    var id: String { name }
    let name: String
    let description: String
    let color: String
    let criterion: String
    let value: Int
    let image: String
    
    static let allAwards: [Award] = Bundle.main.load("Awards.json")
    static let example = allAwards[5]
}
