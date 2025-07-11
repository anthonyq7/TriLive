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
    
    func fetchArrivals(for stationID: Int, completion: @escaping (Result<[Arrival],Error>) -> Void) {
      let url = baseURL
        .appendingPathComponent("stations")
        .appendingPathComponent("\(stationID)")
        .appendingPathComponent("arrivals")

      URLSession.shared.dataTask(with: url) { data, resp, err in
        if let http = resp as? HTTPURLResponse, http.statusCode == 404 {
          // station exists but has no trimetID → treat as “no arrivals”
          DispatchQueue.main.async { completion(.success([])) }
          return
        }
        if let err = err {
          DispatchQueue.main.async { completion(.failure(err)) }
          return
        }
        guard let data = data else {
          DispatchQueue.main.async { completion(.failure(URLError(.badServerResponse))) }
          return
        }
        do {
          let arr = try JSONDecoder().decode([Arrival].self, from: data)
          DispatchQueue.main.async { completion(.success(arr)) }
        } catch {
          DispatchQueue.main.async { completion(.failure(error)) }
        }
      }.resume()
    }
}
