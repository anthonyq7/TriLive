//
//  RouteCard.swift
//  TriLive
//
//  Created by Anthony Qin on 6/16/25.
//

import SwiftUI


/*
 let dummyBusRoutes = [
 BusRoute(id: 12, name: "Line 12 - Barbur/Sandy Blvd", arrivalTime: 1545, direction: "Eastbound to Sandy", realTime: 1548),
 BusRoute(id: 75, name: "Line 75 - Chavez/Lombard", arrivalTime: 1550, direction: "Northbound to Lombard", realTime: 1551)
 ]
 */

let dummyStop1 = Stop(
    id: 258,
    name: "Hawthorne & 12th",
    routeList: dummyRoutes1
)

struct RouteCard: View {
    let parentStop: Stop
    let line: Route
    let isSelected: Bool
    let onTap: () -> Void
    let isFavorited: Bool
    let toggleFavorite: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
                Text(line.isMAX ? "MAX" : "\(line.id)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(line.isMAX ? Color.blue : Color.green)
                    .clipShape(Circle())
                    
                VStack(alignment: .leading, spacing: 4) {
                    Text(line.name)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(2)
                        
                    
                    Text(line.direction)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                .layoutPriority(1)
                
                Spacer()
                
                //Text(line.formattedMinutesRemaining)
                    //.padding(.horizontal)
                    //.foregroundStyle(.tint) //eventually make this time into currentTime - realTime so that it displays the minutes remaining but this shall suffice for now
                
                Spacer()
                //Create Favorite Button
            VStack(alignment: .trailing, spacing: 4) {
                Text(line.formattedMinutesRemaining)
                    .font(.title3)
                    .foregroundColor(.green)
                    .lineLimit(1)
                Button(action: toggleFavorite) {
                    Image(systemName: isFavorited ? "star.fill" : "star")
                        .foregroundColor(isFavorited ? .yellow : .secondary)
                }
            }
            .frame(minWidth: 80, alignment: .topTrailing)
        }
        .padding()
        .background(isSelected ? Color.green.opacity(0.2) : Color.black)
        .cornerRadius(12)
        .shadow(radius: isSelected ? 4 : 1)
        .onTapGesture(perform: onTap)
   }
}

    
    
    struct RouteCard_Previews: PreviewProvider {
        static var previews: some View {
                RouteCard(
                    parentStop: dummyStop1,
                    line: dummyRoutes1[2],
                    isSelected: false,
                    onTap: {},
                    isFavorited: false,
                    toggleFavorite: {}
                )
                .padding()
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
            }
        }
        
        func timeConverter(time: Int) -> String { //Converts time from hrmin to hr:min
            
            var hour: Int {
                let temp = time/100
                
                if temp > 12{
                    return temp - 12
                } else {
                    return temp
                }
                
            }
            
            var minute: String {
                
                if time%100 < 10 {
                    return "0" + String(time%100)
                } else {
                    return String(time%100)
                }
                
            }
            
            return String(hour) + ":" + String(minute)
        }
    
