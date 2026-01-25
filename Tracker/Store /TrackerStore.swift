import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    func storeDidUpdate(_ store: TrackerStore)
}


final class TrackerStore: NSObject {
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController <TrackerCoreData>!
    weak var delegate: TrackerStoreDelegate?
    var trackers: [Tracker] {
        let object = fetchedResultsController.fetchedObjects ?? []
        return object.compactMap { makeTracker(from: $0) }
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
        
    }
    
    func makeTracker(from coreData: TrackerCoreData) -> Tracker? {
        
        guard let id = coreData.id,
              let title = coreData.title else { return nil }
        
        let color = coreData.color as? UIColor
        let emoji = coreData.emoji
        var schedule: [Weekdays: Bool] = [:]
        
        let store = coreData.schedule as? [Int: Bool] ?? [:]

        for (raw, isOn) in store {
            if let day = Weekdays(rawValue: raw) {
                schedule[day] = isOn
            }
        }
        let tracker = Tracker(id: id,
                              title: title,
                              color: color,
                              emoji: emoji,
                              schedule: schedule)
        
        return tracker
    }
    
    func makeOrUpdateCoreData(from tracker: Tracker, in context: NSManagedObjectContext) -> TrackerCoreData {
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        let existingObject = try? context.fetch(fetchRequest)
        let coreData: TrackerCoreData
        
        if let existing = existingObject?.first {
            coreData = existing
        } else {
            coreData = TrackerCoreData(context: context)
        }
        
        coreData.id = tracker.id
        coreData.title = tracker.title
        coreData.emoji = tracker.emoji
        coreData.color = tracker.color
        
        var storedSchedule: [Int: Bool] = [:]
        
        for (weekday, isOn) in tracker.schedule {
            storedSchedule[weekday.rawValue] = isOn
        }
        coreData.schedule = storedSchedule as NSDictionary
        return coreData
    }
    
    func createTracker(tracker: Tracker, categoryTitle: String) throws {
        let coreData = makeOrUpdateCoreData(from: tracker, in: context)
        
        let categoryFetchRequest = TrackerCategoryCoreData.fetchRequest()
        categoryFetchRequest.predicate = NSPredicate(format: "title == %@", categoryTitle)
        categoryFetchRequest.fetchLimit = 1
        let categories = try context.fetch(categoryFetchRequest)
        let category: TrackerCategoryCoreData
        
        if let existing = categories.first {
            category = existing } else {
                category = TrackerCategoryCoreData(context: context)
                category.title = categoryTitle
        }
        
        coreData.category = category
        
        try context.save()
    }
    
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdate(self)
    }
}
