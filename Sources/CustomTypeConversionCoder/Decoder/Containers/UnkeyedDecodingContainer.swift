
import Foundation

struct _UnkeyedDecodingContainer: UnkeyedDecodingContainer {
    var wrappedContainer: UnkeyedDecodingContainer
    let valueDecodings: CustomTypeConversionDecoder.ValueDecodings

    var codingPath: [CodingKey] {
        wrappedContainer.codingPath
    }
    
    var count: Int? { wrappedContainer.count }
    var currentIndex: Int { wrappedContainer.currentIndex }
    var isAtEnd: Bool { wrappedContainer.isAtEnd }
    
    mutating func decodeNil() throws -> Bool {
        try wrappedContainer.decodeNil()
    }
    
    mutating func decode(_ type: Bool.Type) throws -> Bool {
        return try customDecode(type)
    }
    
    mutating func decode(_ type: String.Type) throws -> String {
        try customDecode(type)
    }
    
    mutating func decode(_ type: Double.Type) throws -> Double {
        try customDecode(type)
    }
    
    mutating func decode(_ type: Float.Type) throws -> Float {
        try customDecode(type)
    }
    
    mutating func decode(_ type: Int.Type) throws -> Int {
        try customDecode(type)
    }
    
    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        try customDecode(type)
    }
    
    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        try customDecode(type)
    }
    
    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        try customDecode(type)
    }
    
    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        try customDecode(type)
    }
    
    mutating func decode(_ type: UInt.Type) throws -> UInt {
        try customDecode(type)
    }
    
    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        try customDecode(type)
    }
    
    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        try customDecode(type)
    }
    
    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        try customDecode(type)
    }
    
    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        try customDecode(type)
    }
    
    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        try customDecode(type)
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        try KeyedDecodingContainer(_KeyedDecodingContainer<NestedKey>(wrappedContainer: wrappedContainer.nestedContainer(keyedBy: type),
                                                                      valueDecodings: valueDecodings))
    }
    
    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        try wrappedContainer.nestedUnkeyedContainer()
    }
    
    
    mutating func superDecoder() throws -> Decoder {
        try wrappedContainer.superDecoder()
    }
    
    mutating func customDecode<Model: Decodable>(_ type: Model.Type) throws -> Model {
        if let customDecoding = valueDecodings.get(for: type) {
            return try customDecoding(superDecoder())
        } else {
            return try wrappedContainer.decode(Model.self)
        }
    }
}