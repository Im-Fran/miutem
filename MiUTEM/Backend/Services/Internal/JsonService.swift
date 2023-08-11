//
//  JsonService.swift
//  MiUTEM
//
//  Created by Francisco Solis Maturana on 02-08-23.
//

import Foundation

class JsonService {
    
    static let sharedDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        // Configure the decoder if needed
        return decoder
    }()
    
    static let sharedEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        // Configure encoder if needed
        return encoder
    }()
    
    static func toJson<T: Encodable>(_ value: T) throws -> Data {
        return try sharedEncoder.encode(value)
    }
    
    static func toJsonArray<T: Encodable>(_ values: [T]) throws -> Data {
        return try sharedEncoder.encode(values)
    }
    
    static func fromJson<T: Decodable>(_ type: T.Type, _ data: Data) throws -> T {
        return try sharedDecoder.decode(type, from: data)
    }
    
    static func fromJsonArray<T: Decodable>(_ type: [T].Type, _ data: Data) throws -> [T] {
        return try sharedDecoder.decode(type, from: data)
    }
}
