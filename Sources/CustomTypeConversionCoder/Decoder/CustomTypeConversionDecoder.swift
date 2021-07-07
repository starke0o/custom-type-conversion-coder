
import Foundation
import Combine

public final class CustomTypeConversionDecoder {
    class ValueDecodings {
        static let key = CodingUserInfoKey(rawValue: "ValueDecodings")!
        
        var decodings: [String: Any] = [:]
        
        func set<Model>(for type: Model.Type, customDecoding: ((Decoder) throws -> Model)?) {
            decodings["\(type)"] = customDecoding
        }
        
        func get<Model>(for type: Model.Type) -> ((Decoder) throws -> Model)? {
            decodings["\(type)"] as? ((Decoder) throws -> Model)
        }
    }
    
    struct DecodingInterceptor<Model: Decodable>: Decodable {
        let model: Model
        
        init(from decoder: Decoder) throws {
            model = try Model(from: _CustomTypeConversionDecoder(wrappedDecoder: decoder, valueDecodings: decoder.userInfo[ValueDecodings.key] as! ValueDecodings))
        }
    }
    
    var wrappedDecoder: WrappableDecoder
    let valueDecodings = ValueDecodings()

    public init(decoder: WrappableDecoder) {
        self.wrappedDecoder = decoder
    }
    
    public func decode<Model>(_ type: Model.Type, from data: Data) throws -> Model where Model : Decodable {
        wrappedDecoder.userInfo[ValueDecodings.key] = valueDecodings
        return try wrappedDecoder.decode(DecodingInterceptor<Model>.self, from: data).model
    }
    
    public func valueDecodingStrategy<Model>(for type: Model.Type, customDecoding: ((Decoder) throws -> Model)?) {
        valueDecodings.set(for: type, customDecoding: customDecoding)
    }
}

struct _CustomTypeConversionDecoder: Decoder {
    let wrappedDecoder: Decoder
    let valueDecodings: CustomTypeConversionDecoder.ValueDecodings
    
    var codingPath = [CodingKey]()
    var userInfo = [CodingUserInfoKey : Any]()
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        try KeyedDecodingContainer(_KeyedDecodingContainer(wrappedContainer: wrappedDecoder.container(keyedBy: type),
                                                           valueDecodings: valueDecodings))
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        try _UnkeyedDecodingContainer(wrappedContainer: wrappedDecoder.unkeyedContainer(),
                                      valueDecodings: valueDecodings)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        try _SingleValueDecodingContainer(wrappedDecoder: wrappedDecoder,
                                          wrappedContainer: wrappedDecoder.singleValueContainer(),
                                          valueDecodings: valueDecodings)
    }
}

struct _KeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    typealias Key = Key
    
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
        try customDecode(type, forKey: key)
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        try KeyedDecodingContainer(_KeyedDecodingContainer<NestedKey>(wrappedContainer: wrappedContainer.nestedContainer(keyedBy: type, forKey: key),
                                                                      valueDecodings: valueDecodings))
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        try wrappedContainer.nestedUnkeyedContainer(forKey: key)
    }
    
    func superDecoder() throws -> Decoder {
        try wrappedContainer.superDecoder()
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        try wrappedContainer.superDecoder(forKey: key)
    }
    
    func customDecode<Model: Decodable>(_ type: Model.Type, forKey key: Key) throws -> Model {
        if let customDecoding = valueDecodings.get(for: type) {
            return try customDecoding(superDecoder(forKey: key))
        } else {
            return try wrappedContainer.decode(type, forKey: key)
        }
    }
}

struct _SingleValueDecodingContainer: SingleValueDecodingContainer {
    
    let wrappedDecoder: Decoder
    let wrappedContainer: SingleValueDecodingContainer
    let valueDecodings: CustomTypeConversionDecoder.ValueDecodings

    var codingPath: [CodingKey] {
        wrappedContainer.codingPath
    }

    func decodeNil() -> Bool {
        wrappedContainer.decodeNil()
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        try customDecode(type)
    }

    func decode(_ type: String.Type) throws -> String {
        try customDecode(type)
    }

    func decode(_ type: Double.Type) throws -> Double {
        try customDecode(type)
    }

    func decode(_ type: Float.Type) throws -> Float {
        try customDecode(type)
    }

    func decode(_ type: Int.Type) throws -> Int {
        try customDecode(type)
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        try customDecode(type)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        try customDecode(type)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        try customDecode(type)
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        try customDecode(type)
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        try customDecode(type)
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        try customDecode(type)
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        try customDecode(type)
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        try customDecode(type)
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        try customDecode(type)
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        try customDecode(type)
    }
    
    func customDecode<Model: Decodable>(_ type: Model.Type) throws -> Model {
        if let customDecoding = valueDecodings.get(for: type) {
            return try customDecoding(wrappedDecoder)
        } else {
            return try wrappedContainer.decode(type)
        }
    }
}

struct _UnkeyedDecodingContainer: UnkeyedDecodingContainer {
//    let wrappedDecoder: Decoder
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
