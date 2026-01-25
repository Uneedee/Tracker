import CoreData
import UIKit

protocol TrackerCategoryStoreDelegate: AnyObject {
    func storeDidUpdate(_ store: TrackerCategoryStore)
}

final class TrackerCategoryStore: NSObject {
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    weak var delegate: TrackerCategoryStoreDelegate?
    
    var categories: [TrackerCategory] {
        guard let categoryObjects = fetchedResultsController.fetchedObjects else {
            return []
        }
        
        return categoryObjects.compactMap { categoryCoreData in
            guard let title = categoryCoreData.title,
                  let trackersSet = categoryCoreData.trackers as? Set<TrackerCoreData> else {
                return nil
            }
            
            let trackers = trackersSet.compactMap { trackerCoreData -> Tracker? in
                guard let id = trackerCoreData.id,
                      let trackerTitle = trackerCoreData.title else {
                    return nil
                }
                
                let color = trackerCoreData.color as? UIColor
                let emoji = trackerCoreData.emoji
                var schedule: [Weekdays: Bool] = [:]
                
                if let scheduleDict = trackerCoreData.schedule as? [Int: Bool] {
                    for (raw, isOn) in scheduleDict {
                        if let day = Weekdays(rawValue: raw) {
                            schedule[day] = isOn
                        }
                    }
                }
                
                return Tracker(
                    id: id,
                    title: trackerTitle,
                    color: color,
                    emoji: emoji,
                    schedule: schedule
                )
            }
            
            return TrackerCategory(title: title, trackers: trackers)
        }
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
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
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdate(self)
    }
}
