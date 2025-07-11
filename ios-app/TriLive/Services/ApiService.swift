//
//  ApiService.swift
//  TriLive
//
//  Created by Brian Maina on 7/11/25.
//


import Foundation

final class ApiService {
  static let shared = ApiService()
  private let baseURL = URL(string: "https://trilive-backend.onrender.com")!

  func getStations(completion: @escaping (Result<[Station], Error>) -> Void) {
    let url = baseURL.appendingPathComponent("/stations")
    URLSession.shared.dataTask(with: url) { data, _, err in
      if let err = err { return completion(.failure(err)) }
      guard let data = data else { return completion(.failure(NSError())) }
      do {
        let stations = try JSONDecoder().decode([Station].self, from: data)
        completion(.success(stations))
      } catch {
        completion(.failure(error))
      }
    }.resume()
  }

  func getArrivals(for stationID: Int,
                   limit: Int = 5,
                   minutes: Int = 60,
                   completion: @escaping (Result<[Arrival], Error>) -> Void)
  {
    var url = baseURL.appendingPathComponent("/stations/\(stationID)/arrivals")
    let qs = "?limit=\(limit)&minutes=\(minutes)"
    url = URL(string: url.absoluteString + qs)!
    URLSession.shared.dataTask(with: url) { data, _, err in
      if let err = err { return completion(.failure(err)) }
      guard let data = data else { return completion(.failure(NSError())) }
      do {
        let arrivals = try JSONDecoder().decode([Arrival].self, from: data)
        completion(.success(arrivals))
      } catch {
        completion(.failure(error))
      }
    }.resume()
  }
}
