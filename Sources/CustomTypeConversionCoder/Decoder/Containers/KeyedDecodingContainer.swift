
import Foundation

struct _KeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    
    let wrappedContainer: KeyedDecodingContainer<Key>
    let valueDecodings: CustomTypeConversionDecoder.ValueDecodings
    
    var codingPath: [CodingKey] {
        wrappedContainer.codingPath
    }
    
    var allKeys: [Key] {
        wrappedContainer.allKeys
    }
    
    func contains(_ key: Key) -> Bool {
        wrappedContainer.contains(key)
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        try wrappedContainer.decodeNil(forKey: key)
    }
    
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        try customDecode(type, forKey: key)
    }
    
    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        try customDecode(type, forKey: key)
    }
    
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        try customDecode(type, forKey: key)
    }
    
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        try customDecode(type, forKey: key)
    }
    
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        try customDecode(type, forKey: key)
    }
    
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        try customDecode(type, forKey: key)
    }
    
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        try customDecode(type, forKey: key)
    }
    
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        try customDecode(type, forKey: key)
    }
    
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        try customDecode(type, forKey: key)
    }
    
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        try customDecode(type, forKey: key)
    }
    
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        try customDecode(type, forKey: key)
    }
    
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        try customDecode(type, forKey: key)
    }
    
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        try customDecode(type, forKey: key)
    }
    
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        try customDecode(type, forKey: key)
    }
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        if let customDecoding = valueDecodings.get(for: type) {
            return try customDecoding(wrappedContainer.superDecoder(forKey: key))
        } else {
            return try T(from: superDecoder(forKey: key))
        }
    }
    
    func decodeIfPresent(_ type: Bool.Type, forKey key: Key) throws -> Bool? {
        try customDecodeIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: String.Type, forKey key: Key) throws -> String? {
        try customDecodeIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: Double.Type, forKey key: Key) throws -> Double? {
        try customDecodeIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: Float.Type, forKey key: Key) throws -> Float? {
        try customDecodeIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: Int.Type, forKey key: Key) throws -> Int? {
        try customDecodeIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: Int8.Type, forKey key: Key) throws -> Int8? {
        try customDecodeIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: Int16.Type, forKey key: Key) throws -> Int16? {
        try customDecodeIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: Int32.Type, forKey key: Key) throws -> Int32? {
        try customDecodeIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: Int64.Type, forKey key: Key) throws -> Int64? {
        try customDecodeIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: UInt.Type, forKey key: Key) throws -> UInt? {
        try customDecodeIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: UInt8.Type, forKey key: Key) throws -> UInt8? {
        try customDecodeIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: UInt16.Type, forKey key: Key) throws -> UInt16? {
        try customDecodeIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: UInt32.Type, forKey key: Key) throws -> UInt32? {
        try customDecodeIfPresent(type, forKey: key)
    }

    func decodeIfPresent(_ type: UInt64.Type, forKey key: Key) throws -> UInt64? {
        try customDecodeIfPresent(type, forKey: key)
    }

    func decodeIfPresent<T>(_ type: T.Type, forKey key: Key) throws -> T? where T : Decodable {
        try customDecodeIfPresent(type, forKey: key)
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        try KeyedDecodingContainer(_KeyedDecodingContainer<NestedKey>(wrappedContainer: wrappedContainer.nestedContainer(keyedBy: type, forKey: key),
                                                                      valueDecodings: valueDecodings))
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        try _UnkeyedDecodingContainer(wrappedContainer: wrappedContainer.nestedUnkeyedContainer(forKey: key),
                                      valueDecodings: valueDecodings)
    }
    
    func superDecoder() throws -> Decoder {
        try _CustomTypeConversionDecoder(wrappedDecoder: wrappedContainer.superDecoder(),
                                         valueDecodings: valueDecodings)
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        try _CustomTypeConversionDecoder(wrappedDecoder: wrappedContainer.superDecoder(forKey: key),
                                         valueDecodings: valueDecodings)
    }
    
    func customDecodeIfPresent<Model: Decodable>(_ type: Model.Type, forKey key: Key) throws -> Model? {
        
        let isNilOrNotPresent = (try? decodeNil(forKey: key)) ?? true
        
        guard !isNilOrNotPresent else {
            return nil
        }
        
        if let customDecoding = valueDecodings.get(for: Model?.self) {
            return try customDecoding(superDecoder(forKey: key))
        } else {
            return try customDecode(Model.self, forKey: key)
        }
    }
    
    func customDecode<Model: Decodable>(_ type: Model.Type, forKey key: Key) throws -> Model {
        if let customDecoding = valueDecodings.get(for: type) {
            return try customDecoding(superDecoder(forKey: key))
        } else {
            return try Model(from: superDecoder(forKey: key))
        }
    }
}
