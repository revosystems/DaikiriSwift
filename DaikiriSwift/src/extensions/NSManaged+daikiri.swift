import CoreData

extension NSManagedObject {
    func toJson() throws -> Data {
        var json: [String: Any] = [:]

        try entity.attributesByName.forEach { (key: String, value: NSAttributeDescription) in
            let fieldValue = self.value(forKey: key)
            
            if isCustomEncodable(fieldValue) {
                let encodableValue = fieldValue as! Encodable
                let encodedData = try JSONEncoder().encode(AnyEncodable(encodableValue))
                let encodedJson = try JSONSerialization.jsonObject(with: encodedData, options: [])
                json[key] = encodedJson
                return
            }
            
            json[key] = fieldValue
        }

        return try JSONSerialization.data(withJSONObject: json, options: [])
    }

    private func isCustomEncodable(_ value: Any) -> Bool {
        let foundationTypes: [Any.Type] = [
            String.self, Bool.self, Double.self, Float.self,
            Int.self, Int8.self, Int16.self, Int32.self, Int64.self,
            UInt.self, UInt8.self, UInt16.self, UInt32.self, UInt64.self,
            Array<Any>.self, Dictionary<String, Any>.self,
            Date.self, Data.self
        ]
        
        if foundationTypes.contains { $0 == type(of: value) } {
            return false
        }

        return value is Encodable
    }
}
