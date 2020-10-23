import Foundation


open class Factory<T:DaikiriIdentifiable & Decodable> {
       
    public required init(){}
    
    var states:NSMutableDictionary = [:]
        
    // MARK:- To be overrided
    /**
     * Define here the main attributes of the model to be created by the factory
     */
    open func definition() -> NSMutableDictionary{
        return [:]
    }
    
    
    /**
     * Additional configuration can be done overriding this method in your factory, it will be called for each model created
     */
    open func afterMaking(_ model:T){
        
    }
    
    
    // MARK:- To be used
    /**
     * Use this function to define a state that will be applied to the factory
     */
    public func state(_ state:NSDictionary, overrides:NSDictionary) -> Self {
        state.forEach { states[$0] = $1 }
        overrides.forEach { states[$0] = $1 }
        return self
    }
        
    /**
     * Generates the instance with all the previous states
     */
    public func make(_ overrides:NSDictionary = [:]) -> T {
        let finalDict = definition()
                
        states.allKeys.forEach{
            finalDict[$0] = states[$0]
        }
        
        overrides.allKeys.forEach{
            finalDict[$0] = overrides[$0]
        }
        
        if finalDict["id"] == nil {
            finalDict["id"] = Int.random(in: 1 ..< 99999)
        }
        
        /*finalDict.allKeys.forEach { key in
            let value = finalDict[key]
            if let factory = value as? Factory{
                finalDict[key] = factory.make().id
            }
        }*/
        
        finalDict.allKeys.forEach { key in
            let value = finalDict[key]
            if let clousure = value as? (()->Int32) {
                finalDict[key] = clousure()
            }
        }
        
        return make(final: finalDict)
    }
    
    public func make(count:Int, _ overrides:NSDictionary = [:]) -> [T]{
        (0..<count).map {_ in
            make(overrides)
        }
    }
    
    
    // MARK:- Private
    private func make(final:NSDictionary) -> T{
        guard let data = Self.toJson(final) else { return T.init() }
        do {
            let model:T = try JSONDecoder().decode(T.self, from:data)
            afterMaking(model)
            return model
        } catch {
            print("Error decoding: \(error)")
            return T.init()
        }
    }
    
    //---------------------------------------------------------------
    // MARK: Helpers
    //---------------------------------------------------------------
    private static func toJson(_ dict:NSDictionary) -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    
}
