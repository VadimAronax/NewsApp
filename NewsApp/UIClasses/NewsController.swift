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
    
    private var cellsDataArticles: [Article] = []  //actual data articles for cells
    private var allArticles: [Article] = []   // list of all articles for a week
    private var filteredBySearchArticles: [Article] = []
    
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
        loadArticles()
    }
    
    private func loadArticles() {
        networkService.loadArticlesAndDecode(from: from, to: to) { [weak self] (result: (Result<ArticleListResponse, Error>))  in
            switch result {
            case .success(let articles):
                let parsed = articles.articles
                self?.cellsDataArticles = parsed
                self?.allArticles = parsed
                DispatchQueue.main.async {
                    self?.newsTableView.reloadData()
                }
                print("Person \(articles.articles.count)")
            case .failure(let error):
                self?.showErrorAlert(error: error)
            }
        }.resume()
    }
    //MARK: - Actions
    //pull to refresh action
    @objc private func refresh(sender: UIRefreshControl) {
        daysCounter = 0
        loadArticles()
        sender.endRefreshing()
    }
    // delegate function for correct work button when cell is reusing
    func buttonTapped(cell: NewsCell) {
            newsTableView.beginUpdates()
            if cell.descriptionLabel.numberOfLines >= 3
            {
                UILabel.transition(with: cell.descriptionLabel,
                                   duration: 0.8,
                                   options: [.transitionCrossDissolve],
                                   animations: { [weak self] in
                                   }, completion: nil)
                cell.descriptionLabel.numberOfLines = 0
                cell.descriptionLabel.lineBreakMode = .byWordWrapping
                
                cell.descriptionLabel?.sizeToFit()
                cell.showMoreButton.setTitle("Show Less", for: .normal)
            }
            else {
                UILabel.transition(with: cell.descriptionLabel,
                                   duration: 0.7,
                                   options: [.transitionCrossDissolve, .transitionFlipFromBottom],
                                   animations: { [weak self] in
                                   }, completion: nil)
                
                //   UILabel.setAnimationsEnabled(false)
                cell.descriptionLabel.numberOfLines = 3
                cell.showMoreButton.setTitle("Show More", for: .normal)
                cell.descriptionLabel?.sizeToFit()
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
        let lastElement = cellsDataArticles.count - 1
        
        if (indexPath.row == lastElement) && (daysCounter < 7) && !isFiltering {
            currentDay = daybefore
            daybefore = Date().getDayBefore(from: currentDay)
            
            to = dateFormatter.string(from: currentDay)
            from = dateFormatter.string(from: daybefore)
            print("from: \(from) to: \(to)")
            
            self.networkService.loadArticlesAndDecode(from: from, to: to) { [weak self] (result: (Result<ArticleListResponse, Error>))  in
                
                switch result {
                case .success(let articlesList):
                    DispatchQueue.main.async {
                        let articles = articlesList.articles
                        print(articlesList.articles.count)
                        self?.cellsDataArticles.append(contentsOf: articles)
                        guard let articlesData = self?.cellsDataArticles else {return}
                        self?.allArticles = articlesData
                        self?.daysCounter += 1
                        self?.newsTableView.reloadData()
                    }
                case .failure(let error):
                    self?.showErrorAlert(error: error)
                }
            }.resume()
        }
        
        UITableViewCell.animate (views: [cell],
                                 animations: self.animations, duration: 0.7, options: [.curveEaseIn], completion: {
                                 })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredBySearchArticles.count
        }
        return cellsDataArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell2", for: indexPath) as! NewsCell
        cell.delegate = self
        
        if isFiltering {
            cellsDataArticles = filteredBySearchArticles
        } else {
            cellsDataArticles = allArticles
        }
        let article = cellsDataArticles[indexPath.row]
        cell.article = article

        return cell
    }
}
//MARK: - Search Bar: UISearchResultsUpdating, UISearchBarDelegate
extension NewsController: UISearchResultsUpdating, UISearchBarDelegate {
    
    @objc func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //  cellsData = parsedArticles
        DispatchQueue.main.async {
            self.cellsDataArticles = self.allArticles
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
        filterContentForSearch(_searchText: searchController.searchBar.text ?? "")
    }
    
    private func filterContentForSearch(_searchText: String) {
        filteredBySearchArticles = (cellsDataArticles.filter({ [weak self] (article: Article) -> Bool in
            guard let filteredContent = (article.title?.lowercased().contains(_searchText.lowercased())) else {return false}
            return filteredContent
        }))
        newsTableView.reloadData()
    }
    
    func showErrorAlert(error: Error) {
        let errorDescription:String
        #if DEVELOP
        errorDescription = error.localizedDescription
        #elseif PROD
        errorDescription = "Something went wrong"
        #endif
        let alert = UIAlertController(title: "Error!", message: errorDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: .none))
        self.present(alert, animated: true, completion: nil)
    }
    
}
