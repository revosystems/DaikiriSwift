import Foundation

public class Image : Daikiri, Codable, DaikiriId {
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
    
    
    convenience public init(id:Int, url:String, imageable:DaikiriId){
        self.init(
            id: id, url: url,
            imageable_id: imageable.id,
            imageable_type: String(describing: imageable).components(separatedBy: ".").last!
        )
    }
    
    public func imageable() throws -> (Codable & Daikiri & DaikiriId)? {
        try morphTo(id: imageable_id, type: imageable_type)        
    }
}
