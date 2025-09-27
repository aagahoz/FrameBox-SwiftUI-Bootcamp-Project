//
//  MovieModel.swift
//  FrameBox
//
//  Created by Agah Ozdemir on 19.09.2025.
//

import Foundation

struct MovieModel: Identifiable, Codable {
    let id: Int?
    let name: String?
    let image: String?
    let price: Int?
    let category: String?
    let rating: Double?
    let year: Int?
    let director: String?
    let description: String?
}

//
//  CartMovieModel.swift
//  FrameBox
//
//  Created by Agah Ozdemir on 21.09.2025.
//

import Foundation

struct CartMovieModel: Identifiable, Codable {
    let cartId: Int
    let name: String
    let image: String
    let price: Int
    let category: String
    let rating: Double
    let year: Int
    let director: String
    let description: String
    let orderAmount: Int
    let userName: String
    
    var id: Int { cartId }
}

struct CartMoviesResponseModel: Codable {
    let movies: [CartMovieModel]
    
    enum CodingKeys: String, CodingKey {
        case movies = "movie_cart"
    }
}

extension CartMovieModel {
    func toMovieModel() -> MovieModel {
        MovieModel(
            id: cartId,
            name: name,
            image: image,
            price: price,
            category: category,
            rating: rating,
            year: year,
            director: director,
            description: description
        )
    }
}
