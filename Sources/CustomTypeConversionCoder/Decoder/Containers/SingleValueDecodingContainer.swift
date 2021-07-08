
import Foundation

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
