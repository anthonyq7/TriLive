import Foundation
//moved all the data models here i was getting kinda confused

struct Route: Identifiable, Hashable {
  let id: Int
  let name: String
  let arrivalTime: Int
  let direction: String
  let realTime: Int
  let isMAX: Bool

  var minutesUntilArrival: Int {
    let now = Date()
    let cal = Calendar.current
    let comps = cal.dateComponents([.hour, .minute], from: now)
    let nowTotal = (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
    let arrivalH = realTime / 100
    let arrivalM = realTime % 100
    let arrivalTotal = arrivalH * 60 + arrivalM
    return max(arrivalTotal - nowTotal, 0)
  }

  var formattedMinutesRemaining: String {
    let m = minutesUntilArrival
    return "\(m) min" + (m == 1 ? "" : "s")
  }
}

struct Stop: Identifiable, Hashable {
  let id: Int
  let name: String
  let routeList: [Route]
}


let dummyRoutes1 = [
  Route(id: 12, name: "Line 12 – Barbur/Sandy Blvd", arrivalTime: 1545, direction: "Eastbound to Sandy", realTime: 1559, isMAX: false),
  Route(id: 75, name: "Line 75 – Chavez/Lombard", arrivalTime: 1550, direction: "Northbound to Lombard", realTime: 1551, isMAX: false),
  Route(id: 1,  name: "MAX Green Line",               arrivalTime: 1548, direction: "Southbound to Clackamas", realTime: 1550, isMAX: true),
  Route(id: 2,  name: "MAX Blue Line",                arrivalTime: 1553, direction: "Eastbound to Gresham",    realTime: 1553, isMAX: true)
]

let dummyRoutes2 = [
  Route(id: 72, name: "Line 72 – Killingsworth/82nd Ave", arrivalTime: 1600, direction: "Southbound to Clackamas Town Center", realTime: 1603, isMAX: false),
  Route(id: 19, name: "Line 19 – Woodstock/Glisan",      arrivalTime: 1605, direction: "Eastbound to Gateway Transit Center", realTime: 1607, isMAX: false),
  Route(id: 3,  name: "MAX Red Line",                   arrivalTime: 1602, direction: "Westbound to Beaverton TC",          realTime: 1601, isMAX: true)
]

let stops = [
  Stop(id: 258, name: "Hawthorne & 12th", routeList: dummyRoutes1),
  Stop(id: 312, name: "NE 82nd & Glisan",  routeList: dummyRoutes2)
]

