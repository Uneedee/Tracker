import UIKit

final class CreateTrackerViewController: UIViewController {
    
    let textField = UITextField()
    let tableView = UITableView(frame: .zero, style: .plain)
//    var trackerCategory: [TrackerCategory] = []
//    var trackers = [Tracker]()
    static let cellIdentifier = "cell"
    let buttonCancel = UIButton()
    let buttonCreate = UIButton()
    let characterLimitLabel = UILabel()
    var constraintToTextField: NSLayoutConstraint?
    var constraintToLabelLimit: NSLayoutConstraint?
    var savedText: String?
    public var savedSchedule: [Weekdays: Bool] = [:]
    var tracker: Tracker?
    weak var trackerController: TrackersViewController?
  
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Новая привычка"
        textField.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        configureNavigationBar()
        showTextField()
        setupCharacterLimit()
        setupTableView()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CreateTrackerViewController.cellIdentifier)
        setupCreateButton()
        setupCancelButton()
        characterLimitLabel.isHidden = true
 

   
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
        
        view.addSubview(characterLimitLabel)
        
        characterLimitLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            characterLimitLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            characterLimitLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8)
        ])
    }
    
    func updateCreateButton() {
        // Проверяем, что текст не пуст и в расписании есть хотя бы один выбранный день
        let isScheduleNotEmpty = savedSchedule.contains { $0.value == true }
        // Проверка на хотя бы один активный день в расписании
        let isTextNotEmpty = !(textField.text?.isEmpty ?? true)
        
        if isTextNotEmpty && isScheduleNotEmpty {
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
        
        view.addSubview(buttonCreate)
        
        buttonCreate.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonCreate.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonCreate.widthAnchor.constraint(equalToConstant: 161),
            buttonCreate.heightAnchor.constraint(equalToConstant: 60),
            buttonCreate.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
            
        ])
        
    }
    
    @objc private func createButtonTapped() {
        
        print("Нопка нажата")
        
        saveNewTracker()

    }
    
    func saveNewTracker() {
        print(savedText ?? "Теста точно нет")
        guard let text = savedText else {
            print("Ошибка. Текст отсутствует")
            return }
        
        tracker = Tracker(id: UUID(),
                          title: text,
                          color: nil,
                          emoji: nil,
                          schedule: savedSchedule)
        trackerController?.tracker = tracker
        
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
        
        view.addSubview(buttonCancel)
        
        buttonCancel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonCancel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonCancel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            buttonCancel.trailingAnchor.constraint(equalTo: buttonCreate.leadingAnchor, constant: -8),
            buttonCancel.heightAnchor.constraint(equalToConstant: 60)
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
        
        let tableContainer = UIView()
//        tableContainer.backgroundColor = UIColor(named: "LightGrayColor")
        tableContainer.backgroundColor = .clear
        tableContainer.layer.cornerRadius = 16
        tableContainer.clipsToBounds = true
        tableContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableContainer)
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
            tableContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
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
        }
        else {
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

        
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
//            textField.widthAnchor.constraint(equalToConstant: 343),
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
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
//        savedText = textField.text
//        updateCreateButton()
        
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

