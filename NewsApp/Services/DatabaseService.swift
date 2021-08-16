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
    
    static let sharedInstance = DataBaseService()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func saveData(article: Article) {
        let articleInstance = FavArticles(context: context)
        articleInstance.title = article.title
        articleInstance.descriptionAricle = article.description
        articleInstance.publishedAt = article.publishedAt
        articleInstance.urlToImage = article.urlToImage
        do {
            try context.save()
            print("Data is saved")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteDataInEntity(entity: String, hasAttribute:String, withValue: String) {
        let context = context
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavArticles")
        fetchRequest.predicate = NSPredicate(format: "\(hasAttribute) CONTAINS[cd] %@", withValue)
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
            for result in results {
                        print(result)
                        context.delete(result)
                   }
        }catch {
            print("error executing fetch request: \(error)")
        }
        
      //  context.delete(articleInstance)
        do {
            try context.save()
            print("Data is deleted")
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchFavoriteArticles() -> [FavArticles] {
        var fetchedFavoriteArticles = [FavArticles]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavArticles")
        do {
            fetchedFavoriteArticles = try context.fetch(fetchRequest) as! [FavArticles]
        } catch {
            print("Error while fetching article")
        }
        return fetchedFavoriteArticles
    }
    
    func IsRecordExistInEntity(entity: String, attribute:String, withValue: String) -> Bool {
        let context = context
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        fetchRequest.predicate = NSPredicate(format: "\(attribute) CONTAINS[cd] %@", withValue)
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
