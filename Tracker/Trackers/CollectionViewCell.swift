import UIKit

final class CustomCollectionViewCell: UICollectionViewCell {
    
    private var trackerTitle = UILabel()
    private var emojiFrame = UIView()
    private var emoji = UILabel()
    private var cardFrame = UIView()
    private var buttonPlus = UIButton()
    private var dayCounter = UILabel()
    private var color: UIColor?
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
        cardFrame.addSubview(emojiFrame)
        emojiFrame.addSubview(emoji)
        contentView.addSubview(buttonPlus)
        contentView.addSubview(dayCounter)
        
        buttonPlus.addTarget(self, action: #selector(dayCounterValueChanged) , for: .touchUpInside)
        buttonPlus.layer.cornerRadius = 17
        buttonPlus.layer.masksToBounds = true
        let image = UIImage(
            systemName: "plus",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        )
        buttonPlus.setImage(image, for: .normal)
        buttonPlus.tintColor = .white
        
        dayCounter.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        dayCounter.textColor = UIColor(named: "BlackColor")
        trackerTitle.textColor = .white
        trackerTitle.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        trackerTitle.numberOfLines = 2
        emojiFrame.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        emojiFrame.layer.cornerRadius = 12
        emojiFrame.layer.masksToBounds = true
        emoji.font = .systemFont(ofSize: 16, weight: .medium)
        trackerTitle.translatesAutoresizingMaskIntoConstraints = false
        emoji.translatesAutoresizingMaskIntoConstraints = false
        emojiFrame.translatesAutoresizingMaskIntoConstraints = false
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

        ])
        
        NSLayoutConstraint.activate([
            emojiFrame.leadingAnchor.constraint(equalTo: cardFrame.leadingAnchor, constant: 12),
            emojiFrame.topAnchor.constraint(equalTo: cardFrame.topAnchor, constant: 12),
            emojiFrame.heightAnchor.constraint(equalToConstant: 24),
            emojiFrame.widthAnchor.constraint(equalToConstant: 24),
            emoji.centerXAnchor.constraint(equalTo: emojiFrame.centerXAnchor),
            emoji.centerYAnchor.constraint(equalTo: emojiFrame.centerYAnchor)
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
        cardFrame.backgroundColor = tracker.color
        buttonPlus.backgroundColor = tracker.color
        
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
            let image = UIImage(
                systemName: "plus",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
            )
            controller.removeCompletedTracker(trackerId: tracker.id, date: selectedDate)
            buttonPlus.setImage(image, for: .normal)
            buttonPlus.tintColor = .white

        } else {
            let image = UIImage(
                systemName: "checkmark",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
            )
            controller.addCompletedTracker(trackerID: tracker.id, date: selectedDate)
            buttonPlus.setImage(image, for: .normal)
            buttonPlus.tintColor = .white
            buttonPlus.backgroundColor = tracker.color?.withAlphaComponent(0.3)
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
            let image = UIImage(
                systemName: "checkmark",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
            )
            buttonPlus.setImage(image, for: .normal)
            buttonPlus.tintColor = .white
            buttonPlus.backgroundColor = tracker.color?.withAlphaComponent(0.3)
        } else {
            let image = UIImage(
                systemName: "plus",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
            )
            buttonPlus.setImage(image, for: .normal)
            buttonPlus.tintColor = .white
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

