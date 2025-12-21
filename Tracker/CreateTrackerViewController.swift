import UIKit

final class CreateTrackerViewController: UIViewController {
    
    let textField = UITextField()
    let tableView = UITableView(frame: .zero, style: .plain)
    var trackerCategory: [String] = []
    var tableViewNewHabit: [String] = ["Категория","Расписание"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Новая привычка"
        configureNavigationBar()
        showTextField()
        setupTableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CreateTrackerTableViewCell.reuseIdentifier)
   
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
    
    func setupTableView() {
        
        let tableContainer = UIView()
//        tableContainer.backgroundColor = UIColor(named: "LightGrayColor")
        tableContainer.backgroundColor = .clear
        tableContainer.layer.cornerRadius = 16
        tableContainer.clipsToBounds = true
        tableContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableContainer)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        

        tableContainer.addSubview(tableView)


        NSLayoutConstraint.activate([
            tableContainer.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
               tableContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
               tableContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
               tableContainer.heightAnchor.constraint(equalToConstant: 150),

               tableView.topAnchor.constraint(equalTo: tableContainer.topAnchor),
               tableView.leadingAnchor.constraint(equalTo: tableContainer.leadingAnchor),
               tableView.trailingAnchor.constraint(equalTo: tableContainer.trailingAnchor),
               tableView.bottomAnchor.constraint(equalTo: tableContainer.bottomAnchor)
            
        ])

        
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
    
}

extension CreateTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CreateTrackerTableViewCell.reuseIdentifier, for: indexPath)
        cell.textLabel?.text = indexPath.row == 0 ? "Категория" : "Расписание"
        cell.backgroundColor = UIColor(named: "LightGrayColor")
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    
}

