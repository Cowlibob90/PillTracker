//
//  JSONStorage.swift
//  PillTracker
//
//  Created by P06 on 14/08/26.
//

import Foundation

final class JSONStorage {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init() {
        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }
    
    private func fileURL(for fileName: String) -> URL {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        .appendingPathComponent(fileName)
    }
    
    func save<T: Encodable>(
        _ value: T,
        as fileName: String
    ) throws {
        let data = try encoder.encode(value)
        
        try data.write(
            to: fileURL(for: fileName),
            options: [.atomic]
        )
    }
    
    func load<T: Decodable>(
        _ type: T.Type,
        from fileName: String
    ) throws -> T {
        let data = try Data(contentsOf: fileURL(for: fileName))
        return try decoder.decode(T.self, from: data)
    }
}
