//
//  StopService.swift
//  TriLive
//
//  Created by Brian Maina on 7/3/25.
//

import Foundation

class StopService {
    static let shared = StopService()
    
    // safely pull from Info.plist, or crash with a clear message
    private var baseURL: URL {
        guard let s = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
              let url = URL(string: s) else {
            fatalError("🔴 API_BASE_URL is missing or invalid in Info.plist")
        }
        return url
    }

    // Fetches all stops from GET /stations
    func fetchStops(completion: @escaping (Result<[Stop], Error>) -> Void) {
        let url = baseURL.appendingPathComponent("stations")
        URLSession.shared.dataTask(with: url) { data, response, error in
            // transport error
            if let error = error {
                return completion(.failure(error))
            }
            // check HTTP status code
            if let code = (response as? HTTPURLResponse)?.statusCode,
               !(200...299).contains(code) {
                return completion(.failure(URLError(.badServerResponse)))
            }
            // missing data
            guard let data = data else {
                return completion(.failure(URLError(.zeroByteResource)))
            }
            do {
                let stops = try JSONDecoder().decode([Stop].self, from: data)
                completion(.success(stops))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
