import Foundation

//model representing a transit route
struct Route: Identifiable, Hashable, Codable {
  let id: Int
  let name: String
  let arrivalTime: Int
  let direction: String
  let realTime: Int
  let isMAX: Bool
    
    //computed property calculating minutes until arrival from now
    var minutesUntilArrival: Int {
        let now = Date()
        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute], from: now)
        let nowTotal = (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
        let arrivalH = realTime / 100
        let arrivalM = realTime % 100
        let arrivalTotal = arrivalH * 60 + arrivalM
        //ensures non-negative result
        return max(arrivalTotal - nowTotal, 0)
      }

    //formatted string showing minutes until arrival
      var formattedMinutesRemaining: String {
        let m = minutesUntilArrival
        return "\(m) min" + (m == 1 ? "" : "s")
      }
    }

// model representing a transit stop
struct Stop: Identifiable, Hashable, Codable {
  let id: Int
  let name: String
  let routeList: [Route]
}

