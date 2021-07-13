//
//  NewsCell.swift
//  NewsApp
//
//  Created by Admin on 30.06.21.
//

import UIKit

class NewsCell: UITableViewCell {
    //MARK: - Variables
    private var timer: Timer?
    let gradient = CAGradientLayer()
    let networkService = NetworkService()
    weak var delegate: CellSubclassDelegate?
    let dateFormatter = DateFormatter()
    let serviceData = DataBaseService.shareInstance
    var article: Article! {
        didSet {
            setImage()
            setDescription()
            setTitle()
            setPublishedAgo()
            setTagLabel()
        }
    }
    //MARK: - Outlets
    @IBOutlet weak var imageNewsView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var publishedTimeAgoLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var showMoreButton: UIButton!
    @IBOutlet weak var holderForImageView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Actions
    @IBAction func pressFavButton(_ sender: Any) {
        // print (article.publishedAt)
        if (!serviceData.checkRecordExists(entity: "FavArticles", uniqueIdentity: article.publishedAt!, idAttributeName: "publishedAt")) {
            serviceData.saveData(article: article)
        }
    }
    
    @IBAction func showMoreButtonPressed(_ sender: Any) {
        self.delegate?.buttonTapped(cell: self)
    }
    // stop animate indicator when timer ended
    @objc func timerAction() {
        activityIndicator.stopAnimating()
    }
    
    //MARK: - Superclass methods
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
        imageNewsView.image = UIImage(named: "placeholder")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        toWhiteTextThemeColor()
        setGradient()
        setShadowsAndCorners()
        
        self.activityIndicator.hidesWhenStopped = true
        
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
            DispatchQueue.main.async {
                self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)}
            
            let photoUrl = self.article.urlToImage
            guard let imageUrl = photoUrl, let url = URL(string: imageUrl) else { return }
            do {
                let data = try Data(contentsOf: url)
                DispatchQueue.main.async {
                    let downloadedImage = UIImage(data: data)
                    self.imageNewsView.image = downloadedImage
                }
            } catch {
                DispatchQueue.main.async {
                    print("error: set default image")
                    self.imageNewsView.image = UIImage(named: "placeholder")
                }
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
    
}

