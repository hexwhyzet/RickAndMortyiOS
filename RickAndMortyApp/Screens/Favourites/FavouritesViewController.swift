import Foundation
import UIKit

class FavouritesViewController: UITableViewController, UITabBarControllerDelegate {
    var favourites: [Character] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Favourites"
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.appColor(.main)!]
        
        tableView.backgroundColor = UIColor.appColor(.bg)
        
        tableView.register(FavouritesCell.self, forCellReuseIdentifier: "cell")
        
        tableView.separatorStyle = .singleLine
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        requestFavourites()
    }
    
    func requestFavourites() {
        Task {
            let characters = try await RickAndMortyStorage.shared.getFavourites()
            updateFavourites(characters: characters)
        }
    }
    
    func updateFavourites(characters: [Character]) {
        favourites = characters
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let characterVC = CharacterViewController(model: favourites[indexPath.row])
        characterVC.onDoneBlock = { [weak self] in
            self?.requestFavourites()
        }
        let navC = UINavigationController(rootViewController: characterVC)
        navC.modalPresentationStyle = .overFullScreen
        navC.modalTransitionStyle = .crossDissolve
        show(navC, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return FavouritesCell.height
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FavouritesCell
        cell.update(model: favourites[indexPath.row])
        
        cell.backgroundColor = UIColor.appColor(.bg)
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        cell.layoutMargins = UIEdgeInsets.zero
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.favourites.count == 0 {
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            emptyLabel.text = "No favourites yet"
            emptyLabel.font = UIFont.appFont(.SFTextSemibold, 22)
            emptyLabel.textColor = UIColor.appColor(.secondary)
            emptyLabel.textAlignment = NSTextAlignment.center
            self.tableView.backgroundView = emptyLabel
            self.tableView.separatorStyle = .none
            return 0
        } else {
            self.tableView.backgroundView = nil
            return self.favourites.count
        }
    }
}

class FavouritesCell: UITableViewCell {
    static let height: CGFloat = 132
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func update(model: Character) {
        icon.kf.setImage(with: model.imageURL()!)
        nameLabel.text = model.name
    }
    
    private func setup() {
        contentView.addSubview(icon)
        contentView.addSubview(labelsStack)
        
        labelsStack.addArrangedSubview(nameLabel)
        
        icon.translatesAutoresizingMaskIntoConstraints = false
        labelsStack.translatesAutoresizingMaskIntoConstraints = false
        
        labelsStack.isLayoutMarginsRelativeArrangement = true
        labelsStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 32, leading: 24, bottom: 32, trailing: 16)
        
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: FavouritesCell.height),
            
            icon.heightAnchor.constraint(equalToConstant: 100),
            icon.widthAnchor.constraint(equalToConstant: 100),
            
            icon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            labelsStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            labelsStack.leadingAnchor.constraint(equalTo: icon.trailingAnchor),
            labelsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            labelsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
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
    
    private let labelsStack: UIStackView = {
        let ret = UIStackView()
        ret.axis = .vertical
        ret.distribution = .fillProportionally
        ret.alignment = .leading
        return ret
    }()
    
    private var nameLabel: UILabel = {
        let ret = UILabel()
        ret.font = .appFont(.SFTextBold, 25)
        ret.numberOfLines = 2
        ret.textColor = UIColor.appColor(.main)
        return ret
    }()
}
