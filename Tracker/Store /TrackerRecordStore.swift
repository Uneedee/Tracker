import CoreData
import UIKit

protocol TrackerRecordStoreDelegate: AnyObject {
    func storeDidUpdate(_ store: TrackerRecordStore)
}

final class TrackerRecordStore: NSObject {
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
    weak var delegate: TrackerRecordStoreDelegate?
    
    var records: [TrackerRecord] {
        guard let recordObjects = fetchedResultsController.fetchedObjects else {
            return []
        }
        
        return recordObjects.compactMap { recordCoreData in
            guard let trackerId = recordCoreData.tracker?.id,
                  let date = recordCoreData.date else {
                return nil
            }
            
            return TrackerRecord(trackerId: trackerId, date: date)
        }
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
    }
    
    func addRecord(trackerId: UUID, date: Date) throws {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        fetchRequest.fetchLimit = 1
        
        guard let tracker = try context.fetch(fetchRequest).first else {
            throw NSError(domain: "TrackerRecordStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Трекер не найден"])
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let recordFetchRequest = TrackerRecordCoreData.fetchRequest()
        recordFetchRequest.predicate = NSPredicate(
            format: "tracker.id == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        
        let existingRecords = try context.fetch(recordFetchRequest)
        if existingRecords.isEmpty {
            let record = TrackerRecordCoreData(context: context)
            record.id = UUID()
            record.date = date
            record.tracker = tracker
            
            try context.save()
        }
    }
    
    func removeRecord(trackerId: UUID, date: Date) throws {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "tracker.id == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        
        let records = try context.fetch(fetchRequest)
        for record in records {
            context.delete(record)
        }
        
        try context.save()
    }
    
    func getRecords(for trackerId: UUID) -> [TrackerRecord] {
        return records.filter { $0.trackerId == trackerId }
    }
    
    func hasRecord(trackerId: UUID, date: Date) -> Bool {
        let calendar = Calendar.current
        return records.contains { record in
            record.trackerId == trackerId &&
            calendar.isDate(record.date, inSameDayAs: date)
        }
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdate(self)
    }
}
