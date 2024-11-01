import Foundation

class Image : DaikiriObject, Codable, DaikiriId {
    let id: Int
    let url:String
    let imageable_id:Int
    let imageable_type:String
    
    init(id: Int, url: String, imageable_id: Int, imageable_type: String) {
        self.id = id
        self.url = url
        self.imageable_id = imageable_id
        self.imageable_type = imageable_type
    }
    
    public func imageable() throws -> (Codable & DaikiriObject & DaikiriId)? {
        try morphTo(id: imageable_id, type: imageable_type)        
    }
}
