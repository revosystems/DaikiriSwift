import Foundation

public protocol Factoriable: DaikiriIdentifiable, Decodable{
    
}


//extension DaikiriIdentifiable {
public extension Factoriable {
    
    static func factory() -> Factory2<Self>? {
        
        let baseModel = (String(reflecting: self) + "Factory").components(separatedBy: ".")
        guard let namespace = baseModel.first, let factoryName = baseModel.last else {
            return nil
        }

        let factoryCandidate1 = namespace + "." + factoryName
        let factoryCandidate2 = namespace + "Tests." + factoryName
        
        if let factory = initalizeFactory(factoryCandidate1) {
            return factory
        }
        if let factory = initalizeFactory(factoryCandidate2) {
            return factory
        }
        return nil
    }
    
    private static func initalizeFactory(_ candidate:String) -> Factory2<Self>? {
        guard let factory:Factory2<Self>.Type = NSClassFromString(candidate) as? Factory2<Self>.Type else {
            return nil
        }
        return factory.init()
    }
}

open class Factory2<T:DaikiriIdentifiable & Decodable> {
       
    public required init(){}
    

    /**
     * Define here the main attributes of the model to be created by the factory
     */
    open func definition() -> NSMutableDictionary{
        return [:]
    }
    
    
    /**
     * Use this function to define a state that will be applied to the factory
     */
    public func state() -> Self {
        return self
    }
    
    /**
     * Generates the instance with all the previous states
     */
    public func make(_ overrides:NSDictionary = [:]) -> T {
        let finalDict = definition()
                
        overrides.allKeys.forEach{
            finalDict[$0] = overrides[$0]
        }
        
        if finalDict["id"] == nil {
            finalDict["id"] = Int.random(in: 1 ..< 99999)
        }
        
        return make(final: finalDict)
    }
    
    private func make(final:NSDictionary) -> T{
        guard let data = Self.toJson(final) else { return T.init() }
        do {
            return try JSONDecoder().decode(T.self, from:data)
        } catch {
            print("Error decoding: \(error)")
            return T.init()
        }
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
