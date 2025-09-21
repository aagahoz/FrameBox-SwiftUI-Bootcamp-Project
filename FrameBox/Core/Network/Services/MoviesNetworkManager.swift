//
//  MoviesNetworkManager.swift
//  FrameBox
//
//  Created by Agah Ozdemir on 19.09.2025.
//

import Foundation

// MARK: - MoviesNetworkManager
final class MoviesNetworkManager {
    
    // MARK: - Properties
    private let baseURL = "http://kasimadalan.pe.hu/movies/"
    private let fixedUserName = "agah_ozdemir"
    
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        return URLSession(configuration: config)
    }()
    
    // MARK: - Endpoints
    private enum Endpoint: String {
        case allMovies = "getAllMovies.php"
        case images = "images/"
        case insertMovie = "insertMovie.php"
    }
    
    // MARK: - Errors
    enum NetworkError: Error {
        case invalidURL
        case noData
    }
    
    // MARK: - Helpers
    /// Görsel için tam URL döner
    func imageURL(fileName: String) -> URL? {
        return URL(string: baseURL + Endpoint.images.rawValue + fileName)
    }
    
    // MARK: - Public Methods
    /// Tüm filmleri çeker
    func fetchMovies(completion: @escaping (Result<[MovieModel], Error>) -> Void) {
        guard let url = URL(string: baseURL + Endpoint.allMovies.rawValue) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(MoviesResponseModel.self, from: data)
                completion(.success(response.movies))
            } catch {
                print("Decoding error:", error)
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    /// Sepete film ekler
    func insertMovie(movie: MovieModel, orderAmount: Int, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: baseURL + Endpoint.insertMovie.rawValue) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Parametreleri form-data gibi gönderiyoruz (x-www-form-urlencoded)
        let params: [String: Any] = [
            "name": movie.name ?? "",
            "image": movie.image ?? "",
            "price": movie.price ?? 0,
            "category": movie.category ?? "",
            "rating": movie.rating ?? 0.0,
            "year": movie.year ?? 0,
            "director": movie.director ?? "",
            "description": movie.description ?? "",
            "orderAmount": orderAmount,
            "userName": fixedUserName
        ]
        
        // body encode et
        let bodyString = params.map { "\($0)=\($1)" }
            .joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            // JSON yanıtı parse et
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = json["message"] as? String {
                    completion(.success(message))
                } else {
                    completion(.success("No valid response"))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func fetchCartMovies(completion: @escaping (Result<[CartMovieModel], Error>) -> Void) {
        guard let url = URL(string: baseURL + "getMovieCart.php") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let bodyString = "userName=\(fixedUserName)"
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                // Önce boş mu diye kontrol et
                if data.isEmpty {
                    completion(.success([])) // Boş dizi döndür
                    return
                }
                
                let decoder = JSONDecoder()
                let response = try decoder.decode(CartMoviesResponseModel.self, from: data)
                completion(.success(response.movies))
            } catch {
                // Eğer decode edilemezse, boş dizi ile fallback yap
                print("Cart decoding error:", error)
                completion(.success([]))
            }
        }
        task.resume()
    }
    
    func deleteCartMovie(cartId: Int, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: baseURL + "deleteMovie.php") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let params: [String: Any] = [
            "cartId": cartId,
            "userName": fixedUserName
        ]
        
        let bodyString = params.map { "\($0)=\($1)" }
            .joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            // JSON yanıtı parse et
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = json["message"] as? String {
                    completion(.success(message))
                } else {
                    completion(.success("No valid response"))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
