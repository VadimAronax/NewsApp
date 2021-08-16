//
//  NewsCell.swift
//  NewsApp
//
//

import UIKit

class NewsCell: UITableViewCell {
    
    //MARK: - Variables
    let gradient = CAGradientLayer()
    let networkService = NetworkService()
    weak var delegate: CellSubclassDelegate?
    let dateFormatter = DateFormatter()
    let serviceData = DataBaseService.sharedInstance
    var article: Article! {
        didSet {
            DispatchQueue.main.async {
                self.setImage()
                self.setDescription()
                self.setTitle()
                self.setPublishedAgo()
                self.setTagLabel()
            }
        }
    }
    var isTappedShowMore: Bool = false
    
    //MARK: - Outlets
    @IBOutlet weak var imageNewsView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var publishedTimeAgoLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var showMoreButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var holderForImageView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleBackgroundView: UIView!
    
    //MARK: - Actions
    @IBAction func pressFavButton(_ sender: Any) {
        guard let publishedAt = article.publishedAt else {return}
        if (!serviceData.IsRecordExistInEntity(entity: "FavArticles", attribute: "publishedAt", withValue: publishedAt)) {
            serviceData.saveData(article: article)
            favoritesButton.tintColor = .systemBlue
        } else {
            serviceData.deleteDataInEntity(entity: "FavArticles", hasAttribute: "publishedAt", withValue: publishedAt)
            favoritesButton.tintColor = .systemGray2
        }
    }
    
    @IBAction func showMoreButtonPressed(_ sender: Any) {
        self.delegate?.buttonTapped(cell: self)
    }
    
    //MARK: - Superclass methods
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.delegate = nil
        self.imageNewsView.image = nil
        
        self.descriptionLabel.numberOfLines = 3
        self.showMoreButton.setTitle("Show More", for: .normal)
        self.favoritesButton.tintColor = .systemGray2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
 
        toWhiteTextThemeColor()
        setGradient()
        setShadowsAndCorners()
        
        self.activityIndicator.hidesWhenStopped = true
        
        titleBackgroundView.layer.cornerRadius = 3
        titleBackgroundView.layer.masksToBounds = true
        titleBackgroundView.sizeToFit()
        
        tagLabel.layer.cornerRadius = 5
        tagLabel.layer.masksToBounds = true
        tagLabel.sizeToFit()
    }
    //MARK: - UI Setup
    func toWhiteTextThemeColor() {
        descriptionLabel.textColor = .white
        titleLabel.textColor = .white
    }
    
    private func setShadowsAndCorners() {
        imageNewsView.layer.cornerRadius = 12
        imageNewsView.layer.masksToBounds = true;
        
        holderForImageView.backgroundColor = UIColor.clear
        holderForImageView.layer.shadowColor = UIColor.black.cgColor
        holderForImageView.layer.shadowOpacity = 0.75
        holderForImageView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        holderForImageView.layer.shadowRadius = 2.0
        holderForImageView.clipsToBounds  = false
    }
    
    private func setGradient(){
        // gradient.frame = self.contentView.bounds
        // bugfix when gradiend delay from expanding view
        gradient.frame = CGRect(origin: self.contentView.bounds.origin , size: CGSize(width: self.contentView.bounds.width, height: self.contentView.bounds.height + 30))
        gradient.colors = [UIColor.black.withAlphaComponent(0.3).cgColor,UIColor.black.withAlphaComponent(0.8).cgColor, UIColor.black.withAlphaComponent(0.3)]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1.2)
        imageNewsView.layer.insertSublayer(gradient, at: 0)
    }
    //MARK: - Set data to UI
    func setImage() {
        activityIndicator.startAnimating()
        DispatchQueue.global().async {
            let photoUrl = self.article.urlToImage
            if let imageUrl = photoUrl, let url = URL(string: imageUrl) {
                do {
                    let data = try Data(contentsOf: url)
                    DispatchQueue.main.async { [weak self] in
                        guard let downloadedImage = UIImage(data: data) else { return }
                        self?.imageNewsView.image = downloadedImage
                        self?.imageViewAppearTransition()
                    }
                } catch {
                    DispatchQueue.main.async { 
                        print("error: set default image")
                        self.imageNewsView.image = UIImage(named: "placeholder")
                    }
                }
            } else {
                print("badUrl")
            }
            DispatchQueue.main.sync {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func setDescription() {
        let text = article.description?.filter { !"\r\n\n\t\r".contains($0) }
        self.descriptionLabel.text = text
        if descriptionLabel.isTruncated == false {
            showMoreButton.isHidden = true
        } else {
            showMoreButton.isHidden = false
        }
    }
    
    func setTitle() {
        let title = article.title?.uppercased()
        self.titleLabel.text = title
    }
    
    func setPublishedAgo() {
        let dateArticle = article.publishedAt
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date2 = dateFormatter.date(from: dateArticle ?? "yyyy-MM-dd")
        let publishedTimeAgo = date2?.timeAgoSinceDate()
        self.publishedTimeAgoLabel.text = publishedTimeAgo
    }
    
    func setTagLabel() {
        tagLabel.text = networkService.source.uppercased()
    }
    //MARK: - Animations and transitions
    func imageViewAppearTransition () {
        UIImageView.transition(with: (self.imageNewsView)!,
                               duration: 1,
                               options: [.transitionCrossDissolve],
                               animations: { [weak self] in
                                self?.imageNewsView.alpha = 0.5
                                self?.imageNewsView.alpha = 1
                               }, completion: nil)
    }
}

