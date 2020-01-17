import Foundation

public class Factory {
    
    static var factories = [String: ()->NSDictionary]()
    
    public static func register<T:Decodable>(_ type:T.Type, clousure:@escaping()->NSDictionary){
        factories[String(describing: type)] = clousure
    }
    
    public static func make<T:Decodable>(_ type:T.Type, _ overload:NSDictionary? = nil) -> T?{
        guard let dictClousure  = factories[String(describing: type)] else { return nil }
        guard let finalDict     = dictClousure().mutableCopy() as? NSMutableDictionary else { return nil }
        
        if finalDict["id"] == nil {
            finalDict["id"] = Int.random(in: 1 ..< 9999)
        }
        
        if let overload = overload {
            overload.allKeys.forEach({ key in
                finalDict[key] = overload[key]
            })
        }
        
        guard let data = toJson(finalDict) else { return nil }
        return try? JSONDecoder().decode(type, from:data)
    }
    
    
    
    // MARK: Helpers
    static func toJson(_ dict:NSDictionary) -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
