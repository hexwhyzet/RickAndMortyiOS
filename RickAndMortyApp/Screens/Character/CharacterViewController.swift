import Foundation
import UIKit
import Kingfisher


final class CharacterViewController: UIViewController {
    
    init(model: Character) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        self.requestIsFavourite()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logger.log(level: .info, message: "Character \(self.model.name) opened")
        
        view.backgroundColor = UIColor.appColor(.bg)
        self.navigationItem.title = "Characters"
        
        setupUI()
        updateLikeButtonView()
        updateInfo()
        configureItems()
    }
    
    private func configureItems() {
        let backButton = UIButton(type: .system)
        backButton.tintColor = UIColor.appColor(.main)
        backButton.titleLabel?.font = UIFont.appFont(.SFTextSemibold, 15)
        let largeConfig = UIImage.SymbolConfiguration(weight: .semibold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: largeConfig), for: .normal)
        backButton.setTitle(" Back", for: .normal)
        backButton.sizeToFit()
        backButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    var onDoneBlock: (() -> Void)? = nil
    
    @objc func close() {
        dismiss(animated: true, completion: self.onDoneBlock)
    }
    
    private func setupUI() {
        view.addSubview(scroll)
        scroll.addSubview(stack)
        stack.addArrangedSubview(icon)
        stack.setCustomSpacing(35, after: icon)
        stack.addArrangedSubview(nameLabelAndButton)
        stack.setCustomSpacing(25, after: nameLabelAndButton)
        stack.addArrangedSubview(statusCell)
        stack.addArrangedSubview(speciesCell)
        stack.addArrangedSubview(genderCell)
        
        //        stack.isLayoutMarginsRelativeArrangement = true
        //        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)
        
        //        view.backgroundColor = UIColor.green
        //        scroll.backgroundColor = UIColor.red
        //        stack.backgroundColor = UIColor.blue
        
        view.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        scroll.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        stack.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let stackPadding: CGFloat = 16
        
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scroll.contentLayoutGuide.bottomAnchor.constraint(equalTo: stack.bottomAnchor, constant: stackPadding),
            stack.centerXAnchor.constraint(equalTo: scroll.centerXAnchor),
            stack.topAnchor.constraint(equalTo: scroll.topAnchor, constant: stackPadding),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: stackPadding),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: stackPadding),
            //            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: stackPadding),
        ])
        
        stack.layoutIfNeeded()
        
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(lessThanOrEqualToConstant: stack.frame.width),
            icon.heightAnchor.constraint(lessThanOrEqualToConstant: stack.frame.width),
            icon.centerXAnchor.constraint(equalTo: stack.centerXAnchor),
        ])
        
        for infoCell in [nameLabelAndButton, statusCell, speciesCell, genderCell] {
            NSLayoutConstraint.activate([
                infoCell.leadingAnchor.constraint(equalTo: stack.leadingAnchor, constant: 0),
                infoCell.trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: 0)
            ])
        }
    }
    
    private func updateInfo() {
        icon.kf.setImage(with: model.imageURL()!)
        nameLabel.text = model.name
        statusCell.update(with: InfoCell.Model(key: "Status", value: self.model.status))
        speciesCell.update(with: InfoCell.Model(key: "Species", value: self.model.species))
        genderCell.update(with: InfoCell.Model(key: "Gender", value: self.model.gender))
    }
    
    private let model: Character
    private var isFavourite: Bool = false
    
    func requestIsFavourite() {
        Task {
            let isFavourite = try await RickAndMortyStorage.shared.isFavourite(character: self.model)
            updateIsFavourite(isFavourite: isFavourite)
        }
    }
    
    func updateIsFavourite(isFavourite: Bool) {
        self.isFavourite = isFavourite
        updateLikeButtonView()
    }
    
    private lazy var scroll: UIScrollView = {
        let scroll = UIScrollView(frame: .zero)
        scroll.backgroundColor = .clear
        return scroll
    }()
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 5
        return stack
    }()
    
    private lazy var icon: UIImageView = {
        let ret = UIImageView()
        ret.layer.cornerRadius = 15
        ret.layer.masksToBounds = true
        ret.contentMode = .scaleAspectFill
        if (self.traitCollection.userInterfaceStyle == .light) {
            ret.layer.borderWidth = 1
            ret.layer.borderColor = UIColor.appColor(.main)!.cgColor
        }
        return ret
    }()
    
    private lazy var nameLabel: UILabel = {
        let ret = UILabel()
        ret.font = .appFont(.SFDisplayBold, 45)
        ret.numberOfLines = 0
        ret.textColor = UIColor.appColor(.main)
        return ret
    }()
    
    private lazy var likeButton: UIButton = {
        let buttonSize: CGFloat = 50
        let ret = UIButton()
        ret.layer.cornerRadius = buttonSize / 2
        ret.clipsToBounds = true
        ret.addTarget(self, action: #selector(onLikeButtonTap), for: .touchUpInside)
        ret.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        ret.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        return ret
    }()
    
    func updateLikeButtonView() {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20)
        if (!self.isFavourite) {
            likeButton.backgroundColor = UIColor.appColor(.greybg)!
            likeButton.setImage(UIImage(systemName: "heart", withConfiguration: largeConfig), for: .normal)
            likeButton.tintColor = UIColor.appColor(.main)
        } else {
            likeButton.backgroundColor = UIColor.appColor(.main)!
            likeButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: largeConfig), for: .normal)
            likeButton.tintColor = UIColor.appColor(.bg)
        }
    }
    
    @objc func onLikeButtonTap() {
        logger.log(level: .info, message: "Like Button pressed")
        Task {
            try await RickAndMortyStorage.shared.saveFavouriteCharacter(isFavorite: !self.isFavourite, character: self.model)
            updateIsFavourite(isFavourite: !self.isFavourite)
        }
    }
    
    private lazy var nameLabelAndButton: UIStackView = {
        let stack = UIStackView(frame: .zero)
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.addArrangedSubview(nameLabel)
        stack.addArrangedSubview(likeButton)
        return stack
    }()
    
    private lazy var statusCell = InfoCell(frame: .zero, containsDelimeter: true)
    private lazy var speciesCell = InfoCell(frame: .zero, containsDelimeter: true)
    private lazy var genderCell = InfoCell(frame: .zero, containsDelimeter: false)
}
