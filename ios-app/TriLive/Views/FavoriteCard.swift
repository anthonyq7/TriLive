//
//  FavoriteCard.swift
//  TriLive
//
//  Created by Anthony Qin on 6/17/25.
//

import SwiftUI

struct FavoriteCard: View {
    let parentStop: Stop
    // stop this favorite belongs to
    let route: Route
    // route info for this favorite
    let onRemove: () -> Void
    // action to call when remove button is tapped

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // layout items horizontally
            // route badge with id or "MAX"
            Text(route.isMAX ? "MAX" : "\(route.id)")
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .font(.headline)
                .foregroundColor(.white)
                .padding(10)
                .background(route.isMAX ? Color.blue : Color.green)
                .clipShape(Circle())
                .scaledToFill()
                .frame(width: 54, height: 54)
            
            // route details (name and direction)
            VStack(alignment: .leading, spacing: 4) {
                Text(route.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
                
                Text(route.direction)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.95)
                    .multilineTextAlignment(.leading)
            }
            .layoutPriority(1)
            
            Spacer()
            
            // stop info and remove button
            VStack(alignment: .trailing, spacing: 12) {
                Text("Stop \(parentStop.id)")
                    .font(.subheadline)
                    .lineLimit(1)
                    .foregroundColor(.white)
                    .frame(width: 65)
                
                // remove favorite button
                Button(action: onRemove) {
                    Image(systemName: "star.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.primary.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white, lineWidth: 2)
        )
        .cornerRadius(12)
    }
}

#Preview {
    // define sample data for preview
    let sampleStop = Stop(id: 1, name: "Main St", routeList: [])
    let sampleRoute = Route(id: 10, name: "10 - Downtown", arrivalTime: 0, direction: "northbound", realTime: 0, isMAX: false)
    FavoriteCard(
        parentStop: sampleStop,
        route: sampleRoute,
        onRemove: {}
    )
    .preferredColorScheme(.dark)
}
