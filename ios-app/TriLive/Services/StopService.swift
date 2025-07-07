//
//  StopService.swift
//  TriLive
//
//  Created by Brian Maina on 7/3/25.
//

import Foundation

class StopService {
    static let shared = StopService()
    private let baseURL = URL(
        string: Bundle.main
            .object(forInfoDictionaryKey: "API_BASE_URL") as! String
    )!
    // base url pulled from Info.plist. forced-unwrap will crash if missing or invalid, i tried putting it in the ino.plist but idk if its right

    // fetch list of stops from server
    func fetchStops(completion: @escaping (Result<[Stop], Error>) -> Void) {
        // note: using "stations" path—ensure this matches your API endpoint for stops
        let url = baseURL.appendingPathComponent("stations")
        
        URLSession.shared.dataTask(with: url) { data, res, err in
            // handle transport error
            if let err = err {
                return completion(.failure(err))
            }
            
            //ensure we received data
            guard let data = data else {
                return completion(.failure(URLError(.badServerResponse)))
            }
        
            
            do {
                //decode json into Stop models
                let stops = try JSONDecoder().decode([Stop].self, from: data)
                completion(.success(stops))
            } catch {
                completion(.failure(error))
            }
        }
        .resume()
        // start the network request
    }
}



