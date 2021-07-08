
import Foundation

public protocol WrappableDecoder {
    var userInfo: [CodingUserInfoKey : Any] { get set }
    func decode<Model>(_ type: Model.Type, from data: Data) throws -> Model where Model : Decodable
}

extension JSONDecoder: WrappableDecoder {}
