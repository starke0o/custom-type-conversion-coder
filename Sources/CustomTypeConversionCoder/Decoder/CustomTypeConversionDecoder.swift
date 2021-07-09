
import Foundation

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
