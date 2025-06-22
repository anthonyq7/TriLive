//
//  TimeConversion.swift
//  TriLive
//
//  Created by Brian Maina on 6/22/25.
//

import Foundation

extension Route {
  var minutesUntilArrival: Int {
    let now = Date()
    let cal = Calendar.current
    let comps = cal.dateComponents([.hour, .minute], from: now)
    let nowTotal = (comps.hour ?? 0) * 60 + (comps.minute ?? 0)

    let arrivalH = self.realTime / 100
    let arrivalM = self.realTime % 100
    let arrivalTotal = arrivalH * 60 + arrivalM

    return max(arrivalTotal - nowTotal, 0)
  }

  var formattedMinutesRemaining: String {
    let m = minutesUntilArrival
    return "\(m) min" + (m == 1 ? "" : "s")
  }
}

