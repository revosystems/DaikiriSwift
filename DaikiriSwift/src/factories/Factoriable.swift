import Foundation

public protocol Factoriable: DaikiriIdentifiable, Decodable{
    
}


//extension DaikiriIdentifiable {
public extension Factoriable {
    
    /**
     * This can be overrided in an extesion providing the right ModelFactory so no casts are required in the tests and something like this can be called
     *
     * `Hero.factory().young().make()`
     *
     * Check HeroFactory.swift for an example
     */
    static func factory() -> Factory<Self>? {
        makeFactory()
    }
    
    
    /**
     * The real one that checks if factory exists, add more candidates if needed
     */
    static func makeFactory() -> Factory<Self>? {
        
        let baseModel = (String(reflecting: self) + "Factory").components(separatedBy: ".")
        guard let namespace = baseModel.first, let factoryName = baseModel.last else {
            return nil
        }
        
        var factory:Factory<Self>? = nil
        
        candidatesFor(namespace:namespace, factoryName:factoryName).forEach {
            if factory != nil { return }
            factory = initalizeFactory($0)
        }

        return factory
    }
    
    /**
     * Override this one in cas you want to provide alternatives to find the factory
     */
    static func candidatesFor(namespace:String, factoryName:String) -> [String]{
        [
            namespace + "." + factoryName,
            namespace + "Tests." + factoryName
        ]
    }
    
    
    private static func initalizeFactory(_ candidate:String) -> Factory<Self>? {
        guard let factory:Factory<Self>.Type = NSClassFromString(candidate) as? Factory<Self>.Type else {
            return nil
        }
        return factory.init()
    }
}
