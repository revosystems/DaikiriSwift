import CoreData

extension NSManagedObject {
    func toJson() throws -> Data {
        var json: [String: Any] = [:]

        try entity.attributesByName.forEach { (key: String, value: NSAttributeDescription) in
            let fieldValue = self.value(forKey: key)

            if let arrayValue = fieldValue as? [Any] {
                let encodableArray = arrayValue.compactMap { $0 as? Encodable }
                if encodableArray.count == arrayValue.count {
                    json[key] = try getEncodedJson(value: encodableArray.map { AnyEncodable($0) })
                    return
                }
            }

            if let encodableValue = fieldValue as? Encodable {
                json[key] = try getEncodedJson(value: AnyEncodable(encodableValue))
                return
            }

            json[key] = fieldValue
        }

        return try JSONSerialization.data(withJSONObject: json, options: [])
    }
    
    private func getEncodedJson(value:Encodable) throws -> Any? {
        let encodedData = try JSONEncoder().encode(value)
        let encodedJson = try JSONSerialization.jsonObject(with: encodedData, options: [])
        
        return encodedJson
    }
}
