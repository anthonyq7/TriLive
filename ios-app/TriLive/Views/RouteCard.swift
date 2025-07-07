//
//  RouteCard.swift
//  TriLive
//
//  Created by Anthony Qin on 6/16/25.
//


import SwiftUI

// view representing a single route row with tap and favorite actions
struct RouteCard: View {
    let parentStop: Stop
    let line: Route
    let isSelected: Bool
    let onTap: () -> Void
    let isFavorited: Bool
    let toggleFavorite: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // route badge: either "MAX" or the route id
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
            
            // route name and direction
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
            
            // time remaining and favorite button
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
        .background(isSelected
                        ? Color.green.opacity(0.2)
                        : Color(.black))
        .cornerRadius(12)
        .shadow(radius: isSelected ? 4 : 1)
        .onTapGesture(perform: onTap)          
    }
}

struct RouteCard_Previews: PreviewProvider {
    static var previews: some View {
        // sample data for preview; replace with real Stop and Route values
        let sampleStop = Stop(id: 1, name: "Main St", routeList: [])
        let sampleRoute = Route(id: 10, name: "10 - Downtown", arrivalTime: 0, direction: "northbound", realTime: 0, isMAX: false)
        RouteCard(
            parentStop: sampleStop,
            line: sampleRoute,
            isSelected: false,
            onTap: {},
            isFavorited: false,
            toggleFavorite: {}
        )
        .preferredColorScheme(.dark)
    }
}

