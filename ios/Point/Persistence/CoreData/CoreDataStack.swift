import CoreData

/// Owns the persistent container. `inMemory` is used by tests so each test
/// gets an isolated, disposable store.
final class CoreDataStack {
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Point", managedObjectModel: CoreDataModel.shared)

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load Core Data store: \(error)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    var viewContext: NSManagedObjectContext { container.viewContext }

    func save() throws {
        guard viewContext.hasChanges else { return }
        try viewContext.save()
    }
}
