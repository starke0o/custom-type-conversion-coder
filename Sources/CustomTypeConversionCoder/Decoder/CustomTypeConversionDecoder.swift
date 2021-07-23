
import Foundation

/// The `CustomTypeConversionDecoder` is not a classic decoder like the `JSONDecoder`.
/// It is just a wrapper for other decoders to provide functionality that overrides the default value decodings.
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

    /// Initializes `self` with a wrappable decoder.
    /// - parameter decoder: The decoder to wrap
    public init(decoder: WrappableDecoder) {
        self.wrappedDecoder = decoder
    }
    
    /// Decodes a top-level value of the given type using the provided decoder.
    /// - parameter type: The type of the value to decode.
    /// - parameter data: The data to decode from.
    /// - returns: A value of the requested type.
    /// - throws: An error if any value throws an error during decoding.
    public func decode<Model>(_ type: Model.Type, from data: Data) throws -> Model where Model : Decodable {
        wrappedDecoder.userInfo[ValueDecodings.key] = valueDecodings
        return try wrappedDecoder.decode(DecodingInterceptor<Model>.self, from: data).model
    }
    
    /// Sets the strategy to use in decoding models of a given type.
    /// - parameter type: The type for which the custom decoding is to be used
    /// - parameter customDecoding: Decode the `Model` as a custom value decoded by the given closure.
    public func valueDecodingStrategy<Model>(for type: Model.Type, customDecoding: ((Decoder) throws -> Model)?) {
        valueDecodings.set(for: type, customDecoding: customDecoding)
    }
}

// MARK: _CustomTypeConversionDecoder

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
