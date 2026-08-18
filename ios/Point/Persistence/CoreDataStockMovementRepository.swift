import CoreData
import Foundation

final class CoreDataStockMovementRepository: StockMovementRepository {
    private let stack: CoreDataStack

    init(stack: CoreDataStack) {
        self.stack = stack
    }

    func fetchAll() -> [StockMovement] {
        let request = StockMovementEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let results = (try? stack.viewContext.fetch(request)) ?? []
        return results.map { $0.toDomain() }
    }

    func fetchAll(itemID: UUID) -> [StockMovement] {
        let request = StockMovementEntity.fetchRequest()
        request.predicate = NSPredicate(format: "itemID == %@", itemID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let results = (try? stack.viewContext.fetch(request)) ?? []
        return results.map { $0.toDomain() }
    }

    func save(_ movement: StockMovement) throws {
        let request = StockMovementEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", movement.id as CVarArg)
        let entity = try stack.viewContext.fetch(request).first ?? StockMovementEntity(context: stack.viewContext)
        entity.update(from: movement)
        try stack.save()
    }

    func delete(id: UUID) throws {
        let request = StockMovementEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let entity = try stack.viewContext.fetch(request).first {
            stack.viewContext.delete(entity)
            try stack.save()
        }
    }
}
