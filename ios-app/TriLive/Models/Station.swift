//
//  Station.swift
//  TriLive
//
//  Created by Brian Maina on 7/3/25.
//
//matches our sql database
import Foundation

struct Station: Decodable, Identifiable {
  let id: Int
  let name: String
  let latitude: Double
  let longitude: Double
  let description: String?
}
