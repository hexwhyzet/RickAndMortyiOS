import UIKit

final class HomeViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(mainStack)
        view.backgroundColor = .appColor(.bg)
        mainStack.addArrangedSubview(titlesStack)
        titlesStack.addArrangedSubview(mainTitle)
        titlesStack.addArrangedSubview(secondTitle)
        mainStack.addArrangedSubview(iconsList)
                
        titlesStack.isLayoutMarginsRelativeArrangement = true
        titlesStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0)
        
        view.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        mainStack.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        titlesStack.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            iconsList.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .vertical
        stack.distribution = .fill
        stack.spacing = 15
        return stack
    }()
    
    private lazy var titlesStack: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fillProportionally
        return stack
    }()
    
    private lazy var mainTitle: UILabel = {
        let ret = UILabel()
        let attributes: [NSAttributedString.Key : Any] = [.strokeColor: UIColor.appColor(.main)!,
                                                          .foregroundColor: UIColor.appColor(.bg)!,
                                                          .strokeWidth: -1.0,
                                                          .font: UIFont.appFont(.SFDisplayBlack, 85)!]
        ret.numberOfLines = 3
        ret.attributedText = NSAttributedString(string: "RICK\nAND\nMORTY", attributes: attributes)
        ret.adjustsFontSizeToFitWidth = true
        return ret
    }()
    
    private lazy var secondTitle: UILabel = {
        let ret = UILabel()
        ret.font = .appFont(.SFDisplayBlack, 35)
        ret.numberOfLines = 2
        ret.textColor = UIColor.appColor(.main)
        ret.text = "CHARACTER\nBOOK"
        ret.adjustsFontSizeToFitWidth = true
        return ret
    }()
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        present(BigPictureViewController(), animated: true)
    }
    
    private lazy var iconsList: UIImageView = {
        let ret = UIImageView(image: UIImage(named: "RickAndMortyListShort.png"))
        ret.layer.masksToBounds = true
        ret.contentMode = .scaleAspectFill
        ret.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        ret.addGestureRecognizer(tapGestureRecognizer)
        return ret
    }()
}

