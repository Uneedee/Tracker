import UIKit

final class LaunchScreenViewController: UIViewController {
    
    var logoImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showLaunchScreen()
    }
    
    func showLaunchScreen() {
        
        view.backgroundColor = UIColor(named: "blueColor")
        let logoImage = UIImage(named: "Logo")
        logoImageView = UIImageView(image: logoImage)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 91),
            logoImageView.heightAnchor.constraint(equalToConstant: 94),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)

        ])

        
        
        
    }
    
}
