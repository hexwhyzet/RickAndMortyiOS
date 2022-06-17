import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {
    private let myTableView: UITableView = UITableView()
    private let recentTableViewController: RecentCollectionViewController = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let ret = RecentCollectionViewController.init(collectionViewLayout: layout)
        return ret
    }()
    private var searchCollection: [Character] = []
    
    var isRecentLayout: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    func setupUI() {
        view.addSubview(myTableView)
        
        self.view.backgroundColor = UIColor.appColor(.bg)
        
        let barHeight: CGFloat = searchController.searchBar.frame.height
        let displayHeight: CGFloat = self.view.frame.height
        
        myTableView.register(SearchCell.self, forCellReuseIdentifier: "search")
        
        myTableView.dataSource = self
        myTableView.delegate = self
        searchController.searchResultsUpdater = self
        
        myTableView.separatorColor = UIColor.appColor(.main)
        
        myTableView.translatesAutoresizingMaskIntoConstraints = false
        
        recentTableViewController.collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(recentTableViewController.collectionView)
        
        view.addSubview(searchController.searchBar)
        
        recentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(recentLabel)
        
        updateVisibility()
        
        NSLayoutConstraint.activate([
            recentLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: barHeight + 5),
            recentLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            recentLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 10),
            
            recentTableViewController.collectionView.heightAnchor.constraint(equalToConstant: RecentCell.height),
            recentTableViewController.collectionView.topAnchor.constraint(equalTo: recentLabel.bottomAnchor),
            recentTableViewController.collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            recentTableViewController.collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            myTableView.heightAnchor.constraint(equalToConstant: displayHeight - barHeight),
            myTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: barHeight),
            myTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            myTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    func updateVisibility() {
        if isRecentLayout {
            recentLabel.isHidden = false
            recentTableViewController.collectionView.isHidden = false
            myTableView.isHidden = true
        } else {
            recentLabel.isHidden = true
            recentTableViewController.collectionView.isHidden = true
            myTableView.isHidden = false
        }
    }
    
    let recentLabel: UILabel = {
        let ret = UILabel()
        ret.text = "Recent"
        ret.font = UIFont.appFont(.SFTextSemibold, 15)
        return ret
    }()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchCollection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "search", for: indexPath) as! SearchCell
        let character = searchCollection[indexPath.row]
        cell.update(model: character)
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        cell.layoutMargins = UIEdgeInsets.zero
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let character = searchCollection[indexPath.row]
        let characterVC = CharacterViewController(model: character)
        let navC = UINavigationController(rootViewController: characterVC)
        navC.modalPresentationStyle = .overFullScreen
        navC.modalTransitionStyle = .crossDissolve
        show(navC, sender: self)
        Task {
            try await RickAndMortyStorage.shared.addRecentlySearchedCharacter(character)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SearchCell.height
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let prefix = searchController.searchBar.text ?? ""
        if prefix != "" {
            RickAndMortyApi.shared.searchCharacter(prefix: prefix, completion: updateSearchCollection)
            self.isRecentLayout = false
        } else {
            updateSearchCollection(characters: [])
            recentTableViewController.requestRecents()
            self.isRecentLayout = true
        }
        updateVisibility()
    }
    
    func updateSearchCollection(characters: [Character]) {
        searchCollection = characters
        DispatchQueue.main.async {
            self.myTableView.reloadData()
        }
    }
    
    private var searchController: UISearchController = {
        let ret = UISearchController()
        
        ret.searchBar.searchBarStyle = .default
        ret.searchBar.backgroundImage = UIImage()
        ret.searchBar.backgroundColor = UIColor.appColor(.bg)
        
        ret.searchBar.searchTextField.backgroundColor = UIColor.appColor(.bg)
        ret.searchBar.searchTextField.font = UIFont.appFont(.SFTextSemibold, 16)
        ret.searchBar.searchTextField.attributedPlaceholder =  NSAttributedString.init(string: "Search for character", attributes: [NSAttributedString.Key.foregroundColor:UIColor.appColor(.secondary)!])
        
        ret.searchBar.searchTextField.layer.cornerRadius = 10
        ret.searchBar.searchTextField.layer.borderWidth = 2
        ret.searchBar.searchTextField.layer.borderColor = UIColor.appColor(.main)?.cgColor
        
        ret.searchBar.searchTextField.leftView?.tintColor = UIColor.appColor(.main)
        ret.searchBar.tintColor = UIColor.appColor(.main)
        ret.automaticallyShowsCancelButton = false
        return ret
    }()
}


class RecentCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var recentCollection: [Character] = []
    
    override func viewDidLoad() {
        collectionView.delegate = self
        collectionView.register(RecentCell.self, forCellWithReuseIdentifier: "recent")
        collectionView.showsHorizontalScrollIndicator = false
        requestRecents()
    }
    
    func requestRecents() {
        Task {
            let characters = try await RickAndMortyStorage.shared.getRecentlySearched()
            updateRecentCollection(characters: characters.reversed())
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func updateRecentCollection(characters: [Character]) {
        recentCollection = characters
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.recentCollection.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recent", for: indexPath as IndexPath) as! RecentCell
        cell.update(model: recentCollection[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: RecentCell.width, height: RecentCell.height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let character = recentCollection[indexPath.row]
        let characterVC = CharacterViewController(model: character)
        let navC = UINavigationController(rootViewController: characterVC)
        navC.modalPresentationStyle = .overFullScreen
        navC.modalTransitionStyle = .crossDissolve
        show(navC, sender: self)
    }
}


class RecentCell: UICollectionViewCell {
    static let width: CGFloat = 140
    static let height: CGFloat = 180
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func update(model: Character) {
        icon.kf.setImage(with: model.imageURL()!)
    }
    
    private func setupUI() {
        contentView.addSubview(icon)
        
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalToConstant: RecentCell.width),
            
            icon.heightAnchor.constraint(equalToConstant: 160),
            icon.widthAnchor.constraint(equalToConstant: 120),
            
            icon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
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
}




class SearchCell: UITableViewCell {
    static let height: CGFloat = 192
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    func update(model: Character) {
        icon.kf.setImage(with: model.imageURL()!)
        nameLabel.text = model.name
        speciesLabel.text = model.species
    }
    
    private func setupUI() {
        contentView.addSubview(icon)
        contentView.addSubview(labelsStack)
        labelsStack.addArrangedSubview(nameLabel)
        labelsStack.addArrangedSubview(speciesLabel)
        
        icon.translatesAutoresizingMaskIntoConstraints = false
        labelsStack.translatesAutoresizingMaskIntoConstraints = false
        
        labelsStack.isLayoutMarginsRelativeArrangement = true
        labelsStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 32, leading: 24, bottom: 32, trailing: 16)
        
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: SearchCell.height),
            
            icon.heightAnchor.constraint(equalToConstant: 160),
            icon.widthAnchor.constraint(equalToConstant: 120),
            
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
    
    private var speciesLabel: UILabel = {
        let ret = UILabel()
        ret.font = .appFont(.SFTextSemibold, 18)
        ret.numberOfLines = 1
        ret.textColor = UIColor.appColor(.secondary)
        return ret
    }()
}
