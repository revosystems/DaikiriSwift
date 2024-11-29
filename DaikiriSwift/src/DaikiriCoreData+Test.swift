import Foundation
import CoreData

/**
 Extension to be able to use an InMemory database so database won't afect the simulator one
 */
public extension DaikiriCoreData {
    func useTestDatabase(bundle:Bundle){
        testContext = buildTestContext(bundle)
    }
    
    //https://medium.com/joshtastic-blog/coredata-testing-263d55ce6553
    func buildTestContext(_ bundle:Bundle) -> NSManagedObjectContext? {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [bundle])
        guard let model = managedObjectModel else {
            assertionFailure("Failted to create ManagedObjectModel")
            return nil
        }
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            assertionFailure("Failed to add InMemory Persistent Store: \(error)")
            return nil
        }
        
        let concurrentType = NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: concurrentType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        return managedObjectContext
    }
}
