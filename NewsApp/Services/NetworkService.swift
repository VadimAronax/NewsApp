//
//  NetworkService.swift
//  NewsApp
//
//  Created by Admin on 8.07.21.
//

import Foundation
import UIKit

enum URLError: Error {
    case noData, decodingError
    case unknownError
}

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
    
    func loadArticlesAndDecode<T: Decodable>(from: String, to: String, decoder: JSONDecoder = JSONDecoder(), completion: @escaping (Result<T, Error>) -> Void) -> URLSessionDataTask {
        let request = self.setupRequest(from: from, to: to)
        return URLSession.shared.dataTask(with: request as URLRequest) { [weak self] (data, response, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    completion(.failure(error ?? URLError.unknownError))
                    return
                }
                guard let data = data, let _ = response else {
                    completion(.failure(URLError.noData))
                    return
                }
                guard data == data, error == nil else {
                    completion(.failure(error ?? URLError.unknownError))
                    return
                }
                do {
                    var decoded = try decoder.decode(T.self, from: data) as! ArticleListResponse
                    decoded.articles = decoded.articles.filter {
                        ($0.title != nil) || ($0.description != nil) || ($0.content != nil) || ($0.description != "")
                    }
                    completion(.success(decoded as! T))
                } catch {
                    do {
                        print("parsing error")
                        let decodedError = try decoder.decode(ErrorResponse.self, from: data)
                        let error = NSError(domain: "ServerResponse", code: 1, userInfo: [NSLocalizedDescriptionKey: decodedError.message as Any])
                        completion(.failure(error))
                    } catch let parsingOfErrorResponseError {
                        completion(.failure(parsingOfErrorResponseError))
                    }
                    
                }
            }
        }
    }
    
    func loadArticlesAndDecode<T: Decodable>(from: String, to: String, with url: URL, decoder: JSONDecoder = JSONDecoder(), completion: @escaping (Result<T, Error>) -> Void) -> URLSessionDataTask {
        self.loadArticlesAndDecode(from: from, to: to, decoder: decoder, completion: completion)
    }
}
