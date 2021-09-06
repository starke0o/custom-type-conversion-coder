
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
        struct Item: Decodable, Equatable {
            let number: Int
        }
        
        let json = """
        {
            "number": "10"
        }
        """.data(using: .utf8)!
        
        XCTAssertEqual(try decoder.decode(Item.self, from: json), Item(number: 10))
    }
    
    func test_decodeNestedObjectWithCustomDecodingForDate() throws {
        struct Item: Decodable, Equatable {
            struct NestedItem: Decodable, Equatable {
                let date: Date
            }
            
            let nested: NestedItem
        }
        
        let json = """
        {
            "nested": {
                "date": 231231
            }
        }
        """.data(using: .utf8)!
        
        decoder.valueDecodingStrategy(for: Date.self, customDecoding: { decoder in
            let container = try decoder.singleValueContainer()
            let int = try container.decode(Int.self)
            
            return Date(timeIntervalSinceReferenceDate: Double(int))
        })
        
        XCTAssertEqual(try decoder.decode(Item.self, from: json), Item(nested: .init(date: Date(timeIntervalSinceReferenceDate: 231231))))
    }
    
    func test_decodeNestedObjectWithCustomDecodingForInt() {
        struct Item: Decodable, Equatable {
            struct NestedItem: Decodable, Equatable {
                let number: Int
            }
            
            let nested: NestedItem
        }
        
        let json = """
        {
            "nested": {
                "number": "10"
            }
        }
        """.data(using: .utf8)!
        
        XCTAssertEqual(try decoder.decode(Item.self, from: json), Item(nested: .init(number: 10)))
    }
    
    func test_decodeObjectWithCustomDecodingForIntInList() throws {
        struct Item: Decodable, Equatable {
            let numberText: Int
        }
        
        let json = """
        [
            {
                "numberText": "10"
            },
            {
                "numberText": "11"
            }
        ]
        """.data(using: .utf8)!
        
        XCTAssertEqual(try decoder.decode([Item].self, from: json), [Item(numberText: 10), Item(numberText: 11)])
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
    
    func test_decodeObjectWithOptionalResult() {
        struct Item: Decodable, Equatable {
            let number: UInt?
        }
        
        let decoder = CustomTypeConversionDecoder(decoder: JSONDecoder())
        
        decoder.valueDecodingStrategy(for: UInt?.self, customDecoding: { decoder in
            let int = try Int(from: decoder)
            
            if int > 0 {
                return UInt(int)
            } else {
                return nil
            }
        })
        
        let json = """
        {
            "number": -2
        }
        """.data(using: .utf8)!
        
        XCTAssertEqual(try decoder.decode(Item.self, from: json), Item(number: nil))
    }
    
    func test_decodeObjectWithOptionalResultAndReuse() {
        struct Item: Decodable, Equatable {
            let number: UInt?
        }
        
        let decoder = self.decoder
        
        decoder.valueDecodingStrategy(for: UInt?.self, customDecoding: { decoder in
            let container = try decoder.singleValueContainer()
            let int = try container.decode(Int.self)
            
            if int > 0 {
                return UInt(int)
            } else {
                return nil
            }
        })
        
        let json = """
        {
            "number": "-2"
        }
        """.data(using: .utf8)!
        
        XCTAssertEqual(try decoder.decode(Item.self, from: json), Item(number: nil))
    }
    
    func test_decodeObjectWithNull() {
        struct Item: Decodable, Equatable {
            let number: Int?
        }
        
        let json = """
        {
            "number": null
        }
        """.data(using: .utf8)!
        
        XCTAssertEqual(try decoder.decode(Item.self, from: json), Item(number: nil))
    }
}
