//
//  StationService.swift
//  TriLive
//
//  Created by Brian Maina on 7/3/25.
//
// StationService.swift

import Foundation

private struct API {
    static var baseURL: URL {
        guard let s = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
              let url = URL(string: s) else {
            fatalError("API_BASE_URL is missing or invalid in Info.plist")
        }
        return url
    }
}

private enum NetworkError: Error {
    case noData, badStatus(Int)
}

final class StationService {
    static let shared = StationService()
    private init() {}

    //Fetches all stations (for your map) from GET /stations
    func fetchStations(_ completion: @escaping (Result<[Station], Error>) -> Void) {
        let url = API.baseURL.appendingPathComponent("stations")
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                return completion(.failure(error))
            }
            if let code = (response as? HTTPURLResponse)?.statusCode,
               !(200...299).contains(code) {
                return completion(.failure(NetworkError.badStatus(code)))
            }
            guard let data = data else {
                return completion(.failure(NetworkError.noData))
            }
            do {
                let list = try JSONDecoder().decode([Station].self, from: data)
                completion(.success(list))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchRoutes(
        for stopID: Int,
        completion: @escaping (Result<[Route], Error>) -> Void
      ) {
        let url = API.baseURL
          .appendingPathComponent("stations")
          .appendingPathComponent("\(stopID)")
          .appendingPathComponent("routes")

        URLSession.shared.dataTask(with: url) { data, _, error in
          if let e = error {
            completion(.failure(e)); return
          }
          guard let d = data else {
            completion(.failure(URLError(.badServerResponse))); return
          }
          do {
            let routes = try JSONDecoder().decode([Route].self, from: d)
            completion(.success(routes))
          } catch {
            completion(.failure(error))
          }
        }
        .resume()
      }
    }

