import Foundation

/**
 This one goes to AnotherSQL
 */
public class Vehicle : Daikiri, DaikiriId, Codable {
    public var id: Int?
    public let name:String
    
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}
