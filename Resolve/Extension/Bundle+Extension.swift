//
//  Bundle+Extension.swift
//  Resolve
//
//  Created by Gerard Gomez on 5/28/22.
//

import Foundation

extension Bundle { func load<T: Decodable>(_ filename: String, _ type: T.Type = T.self,
                            dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
                            keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) -> T {
        let data: Data
        
        guard let file = self.url(forResource: filename, withExtension: nil) else {
            fatalError("Could not find \(filename) in main bundle.")
        }
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Could not load \(filename) from main bundle:\n\(error)")
        }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = dateDecodingStrategy
            decoder.keyDecodingStrategy = keyDecodingStrategy
            return try decoder.decode(T.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("Could not decode \(filename) from bundle due to missing key '\(key.stringValue)' not found - \(context.debugDescription)")
        } catch DecodingError.typeMismatch(_, let context) {
            fatalError("Could not decode \(file) from bundle due to type mismatch – \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("Could not decode \(file) from bundle due to missing \(type) value – \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(_) {
            fatalError("Could not decode \(file) from bundle because it appears to be invalid JSON")
        } catch {
            fatalError("Failed to decode \(file) from bundle: \(error.localizedDescription)")
        }
    }
}
