//
//  StationService.swift
//  TriLive
//
//  Created by Brian Maina on 7/3/25.
//
// StationService.swift

import Foundation

//pull base url from Info.plist under key API_BASE_URL
private struct API {
    static var baseURL: URL {
        guard let s = Bundle.main
                .object(forInfoDictionaryKey: "API_BASE_URL") as? String,
              let url = URL(string: s) else {
            fatalError("you must set API_BASE_URL in your Info.plist")
        }
        return url
    }
}

//simple error type for missing data
private enum NetworkError: Error {
    case noData
}

final class StationService {
    static let shared = StationService()
    private init() {}

    // unlabelled first parameter lets you call:
    // StationService.shared.fetchStations { result in … }
    func fetchStations(
        _ completion: @escaping (Result<[Station], Error>) -> Void
    ) {
        // build request url by appending path component
        let url = API.baseURL.appendingPathComponent("stations")
        
        URLSession.shared.dataTask(with: url) { data, _, err in
            // if an error occurred, return it
            if let err = err {
                return completion(.failure(err))
            }
            // ensure data is present
            guard let data = data else {
                return completion(.failure(NetworkError.noData))
            }
            do {
                // decode json into Station array
                let list = try JSONDecoder().decode([Station].self, from: data)
                completion(.success(list))
            } catch {
                completion(.failure(error))
            }
        }
        .resume()
        // start the network request
    }
}

