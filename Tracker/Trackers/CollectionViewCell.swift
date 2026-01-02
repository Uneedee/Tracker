import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    var trackerTitle = UILabel()
    var emoji = UILabel()
    var cardFrame = UIView()
    var buttonPlus = UIButton()
    var dayCounter = UILabel()
    weak var trackerController: TrackersViewController?
    var tracker: Tracker? {
        didSet {
            configureCell()
            updateDayCounter()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(cardFrame)
        cardFrame.addSubview(trackerTitle)
        cardFrame.addSubview(emoji)
        
        contentView.addSubview(buttonPlus)
        contentView.addSubview(dayCounter)
        buttonPlus.addTarget(self, action: #selector(dayCounterValueChanged) , for: .touchUpInside)
        
        cardFrame.backgroundColor = UIColor(named: "GreenColor")
        buttonPlus.setImage(UIImage(named: "ButtonPlusForCard"), for: .normal)
        
        dayCounter.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        dayCounter.textColor = UIColor(named: "BlackColor")
        trackerTitle.textColor = .white
        trackerTitle.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        trackerTitle.numberOfLines = 2
        trackerTitle.translatesAutoresizingMaskIntoConstraints = false
        emoji.translatesAutoresizingMaskIntoConstraints = false
        cardFrame.translatesAutoresizingMaskIntoConstraints = false
        buttonPlus.translatesAutoresizingMaskIntoConstraints = false
        dayCounter.translatesAutoresizingMaskIntoConstraints = false
        
        cardFrame.layer.cornerRadius = 16
        cardFrame.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            cardFrame.heightAnchor.constraint(equalToConstant: 90),
            cardFrame.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardFrame.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardFrame.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerTitle.leadingAnchor.constraint(equalTo: cardFrame.leadingAnchor, constant: 12),
            trackerTitle.trailingAnchor.constraint(equalTo: cardFrame.trailingAnchor, constant: 12),
            trackerTitle.bottomAnchor.constraint(equalTo: cardFrame.bottomAnchor, constant: -12),
            emoji.leadingAnchor.constraint(equalTo: cardFrame.leadingAnchor, constant: 12),
            emoji.topAnchor.constraint(equalTo: cardFrame.topAnchor, constant: 12),
            emoji.heightAnchor.constraint(equalToConstant: 24),
            emoji.widthAnchor.constraint(equalToConstant: 24)
        ])
        
        NSLayoutConstraint.activate([
            buttonPlus.widthAnchor.constraint(equalToConstant: 34),
            buttonPlus.heightAnchor.constraint(equalToConstant: 34),
            dayCounter.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            dayCounter.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            buttonPlus.centerYAnchor.constraint(equalTo: dayCounter.centerYAnchor),
            buttonPlus.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
    }
    func configureCell() {
        guard let tracker = tracker else { return }
        
        trackerTitle.text = tracker.title
        emoji.text = tracker.emoji ?? "😍"
    }
    @objc func dayCounterValueChanged() {
        guard let tracker = tracker,
              let controller = trackerController else { return }
        
        let selectedDate = controller.selectedDate
        let calendar = Calendar.current
        
        if selectedDate > Date() {
            return
        }
        
        let hasRecordForSelectedDate = controller.completedTrackers.contains { record in
            record.trackerId == tracker.id &&
            calendar.isDate(record.date, inSameDayAs: selectedDate)
        }
        
        if hasRecordForSelectedDate {
            controller.removeCompletedTracker(trackerId: tracker.id, date: selectedDate)
            buttonPlus.setImage(UIImage(named: "ButtonPlusForCard"), for: .normal)
        } else {
            controller.addCompletedTracker(trackerID: tracker.id, date: selectedDate)
            buttonPlus.setImage(UIImage(named: "ButtonForCard"), for: .normal)
        }
        
        updateDayCounter()
        controller.trackersCollection.reloadData()
    }
    
    func updateDayCounter() {
        guard let tracker = tracker,
              let controller = trackerController else {
            dayCounter.text = "0 дней"
            return
        }
        
        let recordsForTracker = controller.completedTrackers.filter { $0.trackerId == tracker.id }
        let calendar = Calendar.current
        let uniqueDates = Set(recordsForTracker.map { calendar.startOfDay(for: $0.date) })
        let count = uniqueDates.count
        
        let dayText = count == 1 ? "день" : (count >= 2 && count <= 4 ? "дня" : "дней")
        dayCounter.text = "\(count) \(dayText)"
        
        let selectedDate = controller.selectedDate
        let hasRecordForSelectedDate = recordsForTracker.contains { record in
            calendar.isDate(record.date, inSameDayAs: selectedDate)
        }
        
        if hasRecordForSelectedDate {
            buttonPlus.setImage(UIImage(named: "ButtonForCard"), for: .normal)
        } else {
            buttonPlus.setImage(UIImage(named: "ButtonPlusForCard"), for: .normal)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

