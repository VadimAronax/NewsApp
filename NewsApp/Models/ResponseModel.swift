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

struct Article: Codable {
    var author: String?
    var content: String?
    var description: String?
    var urlToImage: String?
    var title: String?
    var publishedAt: String?
    // var articleText: String
}


