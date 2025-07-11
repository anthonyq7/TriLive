import Foundation

struct Arrival: Identifiable, Decodable {
    // this one will never be decoded, but auto-get a brand new UUID
    var id = UUID()

    let route:     Int
    let scheduled: Int
    let estimated: Int?
    let vehicle:   String?

    // only these four go to/from JSON
    enum CodingKeys: String, CodingKey {
      case route, scheduled, estimated, vehicle
    }


  //Convert the Int-ms to a proper Date
  var scheduledDate: Date {
    Date(timeIntervalSince1970: Double(scheduled) / 1_000)
  }
  var estimatedDate: Date? {
    guard let est = estimated else { return nil }
    return Date(timeIntervalSince1970: Double(est) / 1_000)
  }

  // minutes from now until whichever timestamp is available
  var minutesUntilArrival: Int {
    let target = estimatedDate ?? scheduledDate
    let diff = target.timeIntervalSince(Date())
    return max(0, Int(diff / 60.0))
  }
}
