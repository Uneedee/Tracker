import UIKit

final class TrackersViewController: UIViewController {
    
    private let categoryStore: TrackerCategoryStore
    private let recordStore: TrackerRecordStore
    private let trackerStore: TrackerStore
    

    
    private var emptyStateImageView: UIImageView?
    private var emptyStateLabel: UILabel?
    var categories: [TrackerCategory] = []
    
    var completedTrackers: [TrackerRecord] {
        return recordStore.records
    }
    private let datePicker = UIDatePicker()
    private let searchBar = UISearchBar()
    private let trackersLabel = UILabel()
    var trackersCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let reuseIdentifierForCollectionViewCell = "collectionViewCellReuseIdentifier"
    var selectedDate: Date = Date()
     
    init(categoryStore: TrackerCategoryStore,
         recordStore: TrackerRecordStore,
         trackerStore: TrackerStore ) {
        self.categoryStore = categoryStore
        self.recordStore = recordStore
        self.trackerStore = trackerStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackerStore.delegate = self
        categoryStore.delegate = self
        recordStore.delegate = self
        setupView()
        
        trackersCollection.delegate = self
        trackersCollection.dataSource = self
        trackersCollection.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: self.reuseIdentifierForCollectionViewCell)
        trackersCollection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        loadCategories()
        checkingForTrackers()
    }
    
    private func setupView() {
        setupDatePicker()
        setupAddButton()
        setupAndShowGeneralLabelofTrackers()
        showSearchBar()
    }
    
    func checkingForTrackers() {
        let filtered = filteredCategories(for: selectedDate)
        
        if filtered.isEmpty {
            showEmptyStateView()
        } else {
            setupTrackersCollection()
        }
    }
    private func setupTrackersCollection() {
        emptyStateImageView?.removeFromSuperview()
        emptyStateLabel?.removeFromSuperview()
        emptyStateImageView = nil
        emptyStateLabel = nil
        
        if trackersCollection.superview == nil {
            view.addSubview(trackersCollection)
            trackersCollection.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                trackersCollection.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 24),
                trackersCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                trackersCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                trackersCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
            ])
        }
        
        trackersCollection.reloadData()
    }
    
    private func setupAndShowGeneralLabelofTrackers() {
        trackersLabel.text = "Трекеры"
        trackersLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        trackersLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackersLabel)
        
        NSLayoutConstraint.activate([
            trackersLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            trackersLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    
    private func filteredCategories(for date: Date) -> [TrackerCategory] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        let weekdayForEnum: Int
        if weekday == 1 {
            weekdayForEnum = 7
        } else {
            weekdayForEnum = weekday - 1
        }
        
        guard let targetWeekday = Weekdays(rawValue: weekdayForEnum) else {
            return []
        }
        
        return categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.schedule[targetWeekday] == true
            }
            
            if filteredTrackers.isEmpty {
                return nil
            }
            
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
    }
    
    private func showSearchBar() {
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        searchBar.placeholder = "Поиск"
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupAddButton() {
        let addButton = UIBarButtonItem(
            image: UIImage(named: "ButtonPlus"),
            style: .plain,
            target: self,
            action: #selector(addButtonTapped))
        addButton.tintColor = UIColor(named: "BlackColor")
        navigationItem.leftBarButtonItem = addButton
    }
    
    private func setupDatePicker() {
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    private func showEmptyStateView() {
        if trackersCollection.superview != nil {
            trackersCollection.removeFromSuperview()
        }
        
        emptyStateImageView?.removeFromSuperview()
        emptyStateLabel?.removeFromSuperview()
        
        let emptyStateView = UIImageView()
        let starImage = UIImage(named: "Star")
        emptyStateView.image = starImage
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)
        emptyStateImageView = emptyStateView
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        let trackersLabelIsEmpty = UILabel()
        trackersLabelIsEmpty.text = "Что будем отслеживать?"
        trackersLabelIsEmpty.font = .systemFont(ofSize: 12, weight: .medium)
        trackersLabelIsEmpty.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackersLabelIsEmpty)
        emptyStateLabel = trackersLabelIsEmpty
        
        NSLayoutConstraint.activate([
            trackersLabelIsEmpty.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trackersLabelIsEmpty.topAnchor.constraint(equalTo: emptyStateView.bottomAnchor, constant: 18)
        ])
    }
    
    @objc private func addButtonTapped() {
        let vc = CreateTrackerViewController()
        vc.trackerController = self
        vc.trackerStore = trackerStore
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .pageSheet
        navController.modalTransitionStyle = .coverVertical
        
        present(navController, animated: true)
    }
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        checkingForTrackers()
    }
    
    func addCompletedTracker(trackerID: UUID, date: Date) {
        do {
            try recordStore.addRecord(trackerId: trackerID, date: date)
        } catch {
            print("Ошибка добавления записи: \(error)")
        }
    }
    
    func removeCompletedTracker(trackerId: UUID, date: Date) {
        do {
            try recordStore.removeRecord(trackerId: trackerId, date: date)
        } catch {
            print("Ошибка удаления записи: \(error)")
        }
    }
    
    func loadCategories() {
        categories = categoryStore.categories
    }
    
}
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 167, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = collectionView.bounds.width > 0 ? collectionView.bounds.width : collectionView.frame.width
        return CGSize(width: width, height: 44)
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        filteredCategories(for: selectedDate).count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let filtered = filteredCategories(for: selectedDate)
        return filtered[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = trackersCollection.dequeueReusableCell(withReuseIdentifier: reuseIdentifierForCollectionViewCell, for: indexPath) as! CustomCollectionViewCell
        
        let filtered = filteredCategories(for: selectedDate)
        let currentCategory = filtered[indexPath.section]
        let currentTracker = currentCategory.trackers[indexPath.row]
        cell.tracker = currentTracker
        cell.trackerController = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SupplementaryView
        
        let filtered = filteredCategories(for: selectedDate)
        view.titleLabel.text = filtered[indexPath.section].title
        
        return view
    }
}

extension TrackersViewController: TrackerStoreDelegate {
    func storeDidUpdate(_ store: TrackerStore) {
        loadCategories()
        checkingForTrackers()
    }
}

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func storeDidUpdate(_ store: TrackerCategoryStore) {
        loadCategories()
        checkingForTrackers()
    }
}

extension TrackersViewController: TrackerRecordStoreDelegate {
    func storeDidUpdate(_ store: TrackerRecordStore) {
        trackersCollection.reloadData()
    }
}
