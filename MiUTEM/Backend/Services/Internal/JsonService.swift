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
    
    static func fromJson<T: Decodable>(_ type: T.Type, _ json: Any) -> T? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            let object = try sharedDecoder.decode(type, from: jsonData)
            return object
        } catch {
            print("Error decoding JSON: \(error.localizedDescription)")
            return nil
        }
    }
    
    static func fromJsonArray<T: Decodable>(_ type: [T].Type, _ jsonArray: Any) -> [T]? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
            let objects = try sharedDecoder.decode(type, from: jsonData)
            return objects
        } catch {
            print("Error decoding JSON array: \(error.localizedDescription)")
            print(error)
            return nil
        }
    }
}
