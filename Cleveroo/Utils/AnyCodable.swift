//
//  AnyCodable.swift
//  Cleveroo
//
//  Created by Maya Marzouki on 30/11/2025.
//

import Foundation

/// Helper enum to decode dynamic JSON values
enum AnyCodable: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([AnyCodable])
    case dictionary([String: AnyCodable])
    case null
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let array = try? container.decode([AnyCodable].self) {
            self = .array(array)
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            self = .dictionary(dict)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode AnyCodable")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let string):
            try container.encode(string)
        case .int(let int):
            try container.encode(int)
        case .double(let double):
            try container.encode(double)
        case .bool(let bool):
            try container.encode(bool)
        case .array(let array):
            try container.encode(array)
        case .dictionary(let dict):
            try container.encode(dict)
        case .null:
            try container.encodeNil()
        }
    }
    
    // Helper to extract value
    var value: Any {
        switch self {
        case .string(let str): return str
        case .int(let int): return int
        case .double(let dbl): return dbl
        case .bool(let bool): return bool
        case .array(let arr): return arr.map { $0.value }
        case .dictionary(let dict): return dict.mapValues { $0.value }
        case .null: return NSNull()
        }
    }
}
