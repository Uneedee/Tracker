import UIKit

final class CreateTrackerViewController: UIViewController {
    
    private let textField = UITextField()
    private let tableView = UITableView(frame: .zero, style: .plain)
    static let cellIdentifier = "cell"
    let buttonCancel = UIButton()
    let buttonCreate = UIButton()
    let characterLimitLabel = UILabel()
    let tableContainer = UIView()
    var constraintToTextField: NSLayoutConstraint?
    var constraintToLabelLimit: NSLayoutConstraint?
    var savedText: String?
    var selectedEmoji: String?
    var selectedColor: UIColor?
    var scrollView = UIScrollView()
    public var savedSchedule: [Weekdays: Bool] = [:]
    var selectedEmojiIndex: Int? // для отслеживания выбранной emoji ячейки
    var selectedColorIndex: Int? // для отслеживания выбранной color ячейки

    let emojis = [
        "😊", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🌴", "😴"
    ]
    let colors: [UIColor] = [
        UIColor(named: "Color 1") ?? .clear,
        UIColor(named: "Color 2") ?? .clear,
        UIColor(named: "Color 3") ?? .clear,
        UIColor(named: "Color 4") ?? .clear,
        UIColor(named: "Color 5") ?? .clear,
        UIColor(named: "Color 6") ?? .clear,
        UIColor(named: "Color 7") ?? .clear,
        UIColor(named: "Color 8") ?? .clear,
        UIColor(named: "Color 9") ?? .clear,
        UIColor(named: "Color 10") ?? .clear,
        UIColor(named: "Color 11") ?? .clear,
        UIColor(named: "Color 12") ?? .clear,
        UIColor(named: "Color 13") ?? .clear,
        UIColor(named: "Color 14") ?? .clear,
        UIColor(named: "Color 15") ?? .clear,
        UIColor(named: "Color 16") ?? .clear,
        UIColor(named: "Color 17") ?? .clear,
        UIColor(named: "Color 18") ?? .clear,
        
    ]
    let reuseIdentifierForEmojiCell = "emojiCollectionViewCellReuseIdentifier"
    let reuseIdentifierForColorCell = "colorCollectionViewCellReuseIdentifier"
    let reuseIdentifierForEmojiHeader = "emojiCollectionViewHeader"
    let reuseIdentifierForColorHeader = "colorCollectionViewHeader"
    weak var trackerController: TrackersViewController?
    var colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var emojiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Новая привычка"
        textField.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        configureNavigationBar()
        setupScrollView()
        showTextField()
        setupCharacterLimit()
        setupTableView()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CreateTrackerViewController.cellIdentifier)
        emojiCollectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifierForEmojiCell)
        emojiCollectionView.register(CreateTrackerSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader , withReuseIdentifier: reuseIdentifierForEmojiHeader)
        emojiCollectionView.register(CreateTrackerSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reuseIdentifierForColorHeader)
        emojiCollectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifierForColorCell)
        setupEmojiCollectionView()
        setupCreateButton()
        setupCancelButton()
        characterLimitLabel.isHidden = true
    }
    
    func setupScrollView() {
        
        view.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    
    func configureNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
    }
    
    func setupCharacterLimit() {
        characterLimitLabel.text = "Ограничение 38 символов"
        characterLimitLabel.textColor = UIColor(named: "RedColor")
        characterLimitLabel.font = .systemFont(ofSize: 17, weight: .regular)
        
        scrollView.addSubview(characterLimitLabel)
        
        characterLimitLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            characterLimitLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            characterLimitLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8)
        ])
    }
    
    func updateCreateButton() {
        let isScheduleNotEmpty = savedSchedule.contains { $0.value == true }
        let isTextNotEmpty = !(textField.text?.isEmpty ?? true)
        let isEmojiNotEmpty = selectedEmoji != nil
        let isColorNotEmpty = selectedColor != nil
        
        
        if isTextNotEmpty && isScheduleNotEmpty && isEmojiNotEmpty && isColorNotEmpty {
            buttonCreate.backgroundColor = UIColor(named: "BlackColor")
            buttonCreate.isEnabled = true
        } else {
            buttonCreate.backgroundColor = UIColor(named: "GrayColorForButton")
            buttonCreate.isEnabled = false
        }
    }
    
    func setupCreateButton() {
        guard let grayColor = UIColor(named: "GrayColorForButton") else { return }
        buttonCreate.backgroundColor = grayColor
        buttonCreate.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        buttonCreate.setTitle("Создать", for: .normal)
        buttonCreate.layer.cornerRadius = 16
        buttonCreate.isEnabled = false
        
        buttonCreate.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        scrollView.addSubview(buttonCreate)
        buttonCreate.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonCreate.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            buttonCreate.widthAnchor.constraint(equalToConstant: 161),
            buttonCreate.heightAnchor.constraint(equalToConstant: 60),
            buttonCreate.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            buttonCreate.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func createButtonTapped() {
        saveNewTracker()
    }
    
    func saveNewTracker() {
        guard let text = savedText else {
            return
        }
        
        let newTracker = Tracker(id: UUID(),
                                 title: text,
                                 color: selectedColor,
                                 emoji: selectedEmoji,
                                 schedule: savedSchedule)
        
        let categoryTitle = "Важное"
        guard let trackerController = trackerController,
              let categoryIndex = trackerController.categories.firstIndex(where: { $0.title == categoryTitle }) else { return }
        let existingCategory = trackerController.categories[categoryIndex]
        let updatedCategory = TrackerCategory(title: categoryTitle,
                                              trackers: existingCategory.trackers + [newTracker])
        var newCategory = trackerController.categories
        newCategory[categoryIndex] = updatedCategory
        
        trackerController.categories = newCategory
        trackerController.checkingForTrackers()
        dismiss(animated: true)
    }
    func setupCancelButton() {
        guard let redColor = UIColor(named: "RedColor") else {
            return
        }
        buttonCancel.layer.borderColor = redColor.cgColor
        buttonCancel.layer.cornerRadius = 16
        buttonCancel.layer.borderWidth = 1
        buttonCancel.clipsToBounds = true
        buttonCancel.setTitleColor(redColor, for: .normal)
        buttonCancel.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        buttonCancel.setTitle("Отменить", for: .normal)
        buttonCancel.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        scrollView.addSubview(buttonCancel)
        buttonCancel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonCancel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            buttonCancel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            buttonCancel.trailingAnchor.constraint(equalTo: buttonCreate.leadingAnchor, constant: -8),
            buttonCancel.heightAnchor.constraint(equalToConstant: 60),
            buttonCancel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16)
        ])
    }
    
    @objc func dismissView() {
        dismiss(animated: true)
    }
    
    func updateTableView() {
        let indexPath = IndexPath(row: 1, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) {
            let activeDays = savedSchedule.filter { $0.value }.map { $0.key.shortName}
            cell.detailTextLabel?.text = activeDays.joined(separator: ", ")
        }
    }
    
    func setupTableView() {

        tableContainer.backgroundColor = .clear
        tableContainer.layer.cornerRadius = 16
        tableContainer.clipsToBounds = true
        tableContainer.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(tableContainer)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        tableContainer.addSubview(tableView)
        
        self.constraintToTextField = tableContainer.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24)
        constraintToTextField!.priority = .required
        
        self.constraintToLabelLimit = tableContainer.topAnchor.constraint(equalTo: characterLimitLabel.bottomAnchor, constant: 24)
        constraintToLabelLimit!.priority = .defaultLow
        
        NSLayoutConstraint.activate([
            constraintToTextField!,
            constraintToLabelLimit!,
            tableContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            tableContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            tableContainer.heightAnchor.constraint(equalToConstant: 150),
            tableView.topAnchor.constraint(equalTo: tableContainer.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: tableContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableContainer.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: tableContainer.bottomAnchor)
        ])
    }
    
    func updateConstraint() {
        if characterLimitLabel.isHidden {
            constraintToTextField?.priority = .required
            constraintToLabelLimit?.priority = .defaultLow
        } else {
            constraintToTextField?.priority = .defaultLow
            constraintToLabelLimit?.priority = .required
        }
    }
    
    func showTextField() {
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = UIColor(named: "LightGrayColor")
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.borderStyle = .none
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 41, height: 0))
        textField.rightViewMode = .always
        
        scrollView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            textField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16)
        ])
    }
    
    func presentSchedule() {
        let vc = ScheduleViewController()
        vc.parentTrackerVC = self
        vc.scheduleIsOn = self.savedSchedule
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    func setupEmojiCollectionView() {
        
        let emojiCollectionViewFlowLayout = UICollectionViewFlowLayout()
        emojiCollectionViewFlowLayout.itemSize = CGSize(width: 52, height: 52)
        emojiCollectionViewFlowLayout.minimumLineSpacing = 0
        emojiCollectionViewFlowLayout.minimumInteritemSpacing = 5
        emojiCollectionView.collectionViewLayout = emojiCollectionViewFlowLayout
        emojiCollectionViewFlowLayout.collectionView?.isScrollEnabled = false
        
        scrollView.addSubview(emojiCollectionView)
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Вычисление высоты
        let screenWidth = UIScreen.main.bounds.width
        let availableWidth = screenWidth - 36 // insets left + right
        let itemWidth: CGFloat = 52
        let spacing: CGFloat = 5
        let columns = floor((availableWidth + spacing) / (itemWidth + spacing))
        let itemsPerSection = emojis.count
        let rowsPerSection = ceil(CGFloat(itemsPerSection) / columns)
        let headerHeight: CGFloat = 18
        let topInset: CGFloat = 24
        let bottomInset: CGFloat = 24
        let sectionHeight = topInset + headerHeight + (rowsPerSection * itemWidth) + bottomInset
        let numberOfSections = 2
        let totalHeight = sectionHeight * CGFloat(numberOfSections)

        NSLayoutConstraint.activate([
            emojiCollectionView.topAnchor.constraint(equalTo: tableContainer.bottomAnchor, constant: 50),
            emojiCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            // Тут поправить логику. Режет нижний отступ и контент. После добавления 2й секции можно указать contentSize
//            emojiCollectionView.bottomAnchor.constraint(equalTo: buttonCancel.topAnchor, constant: -10)
            emojiCollectionView.heightAnchor.constraint(equalToConstant: totalHeight)
        ])
        
        
    }
    
}

