import UIKit

class TrackersViewController: UIViewController {
    

    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    let datePicker = UIDatePicker()
    let searchBar = UISearchBar()
    let trackersLabel = UILabel()
    var tracker: Tracker?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatePicker()
        setupAddButton()
        setupAndShowGeneralLabelofTrackers()
        showSearchBar()
        if categories .isEmpty {
            showEmptyStateView()
        }
    }
    
    func setupAndShowGeneralLabelofTrackers() {
        trackersLabel.text = "Трекеры"
        trackersLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        trackersLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackersLabel)
        
        NSLayoutConstraint.activate([
            trackersLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            trackersLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
        
    }
    
    
    func showSearchBar() {
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    func setupAddButton() {
        let addButton = UIBarButtonItem(
            image: UIImage(named: "ButtonPlus"),
            style: .plain,
            target: self,
            action: #selector(addButtonTapped))
        addButton.tintColor = UIColor(named: "BlackColor")
        navigationItem.leftBarButtonItem = addButton
    }
    
    func setupDatePicker() {
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    
    func showEmptyStateView() {
        // Показываем изображение
        let emptyStateView = UIImageView()
        let starImage = UIImage(named: "Star")
        emptyStateView.image = starImage
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Показываем заголовок
        let trackersLabelIsEmpty = UILabel()
        trackersLabelIsEmpty.text = "Что будем отслеживать?"
        trackersLabelIsEmpty.font = .systemFont(ofSize: 12, weight: .medium)
        trackersLabelIsEmpty.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackersLabelIsEmpty)
        
        NSLayoutConstraint.activate([
            trackersLabelIsEmpty.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trackersLabelIsEmpty.topAnchor.constraint(equalTo: emptyStateView.bottomAnchor, constant: 18)

        ])

    }
    
    func updateEmptyState() {
        
    }
    
    @objc func addButtonTapped() {
        let vc = CreateTrackerViewController()
        vc.trackerController = self
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .pageSheet
        navController.modalTransitionStyle = .coverVertical
        
        present(navController, animated: true)
        
    }
    


    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        filterTrackersByDate(selectedDate)
    }

    // Метод для фильтрации трекеров (пример)
    func filterTrackersByDate(_ date: Date) {
//        let calendar = Calendar.current
//        let weekday = calendar.component(.weekday, from: date)
        
        // Преобразуем weekday в ваш enum Weekdays
        // И фильтруете трекеры, которые должны отображаться в этот день
        // Это пример - вам нужно будет адаптировать под вашу логику
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
