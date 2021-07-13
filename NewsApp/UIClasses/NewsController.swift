//
//  ViewController.swift
//  NewsApp
//
//  Created by Admin on 29.06.21.
//

import UIKit
import ViewAnimator

protocol CellSubclassDelegate: AnyObject {
    func buttonTapped(cell: NewsCell)
}

class NewsController: UIViewController, CellSubclassDelegate  {
    
    @IBOutlet weak var newsTableView: UITableView!
    
    
    //MARK: - Variables
    private let networkService = NetworkService()
    private let searchController = UISearchController(searchResultsController: nil)
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: .valueChanged)
        return refreshControl
    }()
    
    private let animations = [AnimationType.vector((CGVector(dx: 40, dy: 0))), AnimationType.identity]
    
    private var daysCounter: Int = 0
    private var from = ""
    private var to = ""
    private var currentDay: Date = Date()
    private var daybefore: Date = Date()
    private let dateFormatter = DateFormatter()
    
    private var cellsData: [Article] = []
    private var allArticles: [Article] = []
    private var filtered: [Article] = []

    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNewsTableView()
        setupSearchBar()
        hideKeyboardWhenTappedAround()
        setupDate()
        loadData()
    }
    
    func loadData() {
        daybefore = Date().getDayBefore(from: currentDay)
         from = dateFormatter.string(from: currentDay)
         to = dateFormatter.string(from: daybefore)
        
        networkService.setupApiConnection(from: from, to: to) { (result, isConnected) in
            print(result.articles.count)
            let parsed = result.articles
            self.cellsData = parsed
            self.allArticles = parsed
            DispatchQueue.main.async {
                self.newsTableView.reloadData()
            }
        }
     }
//MARK: - Actions
    //pull to refresh action
    @objc private func refresh(sender: UIRefreshControl) {
        daysCounter = 0
        networkService.setupApiConnection(from: from, to: to) { (result, isConnected) in
            print(result.articles.count)
            let parsed = result.articles
            self.cellsData = parsed
            self.allArticles = parsed
            DispatchQueue.main.async {
                self.newsTableView.reloadData()
            }
        }
        sender.endRefreshing()
    }
    // delegate function for correct work button when cell is reusing
    func buttonTapped(cell: NewsCell) {
        newsTableView.beginUpdates()
      //  print(cell.descriptionLabel.text)
      //  print(cell.descriptionLabel.isTruncated)
       // print(cell.descriptionLabel.numberOfLines)
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
        newsTableView.endUpdates()
    }
    func hideKeyboardWhenTappedAround() {
           let tapGesture = UITapGestureRecognizer(target: self,
                                                   action: #selector(hideKeyboard))
           view.addGestureRecognizer(tapGesture)
       }
    @objc func hideKeyboard() {
        searchController.searchBar.endEditing(true)
       }
    // MARK: - UI Setup
    private func setupSearchBar() {
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Tesla"
        navigationItem.hidesSearchBarWhenScrolling = false
        view.addSubview(searchController.searchBar)
    }
    
    private func setupDate() {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    }
    
    private func setupNewsTableView() {
        newsTableView.dataSource = self
        newsTableView.delegate = self
        newsTableView.refreshControl = self.refreshControl
    }
  
    
}
// MARK: - UITableViewDataSource, UITableViewDelegate
extension NewsController: UITableViewDelegate, UITableViewDataSource {
    
    //load additional news at the end of the scroll
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = cellsData.count - 1
        
        if (indexPath.row == lastElement) && (daysCounter < 7) && !isFiltering {
            currentDay = daybefore
            daybefore = Date().getDayBefore(from: currentDay)
            
            to = dateFormatter.string(from: currentDay)
            from = dateFormatter.string(from: daybefore)
            print("from: \(from) to: \(to)")
           
            self.networkService.setupApiConnection(from: from, to: to) { (result, _) in
                print(result.articles.count)
                DispatchQueue.main.async {
                    self.cellsData.append(contentsOf: result.articles)
                    self.allArticles = self.cellsData
                    self.daysCounter += 1
                    print("days counter \(self.daysCounter)")
                    print("cells data \(self.cellsData.count)")
                    self.newsTableView.reloadData()
                }
            }
        }
        UITableViewCell.animate (views: [cell],
                                 animations: animations, duration: 0.5, options: [.curveEaseInOut], completion: {

                                   })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filtered.count
        }
        return cellsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell2", for: indexPath) as! NewsCell
        cell.delegate = self
        if isFiltering {
            cellsData = filtered
        } else {
            cellsData = allArticles
        }
        let article = cellsData[indexPath.row]
        cell.article = article
        return cell
    }
}
//MARK: - Search Bar: UISearchResultsUpdating, UISearchBarDelegate
extension NewsController: UISearchResultsUpdating, UISearchBarDelegate {
    
   @objc func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
      //  cellsData = parsedArticles
        DispatchQueue.main.async {
            self.cellsData = self.allArticles
            self.newsTableView.reloadData()
        }
    }
    
    private var searchBarEmpty: Bool {
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    
     var isFiltering: Bool {
        return searchController.isActive && !searchBarEmpty
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearch(_searchText: searchController.searchBar.text!)
    }
    
    private func filterContentForSearch(_searchText: String) {
        filtered = (cellsData.filter({ (article: Article) -> Bool in
            return  (article.title?.lowercased().contains(_searchText.lowercased()))!
        }))
        newsTableView.reloadData()
    }
    
}
