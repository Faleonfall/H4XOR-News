//
//  NetworkManager.swift
//  H4XOR News
//
//  Created by Volodymyr Kryvytskyi on 14.09.2023.
//

import Foundation

@MainActor
final class NetworkManager: ObservableObject {
    
    @Published private(set) var posts: [Post] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var lastUpdated: Date?
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let frontPageURL = URL(string: "https://hn.algolia.com/api/v1/search?tags=front_page")!
    
    init(session: URLSession = .shared) {
        self.session = session
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }
    
    enum NetworkError: LocalizedError {
        case badStatus(Int)
        case invalidResponse
        
        var errorDescription: String? {
            switch self {
            case .badStatus(let code):
                return "Server returned an unexpected status code: \(code)."
            case .invalidResponse:
                return "Received an invalid response from the server."
            }
        }
    }
    
    func fetchFrontPage() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let (data, response) = try await session.data(from: frontPageURL)
            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            guard (200...299).contains(http.statusCode) else {
                throw NetworkError.badStatus(http.statusCode)
            }
            
            let results = try decoder.decode(Results.self, from: data)
            // If you want, you could sort or filter here:
            // posts = results.hits.sorted { $0.points > $1.points }
            posts = results.hits
            lastUpdated = Date()
        } catch is CancellationError {
            // Task was cancelled; ignore.
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}
