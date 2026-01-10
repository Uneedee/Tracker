import UIKit

class EmojiCollectionViewCell: UICollectionViewCell {
    
    var emojiLabel: UILabel?
    var colorBorder: UIView?
    var isCellSelected: Bool = false {
        didSet {
            if isCellSelected == false {
                updateDeselectedCell()
            } else {
                updateSelectedCell()
            }
        }
    }
    
    func updateSelectedCell() {
        
        colorBorder?.backgroundColor = .lightGray.withAlphaComponent(0.3)
        colorBorder?.layer.cornerRadius = 8
        colorBorder?.layer.masksToBounds = true
    }
    
    func updateDeselectedCell() {
        colorBorder?.backgroundColor = .clear
        colorBorder?.layer.cornerRadius = 0
        colorBorder?.layer.masksToBounds = false
    }
    
    override init(frame: CGRect) {
        
        colorBorder = UIView()

        emojiLabel = UILabel()
        emojiLabel?.textAlignment = .center
        emojiLabel?.font = .systemFont(ofSize: 30)
        super.init(frame: frame)
        
        guard let emojiLabel else { return }
        guard let colorBorder else { return }
        
        contentView.addSubview(colorBorder)
        colorBorder.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        colorBorder.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: colorBorder.topAnchor),
            emojiLabel.leadingAnchor.constraint(equalTo: colorBorder.leadingAnchor),
            emojiLabel.trailingAnchor.constraint(equalTo: colorBorder.trailingAnchor),
            emojiLabel.bottomAnchor.constraint(equalTo: colorBorder.bottomAnchor),
            colorBorder.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorBorder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorBorder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorBorder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

