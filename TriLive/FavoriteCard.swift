//
//  FavoriteCard.swift
//  TriLive
//
//  Created by Anthony Qin on 6/17/25.
//

import SwiftUI

struct FavoriteCard: View {
    let parentStop: Stop
    let route: Route
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Route badge
            Text(route.isMAX ? "MAX" : "\(route.id)")
                .font(.headline)
                .foregroundColor(.white)
                .padding(10)
                .background(route.isMAX ? Color.blue : Color.green)
                .clipShape(Circle())

            // Route name
            Text(route.name)
                .font(.body)
                .foregroundColor(.white)
                .lineLimit(2)

            Spacer()

            // Stop info
            Text("Stop \(parentStop.id)")
                .font(.subheadline)
                .foregroundColor(.white)

            Spacer()

            // Remove favorite button
            Button(action: onRemove) {
                Image(systemName: "star.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
            }
        }
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
    RouteCard(
        parentStop: stops[0],
        line:       stops[0].routeList[2],
        isSelected: false,
        onTap:      {},
        isFavorited:false,
        toggleFavorite: {}
    )
    .padding()
    .preferredColorScheme(.dark)
}
