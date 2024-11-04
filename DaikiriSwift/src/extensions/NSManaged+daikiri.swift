import CoreData

extension NSManagedObject {
    
    func toJson() throws -> Data {
        var json: [String:Any] = [:]
        
        entity.attributesByName.forEach { (key: String, value: NSAttributeDescription) in
            json[key] = self.value(forKey: key)
        }
        return try JSONSerialization.data(withJSONObject: json, options: [])
    }
}
