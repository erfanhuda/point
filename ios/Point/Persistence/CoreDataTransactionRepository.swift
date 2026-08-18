import CoreData
import Foundation

final class CoreDataTransactionRepository: TransactionRepository {
    private let stack: CoreDataStack

    init(stack: CoreDataStack) {
        self.stack = stack
    }

    func fetchAll() -> [Transaction] {
        let request = TransactionEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let results = (try? stack.viewContext.fetch(request)) ?? []
        return results.map { $0.toDomain() }
    }

    func save(_ transaction: Transaction) throws {
        let request = TransactionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)
        let entity = try stack.viewContext.fetch(request).first ?? TransactionEntity(context: stack.viewContext)
        entity.update(from: transaction)
        try stack.save()
    }

    func delete(id: UUID) throws {
        let request = TransactionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let entity = try stack.viewContext.fetch(request).first {
            stack.viewContext.delete(entity)
            try stack.save()
        }
    }
}
