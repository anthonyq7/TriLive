//
//  Arrival.swift
//  TriLive
//
//  Created by Brian Maina on 7/7/25.
//

import Foundation

struct Arrival: Identifiable, Decodable {
    var id: UUID { UUID() }
    let route: Int
    let name: String
    let direction: String
    let scheduled: Int
    let estimated: Int?
    let isMAX: Bool
}

extension Arrival {
  //Minutes from now until the arrival’s `realTime` value
  var minutesUntilArrival: Int {
    let comps = Calendar.current.dateComponents([.hour, .minute], from: Date())
    let currentMins = (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
    let h = (estimated ?? scheduled) / 100
    let m = (estimated ?? scheduled) % 100
    return max(h * 60 + m - currentMins, 0)
  }

  //A “3 mins” vs “1 min” friendly string
  var minutesUntilArrivalString: String {
    let mins = minutesUntilArrival
    return "\(mins) min" + (mins == 1 ? "" : "s")
  }
}
