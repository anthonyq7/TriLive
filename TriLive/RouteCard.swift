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
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .layoutPriority(1)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(line.formattedMinutesRemaining)
                    .font(.title3)
                    .foregroundColor(.green)
                    .lineLimit(1)
                
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
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
