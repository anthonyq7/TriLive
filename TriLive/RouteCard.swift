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
    @State var isFavorite: Bool = false
    @State var isSelected: Bool = false
    
    var body: some View {
        
        VStack {
            HStack {
                Text(line.name)
                    .padding(.horizontal)
                
                Spacer()
                
                Text(timeConverter(time: line.realTime).description)
                    .padding(.horizontal)
                    .foregroundStyle(.tint) //eventually make this time into currentTime - realTime so that it displays the minutes remaining but this shall suffice for now
                
                Spacer()
                //Create Favorite Button
                if !isFavorite {
                    Image(systemName: "star")
                        .font(.title2)
                        .padding(.horizontal)
                        .onTapGesture {
                            isFavorite.toggle()
                        }
                } else {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.title2)
                        .padding(.horizontal)
                        .onTapGesture {
                            isFavorite.toggle()
                        }
                }
            }
            
            Text(line.direction)
                .padding(.vertical, 5)
                .fontWeight(.bold)
                .lineLimit(1)
        }
        .lineLimit(1)
        .foregroundStyle(.white)
        .padding(.vertical, 20)
        .background(Color.appBackground)
        .overlay(
            Rectangle()
                .stroke(isSelected ? Color.green: Color.white, lineWidth: 2.5) //Convert to green when selected
        )
        .onTapGesture {
            isSelected.toggle()
        }
    }
}


#Preview {
    RouteCard(parentStop: dummyStop1, line: dummyRoutes1[2])
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

