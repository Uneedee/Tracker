import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    
    let colorView = UIView()
    var innerBorderView: UIView?
    var outerBorderView: UIView?
    var isCellSelected: Bool = false {
        didSet {
            if isCellSelected {
                updateSelectedCell()
            } else {
                updateDeselectedCell()
            }
        }
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        innerBorderView = UIView()
        outerBorderView = UIView()
        
        guard let innerBorderView,
              let outerBorderView else { return }
        
        contentView.addSubview(outerBorderView)
        outerBorderView.addSubview(innerBorderView)
        innerBorderView.addSubview(colorView)

        colorView.layer.cornerRadius = 8
        colorView.layer.masksToBounds = true
        
        outerBorderView.translatesAutoresizingMaskIntoConstraints = false
        innerBorderView.translatesAutoresizingMaskIntoConstraints = false
        colorView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            outerBorderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            outerBorderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            outerBorderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            outerBorderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            innerBorderView.leadingAnchor.constraint(equalTo: outerBorderView.leadingAnchor, constant: 3),
            innerBorderView.trailingAnchor.constraint(equalTo: outerBorderView.trailingAnchor, constant: -3),
            innerBorderView.topAnchor.constraint(equalTo: outerBorderView.topAnchor, constant: 3),
            innerBorderView.bottomAnchor.constraint(equalTo: outerBorderView.bottomAnchor, constant: -3)
        ])
        
        
        NSLayoutConstraint.activate([
            colorView.leadingAnchor.constraint(equalTo: innerBorderView.leadingAnchor, constant: 3),
            colorView.trailingAnchor.constraint(equalTo: innerBorderView.trailingAnchor, constant: -3),
            colorView.topAnchor.constraint(equalTo: innerBorderView.topAnchor, constant: 3),
            colorView.bottomAnchor.constraint(equalTo: innerBorderView.bottomAnchor, constant: -3)
        ])
    }
    
    func updateSelectedCell() {
        innerBorderView?.isHidden = false
        outerBorderView?.isHidden = false

        outerBorderView?.layer.borderWidth = 3
        outerBorderView?.layer.borderColor = colorView.backgroundColor?.withAlphaComponent(0.3).cgColor ?? UIColor.lightGray.withAlphaComponent(0.3).cgColor
        outerBorderView?.layer.cornerRadius = 10
        outerBorderView?.layer.masksToBounds = true
        
        innerBorderView?.layer.borderWidth = 3
        innerBorderView?.layer.borderColor = UIColor.clear.cgColor
        innerBorderView?.layer.cornerRadius = 8
        innerBorderView?.layer.masksToBounds = true
 
    }
    
    func updateDeselectedCell() {
        outerBorderView?.layer.borderWidth = 0
        outerBorderView?.layer.borderColor = nil
        outerBorderView?.backgroundColor = .clear
        
        innerBorderView?.layer.borderWidth = 0
        innerBorderView?.layer.borderColor = nil
        innerBorderView?.backgroundColor = .clear
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

