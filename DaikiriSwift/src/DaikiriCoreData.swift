import Foundation
import CoreData


// https://github.com/3lvis/Sync/blob/6723c1f9a07014024e0f8f2923d1930789cabb72/Source/DataStack/DataStack.swift#L77-L196
public class DaikiriCoreData {
    
    public static var manager:DaikiriCoreData = DaikiriCoreData()
    
    /** See DaikiriCoreData+Test*/
    var testContext:NSManagedObjectContext? = nil
    
    let name:String?
    
    init(name:String? = nil){
        self.name = name
    }
    
    public var context:NSManagedObjectContext {
        testContext ?? persistentContainer.viewContext
    }
    
    var undoManager:UndoManager{
        if context.undoManager == nil {
            context.undoManager = UndoManager()
        }
        return context.undoManager!
    }
    
    var containerName: String{
        name ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
    }
    
    public lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
           storeDescription.shouldMigrateStoreAutomatically      = true
           //storeDescription.shouldInferMappingModelAutomatically = true
           if let error = error as NSError? {
               fatalError("Unresolved error \(error), \(error.userInfo)")
           }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    public func saveContext () {
       if context.hasChanges {
           do {
               try context.save()
           } catch {
               let nserror = error as NSError
               fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
           }
       }
   }
    
    public func clearDatabase(){
       // It leaves it not recoverable
       let coordinator = persistentContainer.persistentStoreCoordinator
        for store in coordinator.persistentStores where store.url != nil {
            try? coordinator.remove(store)
            try? FileManager.default.removeItem(atPath: store.url!.path)
        }
    }
    
    public func whereIsTheDatabase(){
        print("DatabaseDirectory: ", NSPersistentContainer.defaultDirectoryURL())
    }
    
    public func showEntities(){
        //let objectModel = context.persistentStoreCoordinator?.managedObjectModel
        //let entities    = objectModel?.entitiesByName
        //print (entities ?? "No Entities")
    }
    
    public func truncate( _ entityName:String){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        // perform the delete
        do {
            try context.execute(deleteRequest)
            saveContext()
        } catch let error as NSError {
            print(error)
        }
    }
    
    // MARK: - Transactions
    public func beginTransaction(){
        undoManager.beginUndoGrouping()
    }
    
    public func commit(){
        undoManager.endUndoGrouping()
        undoManager.removeAllActions()
    }
    
    public func rollback(){
        undoManager.endUndoGrouping()
        undoManager.undo()
    }

    public func transaction(callback:() throws -> Void ){
        beginTransaction()
        do {
            try callback()
        } catch {
            rollback()
        commit()
        }
    }
}


