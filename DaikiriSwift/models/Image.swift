import Foundation

public class Image : DaikiriObject, Codable, DaikiriId {
    public let id: Int
    public let url:String
    public let imageable_id:Int
    public let imageable_type:String
    
    public init(id: Int, url: String, imageable_id: Int, imageable_type: String) {
        self.id = id
        self.url = url
        self.imageable_id = imageable_id
        self.imageable_type = imageable_type
    }
    
    public func imageable() throws -> (Codable & DaikiriObject & DaikiriId)? {
        try morphTo(id: imageable_id, type: imageable_type)        
    }
}
