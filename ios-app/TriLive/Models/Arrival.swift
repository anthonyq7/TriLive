import Foundation

struct Arrival: Identifiable, Decodable {

    var id = UUID()
    let route: Int
    let scheduled: Int
    let estimated: Int?
    let vehicle: String?


  //Convert the Int-ms to a proper Date
  var scheduledDate: Date {
    Date(timeIntervalSince1970: Double(scheduled) / 1_000)
  }
  var estimatedDate: Date? {
    guard let est = estimated else { return nil }
    return Date(timeIntervalSince1970: Double(est) / 1_000)
  }

  /// minutes from now until whichever timestamp is available
  var minutesUntilArrival: Int {
    let target = estimatedDate ?? scheduledDate
    let diff = target.timeIntervalSince(Date())
    return max(0, Int(diff / 60.0))
  }
}
