
import XCTest
@testable import CustomTypeConversionCoder

class DecoderTests: XCTestCase {
    func testDecode() {
        
        struct Item: Decodable {
            let numberText: Int
        }
        
        let json = """
        {
            "numberText": "10"
        }
        """.data(using: .utf8)!
        
        let decoder = CustomTypeConversionDecoder(decoder: JSONDecoder())
        
        decoder.valueDecodingStrategy(for: Int.self, customDecoding: { decoder in
            return Int(try String(from: decoder))!
        })
        
        XCTAssertNoThrow(try decoder.decode(Item.self, from: json))
    }
}
