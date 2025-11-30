import UIKit

class TrackersViewController: UIViewController {
    

    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func addCompletedTracker(trackerID: UUID, date: Date){
        let record = TrackerRecord(trackerId: trackerID, date: date)
        completedTrackers.append(record)
    }
    
    func removeCompletedTracker(trackerId: UUID, date: Date) {
        completedTrackers.removeAll { completedTracker in
            completedTracker.trackerId == trackerId && Calendar.current.isDate(completedTracker.date, inSameDayAs: date)
        }
    }
    
    func addTracker(tracker: Tracker, categoryTitle: String) {
        
    }
}
