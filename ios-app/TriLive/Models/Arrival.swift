//
//  Arrival.swift
//  TriLive
//
//  Created by Brian Maina on 7/7/25.
//

import Foundation


// Arrival.swift
struct Arrival: Identifiable, Codable, Hashable {
  let route: Int
  let scheduled: Int
  let estimated: Int?
  let vehicle: String?
  var id: String { vehicle ?? "\(route)-\(scheduled)" }
}
