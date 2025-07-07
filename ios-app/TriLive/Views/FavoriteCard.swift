//
//  FavoriteCard.swift
//  TriLive
//
//  Created by Anthony Qin on 6/17/25.
//

import SwiftUI

//A card showing a favorited route at a given stop, with a remove button.
struct FavoriteCard: View {
    let parentStop: Stop
    let route: Route
    let onRemove: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // MARK: – Route badge (circular)
            Text(route.isMAX ? "MAX" : "\(route.id)")
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .font(.headline)
                .foregroundColor(.white)
                .padding(10)
                .background(route.isMAX ? Color.blue : Color.green)
                .clipShape(Circle())
                .frame(width: 54, height: 54)

            // MARK: – Route details (name & direction)
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

            // MARK: – Stop info & remove favorite button
            VStack(alignment: .trailing, spacing: 12) {
                // show stop’s name instead of just its id
                Text(parentStop.name)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .frame(width: 100, alignment: .trailing)

                Button(action: onRemove) {
                    Image(systemName: "star.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Remove favorite \(route.name) from \(parentStop.name)")
                .accessibilityAddTraits(.isButton)
            }
            .padding()
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
    // sample Stop matching your new model
    let sampleStop = Stop(
        id: 1,
        name: "Main St & 3rd Ave",
        latitude: 45.512,
        longitude: -122.658,
        description: "Near the library"
    )
    // sample Route (manually constructed)
    let sampleRoute = Route(
        id: 10,
        name: "10 – Downtown",
        arrivalTime: 900,
        direction: "Northbound",
        realTime: 905,
        isMAX: false
    )

    FavoriteCard(
        parentStop: sampleStop,
        route: sampleRoute,
        onRemove: { print("Removed!") }
    )
    .preferredColorScheme(.dark)
}
