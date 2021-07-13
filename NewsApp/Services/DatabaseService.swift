//
//  DatabaseService.swift
//  NewsApp
//
//  Created by Admin on 10.07.21.
//

import Foundation
import CoreData
import UIKit

class DataBaseService {
    
    static let shareInstance = DataBaseService()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    func saveData(article: Article) {
        let articleInstance = FavArticles(context: context)
        articleInstance.title = article.title
        articleInstance.descriptionAricle = article.description
        articleInstance.publishedAt = article.publishedAt
        articleInstance.urlToImage = article.urlToImage
        do {
            try context.save()
            print("Image is saved")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage() -> [FavArticles] {
        var fetchingImage = [FavArticles]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavArticles")
        do {
            fetchingImage = try context.fetch(fetchRequest) as! [FavArticles]
        } catch {
            print("Error while fetching the image")
        }
        return fetchingImage
    }
    
    func checkRecordExists(entity: String, uniqueIdentity: String,idAttributeName:String) -> Bool {
        let context = context
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        fetchRequest.predicate = NSPredicate(format: "\(idAttributeName) CONTAINS[cd] %@", uniqueIdentity)
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        return results.count > 0
    }
}
