//
//  RouteCard.swift
//  TriLive
//
//  Created by Anthony Qin on 6/16/25.
//




/*
 let dummyBusRoutes = [
 BusRoute(id: 12, name: "Line 12 - Barbur/Sandy Blvd", arrivalTime: 1545, direction: "Eastbound to Sandy", realTime: 1548),
 BusRoute(id: 75, name: "Line 75 - Chavez/Lombard", arrivalTime: 1550, direction: "Northbound to Lombard", realTime: 1551)
 ]
 */

import SwiftUI

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
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .font(.headline)
                .foregroundColor(.white)
                .padding(10)
                .background(line.isMAX ? Color.blue : Color.green)
                .clipShape(Circle())
                .scaledToFill()
                .frame(width: 54, height: 54)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(line.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
                
                Text(line.direction)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.95)
                    .multilineTextAlignment(.leading)
            }
            .layoutPriority(1)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(line.formattedMinutesRemaining)
                    .font(.headline)
                    .foregroundColor(.green)
                    .lineLimit(1)
                    .frame(width: 80)
                
                Button(action: toggleFavorite) {
                          Image(systemName: isFavorited ? "star.fill" : "star")
                            .foregroundColor(isFavorited ? .yellow : .secondary)
                }
                .buttonStyle(.plain)
            }
            .frame(minWidth: 80, alignment: .topTrailing)
        }
        .padding()
        .background(isSelected ? Color.green.opacity(0.2) : Color(.black))
        .cornerRadius(12)
        .shadow(radius: isSelected ? 4 : 1)
        .onTapGesture(perform: onTap)
    }
}

struct RouteCard_Previews: PreviewProvider {
    static var previews: some View {
        //using the first stop and its third route as sample
        RouteCard(
            parentStop: stops[0],
            line: stops[0].routeList[2],
            isSelected: false,
            onTap: {},
            isFavorited: false,
            toggleFavorite: {}
        )
    }
}

