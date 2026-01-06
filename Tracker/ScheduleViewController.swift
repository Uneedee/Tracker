import UIKit

final class ScheduleViewController: UIViewController {
    
    let doneButton = UIButton()
    var scheduleTableView = UITableView(frame: .zero, style: .plain)
    static let scheduleCellReuseIdentifier = "scheduleCell"
    
    weak var parentTrackerVC: CreateTrackerViewController?
    
    var scheduleIsOn: [Weekdays: Bool] = {
        var dict: [Weekdays: Bool] = [:]
        for day in Weekdays.allCases {
            dict[day] = false
        }
        return dict
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Расписание"
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        scheduleTableView.register(UITableViewCell.self, forCellReuseIdentifier: ScheduleViewController.scheduleCellReuseIdentifier)
        setupDoneButton()
        setupTableView()
        
        scheduleTableView.tableHeaderView = UIView(frame: .zero)
        scheduleTableView.tableFooterView = UIView(frame: .zero)
    }
    
    func setupDoneButton() {
        doneButton.backgroundColor = UIColor(named: "BlackColor")
        doneButton.layer.cornerRadius = 16
        doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(saveSchedule), for: .touchUpInside)
        
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
    }
    
    @objc func saveSchedule() {
        parentTrackerVC?.savedSchedule = scheduleIsOn
        parentTrackerVC?.updateTableView()
        parentTrackerVC?.updateCreateButton()
        
        dismiss(animated: true)
    }
    
    func setupTableView() {
        let scheduleTableViewContainer = UIView()
        scheduleTableViewContainer.backgroundColor = .clear
        scheduleTableViewContainer.layer.cornerRadius = 16
        scheduleTableView.separatorStyle = .singleLine
        scheduleTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        scheduleTableViewContainer.clipsToBounds = true
        scheduleTableView.backgroundColor = .clear
        
        scheduleTableViewContainer.translatesAutoresizingMaskIntoConstraints = false
        scheduleTableView.translatesAutoresizingMaskIntoConstraints = false
        
        scheduleTableViewContainer.addSubview(scheduleTableView)
        view.addSubview(scheduleTableViewContainer)
        
        NSLayoutConstraint.activate([
            scheduleTableViewContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            scheduleTableViewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleTableViewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scheduleTableViewContainer.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -16),
            
            scheduleTableView.topAnchor.constraint(equalTo: scheduleTableViewContainer.topAnchor),
            scheduleTableView.leadingAnchor.constraint(equalTo: scheduleTableViewContainer.leadingAnchor),
            scheduleTableView.trailingAnchor.constraint(equalTo: scheduleTableViewContainer.trailingAnchor),
            scheduleTableView.bottomAnchor.constraint(equalTo: scheduleTableViewContainer.bottomAnchor)
        ])
    }
    
    @objc func switchValueChanged(sender: UISwitch) {
        let tag = sender.tag
        let weekday = Weekdays.allCases[tag]
        scheduleIsOn[weekday] = sender.isOn
    }
}
extension ScheduleViewController: UITableViewDelegate {
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Weekdays.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleViewController.scheduleCellReuseIdentifier, for: indexPath)
        cell.backgroundColor = UIColor(named: "LightGrayColor")
        let switcher = UISwitch()
        let weekday = Weekdays.allCases[indexPath.row]
        switcher.onTintColor = UIColor(named: "BlueColor")
        switcher.isOn = scheduleIsOn[weekday] ?? false
        switcher.tag = indexPath.row
        switcher.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        cell.accessoryView = switcher
        
        cell.textLabel?.text = weekday.localizedName
        
        if indexPath.row == 6 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.layer.cornerRadius = 16
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
