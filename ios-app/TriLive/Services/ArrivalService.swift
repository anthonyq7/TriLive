//
//  ArrivalService.swift
//  TriLive
//
//  Created by Brian Maina on 7/7/25.
//


import Foundation

final class ArrivalService {
  static let shared = ArrivalService()

  private var baseURL: URL {
    guard let s = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
          let u = URL(string: s) else {
      fatalError("API_BASE_URL missing or invalid in Info.plist")
    }
    return u
  }

  func fetchArrivals(
    for stopID: Int,
    limit: Int = 5,
    minutes: Int = 60,
    completion: @escaping (Result<[Arrival], Error>) -> Void
  ) {
    let endpoint = baseURL.appendingPathComponent("stations/\(stopID)/arrivals")
    var comps = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)!
    comps.queryItems = [
      URLQueryItem(name: "limit",   value: String(limit)),
      URLQueryItem(name: "minutes", value: String(minutes))
    ]
    guard let url = comps.url else {
      return completion(.failure(URLError(.badURL)))
    }

    URLSession.shared.dataTask(with: url) { data, resp, err in
      if let err = err { return completion(.failure(err)) }
      guard let data = data else {
        return completion(.failure(URLError(.badServerResponse)))
      }
      do {
        let arr = try JSONDecoder().decode([Arrival].self, from: data)
        completion(.success(arr))
      } catch {
        completion(.failure(error))
      }
    }.resume()
  }
}
