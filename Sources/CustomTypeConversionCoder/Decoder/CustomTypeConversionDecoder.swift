
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
        try KeyedDecodingContainer(_KeyedDecodingContainer(wrappedDecoder: wrappedDecoder,
                                                           wrappedContainer: wrappedDecoder.container(keyedBy: type),
                                                           valueDecodings: valueDecodings))
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        try wrappedDecoder.unkeyedContainer()
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        try wrappedDecoder.singleValueContainer()
    }
}

struct _KeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    typealias Key = Key
    
    let wrappedDecoder: Decoder
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
        try customDecode(type, forKey: key, or: try wrappedContainer.decode(type, forKey: key))
    }
    
    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        try customDecode(type, forKey: key, or: try wrappedContainer.decode(type, forKey: key))
    }
    
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        try customDecode(type, forKey: key, or: try wrappedContainer.decode(type, forKey: key))
    }
    
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        try customDecode(type, forKey: key, or: try wrappedContainer.decode(type, forKey: key))
    }
    
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        try customDecode(type, forKey: key, or: try wrappedContainer.decode(type, forKey: key))
    }
    
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        try wrappedContainer.decode(type, forKey: key)
    }
    
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        try wrappedContainer.decode(type, forKey: key)
    }
    
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        try wrappedContainer.decode(type, forKey: key)
    }
    
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        try wrappedContainer.decode(type, forKey: key)
    }
    
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        try wrappedContainer.decode(type, forKey: key)
    }
    
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        try wrappedContainer.decode(type, forKey: key)
    }
    
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        try wrappedContainer.decode(type, forKey: key)
    }
    
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        try wrappedContainer.decode(type, forKey: key)
    }
    
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        try wrappedContainer.decode(type, forKey: key)
    }
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        try wrappedContainer.decode(type, forKey: key)
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        try KeyedDecodingContainer(_KeyedDecodingContainer<NestedKey>(wrappedDecoder: wrappedDecoder,
                                                                      wrappedContainer: wrappedContainer.nestedContainer(keyedBy: type, forKey: key),
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
    
    func customDecode<Model: Decodable>(_ type: Model.Type, forKey key: Key, or decoding: @autoclosure () throws -> Model) throws -> Model {
        if let customDecoding = valueDecodings.get(for: type) {
            return try customDecoding(superDecoder(forKey: key))
        } else {
            return try decoding()
        }
    }
}

//struct _SingleValueDecodingContainer: SingleValueDecodingContainer {
//    let wrappedContainer: SingleValueDecodingContainer
//
//    var codingPath: [CodingKey]
//
//    func decodeNil() -> Bool {
//        wrappedContainer.decodeNil()
//    }
//
//    func decode(_ type: Bool.Type) throws -> Bool {
//        wrappedDecoder.d
//    }
//
//    func decode(_ type: String.Type) throws -> String {
//        <#code#>
//    }
//
//    func decode(_ type: Double.Type) throws -> Double {
//        <#code#>
//    }
//
//    func decode(_ type: Float.Type) throws -> Float {
//        <#code#>
//    }
//
//    func decode(_ type: Int.Type) throws -> Int {
//        <#code#>
//    }
//
//    func decode(_ type: Int8.Type) throws -> Int8 {
//        <#code#>
//    }
//
//    func decode(_ type: Int16.Type) throws -> Int16 {
//        <#code#>
//    }
//
//    func decode(_ type: Int32.Type) throws -> Int32 {
//        <#code#>
//    }
//
//    func decode(_ type: Int64.Type) throws -> Int64 {
//        <#code#>
//    }
//
//    func decode(_ type: UInt.Type) throws -> UInt {
//        <#code#>
//    }
//
//    func decode(_ type: UInt8.Type) throws -> UInt8 {
//        <#code#>
//    }
//
//    func decode(_ type: UInt16.Type) throws -> UInt16 {
//        <#code#>
//    }
//
//    func decode(_ type: UInt32.Type) throws -> UInt32 {
//        <#code#>
//    }
//
//    func decode(_ type: UInt64.Type) throws -> UInt64 {
//        <#code#>
//    }
//
//    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
//        <#code#>
//    }
//}
