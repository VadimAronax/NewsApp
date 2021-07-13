//
//  NetworkService.swift
//  NewsApp
//
//  Created by Admin on 8.07.21.
//

import Foundation

class NetworkService {
    
    let apiKey = "e667e9a4ebc0463b8d8ff36985862dc2"
    let apiKey2 = "560257a4f5fa40fc902a3d51417e05aa" //when limit reaches 50 request per day
    let source = "Tesla"
    var url = URLComponents(string: "https://newsapi.org/v2/everything")!
    
    func setupRequest(from: String, to: String) -> NSMutableURLRequest {
        url.queryItems = [
            URLQueryItem(name: "q", value: source),
            URLQueryItem(name: "apiKey", value: apiKey2),
            URLQueryItem(name: "from", value: from),
            URLQueryItem(name: "to", value: to),
            URLQueryItem(name: "sortBy", value: "publishedAt"),
            URLQueryItem(name: "pageSize", value: "100"),
            URLQueryItem(name: "qInTitle", value: "Tesla")]
        
        let request = NSMutableURLRequest(url: url.url!)
        request.httpMethod = "GET"
        
        return request
    }
    
    func setupApiConnection(from: String, to: String, completionHandler: @escaping (ArticleListResponse, Bool) -> ()) {
        var parsed = ArticleListResponse(articles: [])
        let request = self.setupRequest(from: from, to: to)
        let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            do {
                if (try JSONSerialization.jsonObject(with: data!, options: [])
                        as? NSDictionary) != nil {
                    parsed = try! JSONDecoder().decode(ArticleListResponse.self,from: data!)
                    print("apiconnection")
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            // возвращаем данные в мэйн поток
            DispatchQueue.main.async {
                completionHandler(parsed, false)
            }
        }
        dataTask.resume()
    }
}