extension CreateTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: CreateTrackerViewController.cellIdentifier)
        cell.textLabel?.text = indexPath.row == 0 ? "Категория" : "Расписание"
        cell.backgroundColor = UIColor(named: "LightGrayColor")
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = UIColor(named: "BlackColor")
        cell.accessoryType = .disclosureIndicator
        
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = "Важное"
        }
        
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.textColor = UIColor(named: "GrayColorForButton")
        
        if indexPath.row == 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard presentedViewController == nil else { return }
        if indexPath.row == 1 {
            presentSchedule()
        }
    }

}

extension CreateTrackerViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let curentText = textField.text ?? ""
        let updateText = (curentText as NSString).replacingCharacters(in: range, with: string)
        let charactersCount = updateText.count
        
        if charactersCount > 38 {
            characterLimitLabel.isHidden = false
            updateConstraint()
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
            return false
        } else {
            characterLimitLabel.isHidden = true
        }
        
        updateConstraint()
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        savedText = text
        updateCreateButton()
    }
}

extension CreateTrackerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return emojis.count
        } else {
            return colors.count
        }
  
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
        let emojiCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierForEmojiCell, for: indexPath) as! EmojiCollectionViewCell
        emojiCell.emojiLabel?.text = emojis[indexPath.item]
            emojiCell.isCellSelected = (selectedEmojiIndex == indexPath.item)
        
        return emojiCell
        } else {
            let colorCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierForColorCell, for: indexPath) as! ColorCollectionViewCell
            colorCell.colorView.backgroundColor = colors[indexPath.item]
            colorCell.isCellSelected = (selectedColorIndex == indexPath.item)
            return colorCell
        }
        
        
    }
    
}

extension CreateTrackerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if indexPath.section == 0 {
        let emojiHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifierForEmojiHeader, for: indexPath) as! CreateTrackerSupplementaryView
        
            emojiHeader.titleLabel.text = "Emoji"
        
        return emojiHeader
        } else {
            let colorHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifierForColorHeader, for: indexPath) as! CreateTrackerSupplementaryView
            
            colorHeader.titleLabel.text = "Color"
            
            return colorHeader
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedEmoji = emojis[indexPath.item]
            selectedEmojiIndex = indexPath.item
            collectionView.reloadData()
        } else {
            selectedColor = colors[indexPath.item]
            selectedColorIndex = indexPath.item
            collectionView.reloadData()
            
        }
        updateCreateButton()
    }
    
}

