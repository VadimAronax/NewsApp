//
//  ResponseModel.swift
//  NewsApp
//
//  Created by Admin on 7.07.21.
//

import Foundation

struct  ArticleListResponse: Decodable {
    //    enum CodingKeys: String, CodingKey {
    //        case articles
    //    }
    var articles: [Article]
}

struct ErrorResponse: Decodable {
    var status: String
    var code: String?
    var message: String?
}

struct Article: Codable {
    var author: String?
    var content: String?
    var description: String?
    var urlToImage: String?
    var title: String?
    var publishedAt: String?
    
    static let unknownAuthor: String = "Unknown"
    
    enum CodingKeys: String, CodingKey {
        case author
        case content
        case description
        case urlToImage
        case title
        case publishedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        author = try? container.decode(String?.self, forKey: .author) ?? Article.unknownAuthor
        description = try? container.decode(String.self, forKey: .description)
        urlToImage = try? container.decode(String.self, forKey: .urlToImage)
        publishedAt = try? container.decode(String.self, forKey: .publishedAt)
        title = try? container.decode(String.self, forKey: .title)
    }
    
    internal init(description: String?, title: String?, urlToImage: String?, publishedAt: String?) {
        self.description = description
        self.title = title
        self.urlToImage = urlToImage
        self.publishedAt = publishedAt
    }
    
}


