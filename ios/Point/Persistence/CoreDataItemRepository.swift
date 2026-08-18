import CoreData
import Foundation

final class CoreDataItemRepository: ItemRepository {
    private let stack: CoreDataStack

    init(stack: CoreDataStack) {
        self.stack = stack
    }

    func fetchAll() -> [Item] {
        let request = ItemEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        let results = (try? stack.viewContext.fetch(request)) ?? []
        return results.map { $0.toDomain() }
    }

    @discardableResult
    func create(_ item: Item) throws -> Item {
        var item = item
        item = Item(
            id: item.id,
            code: nextCode(),
            name: item.name,
            itemDescription: item.itemDescription,
            imageData: item.imageData,
            sellPrice: item.sellPrice,
            variants: item.variants,
            createdAt: item.createdAt
        )
        let entity = ItemEntity(context: stack.viewContext)
        entity.update(from: item)
        try stack.save()
        return item
    }

    func update(_ item: Item) throws {
        let request = ItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
        guard let entity = try stack.viewContext.fetch(request).first else { return }
        entity.update(from: item)
        try stack.save()
    }

    func delete(id: UUID) throws {
        let request = ItemEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let entity = try stack.viewContext.fetch(request).first {
            stack.viewContext.delete(entity)
            try stack.save()
        }
    }

    /// Sequential "ITM-0001" style code derived from how many items already
    /// exist. Not reused after a delete (Core Data row count only ever
    /// grows the counter via `fetchAll().count`, it doesn't reclaim gaps) —
    /// codes stay stable and unique for the life of the store.
    private func nextCode() -> String {
        let count = (try? stack.viewContext.count(for: ItemEntity.fetchRequest())) ?? 0
        return String(format: "ITM-%04d", count + 1)
    }
}
