
import XCTest
import CustomTypeConversionCoder

class DecoderTests: XCTestCase {
    
    lazy var decoder: CustomTypeConversionDecoder = {
        let decoder = CustomTypeConversionDecoder(decoder: JSONDecoder())
        
        decoder.valueDecodingStrategy(for: Int.self, customDecoding: { decoder in
            guard let intValue = Int(try String(from: decoder)) else {
                throw DecodingError.typeMismatch(Int.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected to decode String containing a number but found a just a String instead."))
            }
            
            return intValue
        })
        
        return decoder
    }()
    
    func test_decodeObjectWithCustomDecodingForInt() {
        struct Item: Decodable {
            let numberText: Int
        }
        
        let json = """
        {
            "numberText": "10"
        }
        """.data(using: .utf8)!
        
        XCTAssertNoThrow(try decoder.decode(Item.self, from: json))
    }
    
    func test_decodeTopLevelCustomDecodingForInt() throws {
        let json = """
            "10"
        """.data(using: .utf8)!
        
        XCTAssertEqual(try decoder.decode(Int.self, from: json), 10)
    }
    
    func test_decodeTopLevelCustomDecodingForIntList() throws {
        let json = """
            ["10", "11", "12"]
        """.data(using: .utf8)!
        
        XCTAssertEqual(try decoder.decode([Int].self, from: json), [10, 11, 12])
    }
}
