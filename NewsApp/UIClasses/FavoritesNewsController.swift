//
//  FavoritesNewsController.swift
//  NewsApp
//
//  Created by Admin on 10.07.21.
//

import Foundation
import UIKit
import ViewAnimator

class FavoritesNewsController: UIViewController, CellSubclassDelegate {
    
    @IBOutlet weak var favNewsTable: UITableView!
    
    private var favArticles: [FavArticles] = []
    private let animations = [AnimationType.vector((CGVector(dx: 20, dy: 0))), AnimationType.identity]

    override func viewDidLoad() {
        super.viewDidLoad()
        favArticles = DataBaseService.shareInstance.fetchImage()
        favNewsTable.dataSource = self
        favNewsTable.delegate = self
    }
    
    func buttonTapped(cell: NewsCell) {
        favNewsTable.beginUpdates()

        if cell.descriptionLabel.numberOfLines >= 3 {
            cell.descriptionLabel.numberOfLines = 0
            cell.descriptionLabel.lineBreakMode = .byWordWrapping
           
            cell.descriptionLabel?.sizeToFit()
            cell.showMoreButton.setTitle("Show Less", for: .normal)
        }
        else {
            cell.descriptionLabel.numberOfLines = 3
            cell.showMoreButton.setTitle("Show More", for: .normal)
        }
        favNewsTable.endUpdates()
    }
}

//MARK: - Table delegates
extension FavoritesNewsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return favArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavNewsCell", for: indexPath) as! NewsCell
        cell.delegate = self
     
        let favArticle = favArticles[indexPath.row]
        cell.article = Article(description: favArticle.descriptionAricle, urlToImage: favArticle.urlToImage, title: favArticle.title, publishedAt: favArticle.publishedAt)
        
        return cell
    }
}

