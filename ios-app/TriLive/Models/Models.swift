import Foundation

//model representing a transit route
import Foundation

struct Route: Identifiable, Hashable, Codable {
  let id: Int
  let name: String
  let arrivalTime: Int        // ms since 1970
  let direction: String
  let realTime: Int           // ms since 1970 (use estimated if available)
  let isMAX: Bool

  // Date of the expected arrival
  var arrivalDate: Date {
    Date(timeIntervalSince1970: Double(realTime) / 1000)
  }

  // Minutes from now until that date (never negative)
  var minutesUntilArrival: Int {
    let interval = arrivalDate.timeIntervalSinceNow
    return max(Int(interval / 60), 0)
  }

  // “5 min” or “1 min” formatting
  var formattedMinutesRemaining: String {
    let m = minutesUntilArrival
    return "\(m) min" + (m == 1 ? "" : "s")
  }
}


// model representing a transit stop
struct Stop: Identifiable, Hashable, Codable {
  let id: Int
  let name: String
  let latitude: Double
  let longitude: Double
  let description: String?
}

