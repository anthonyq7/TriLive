//
//  ApiService.swift
//  TriLive
//
//  Created by Brian Maina on 7/11/25.

import Foundation

struct APIClient {
    private let baseURL = Bundle.main.apiBaseURL
    private var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }
    
    // fetch the stop catalog from GET /stops
    func fetchStops() async throws -> [Stop] {
        let url = baseURL.appendingPathComponent("stations")
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }
        if let txt = String(data: data, encoding: .utf8) {
            print("RAW /stops response:", txt)
        }
        
        return try decoder.decode([Stop].self, from: data)
    }
    
    
    // fetch arrivals from GET /arrivals/{stop_id}
    func fetchArrivals(for stopId: Int) async throws -> [Arrival] {
        let url = baseURL
          .appendingPathComponent("arrivals")
          .appendingPathComponent("\(stopId)")
        let (data, resp) = try await URLSession.shared.data(from: url)
        guard let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }

        // 1) Dump raw JSON so we can see it again
        if let s = String(data: data, encoding: .utf8) {
            print("RAW /arrivals/\(stopId) JSON:\n\(s)\n")
        }

        // 2) Fallback to manual JSONSerialization
        let top = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        var arrivals: [Arrival] = []
        for (_, value) in top {
            guard let dict = value as? [String: Any],
                  let rid   = dict["route_id"]   as? Int,
                  let name  = dict["route_name"] as? String,
                  let status = dict["status"]    as? String,
                  let eta    = dict["eta"]       as? Int,
                  let color  = dict["route_color"] as? String
            else {
                print("⚠️ Skipping malformed arrival entry:", value)
                continue
            }
            let a = Arrival(
              routeId:    rid,
              routeName:  name,
              status:     status,
              eta:        eta,
              routeColor: color
            )
            arrivals.append(a)
        }

        // 3) Return the array
        return arrivals
    }



}



